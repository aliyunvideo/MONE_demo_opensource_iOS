//
//  AUIRecorderWrapper.m
//  AlivcUgsvDemo
//
//  Created by coder.pi on 2022/6/5.
//

#import "AUIRecorderWrapper.h"
#import "AUIUgsvPath.h"
#import "NSString+AVHelper.h"
#import "Masonry.h"
#import "AVAlertController.h"
#import "UIView+AVHelper.h"
#import "AUIUgsvMacro.h"
#import "AlivcUgsvSDKHeader.h"

#ifdef ENABLE_BEAUTY
#import "AUIBeautyManager.h"
#endif // ENABLE_BEAUTY

@interface AUIRecorderWrapper ()<AliyunRecorderDelegate, AliyunRecorderCustomRender>
{
    NSMutableArray<NSNumber *> *_partDurations;
}
@property (nonatomic, strong) AliyunRecorderConfig *recorderConfig;

@property (nonatomic, strong) id<AliyunAVFileRecordController> mixVideoController;
@property (nonatomic, strong) UIView *mixVideoPreview;

#ifdef ENABLE_BEAUTY
@property (nonatomic, strong) id<AUIBeautyControllerProtocol> beautyController;
#endif // ENABLE_BEAUTY
@end

@implementation AUIRecorderWrapper

- (instancetype) initWithConfig:(AUIRecorderConfig *)config containerView:(UIView *)containerView {
    self = [super init];
    if (self) {
        _config = config;
        _containerView = containerView;
        _partDurations = @[].mutableCopy;
        [self setupRecorder];
    }
    return self;
}

- (void) setEnabledPreview:(BOOL)enabledPreview {
    if (_enabledPreview == enabledPreview) {
        return;
    }
    _enabledPreview = enabledPreview;
    if (_enabledPreview) {
        [self startPreview];
    } else {
        [self stopPreview];
    }
}

- (NSTimeInterval) duration {
    return _recorder.clipManager.duration;
}

- (NSTimeInterval) lastDuration {
    NSTimeInterval duration = 0;
    for (NSNumber *dur in _partDurations) {
        duration += dur.doubleValue;
    }
    return duration;
}

- (NSArray<NSNumber *> *) partDurations {
    return _partDurations.copy;
}

// MARK: - Actions
- (void) deleteLastPart {
    [_partDurations removeLastObject];
    [_recorder.clipManager deletePart];
}

- (void) startRecord {
    if (_recorder.state == AliyunRecorderState_Stopping) {
        [AVToastView show:AUIUgsvGetString(@"上一段正在存储，请稍等")
                     view:_containerView
                 position:AVToastViewPositionTop];
        return;
    }
    
    int ret = [_recorder startRecord];
    if (ret != ALIVC_COMMON_RETURN_SUCCESS) {
        __weak typeof(self) weakSelf = self;
        [self retryWithErrorTitle:AUIUgsvGetString(@"开始录制失败，是否重试") code:ret action:^(BOOL isCancel) {
            if (!isCancel) {
                [weakSelf startRecord];
            }
        }];
    }
}

- (void) stopRecord {
    [_recorder stopRecord];
}

- (void) cancelRecord {
    [_partDurations removeAllObjects];
    [_recorder cancel];
    if ([_delegate respondsToSelector:@selector(onAUIRecorderWrapperDidCancel:)]) {
        [_delegate onAUIRecorderWrapperDidCancel:self];
    }
}

static void s_retryForFinish(NSError *error, void(^onCompleted)(BOOL isCancel)) {
    [AVAlertController showWithTitle:AUIUgsvGetString(@"完成录制出错，是否重试？")
                             message:error.localizedDescription
                          needCancel:YES
                         onCompleted:onCompleted];
}

- (void)finishRecordSkipMerge:(void(^)(NSString *taskPath, NSError *error))completion {
    __weak typeof(self) weakSelf = self;
    [_recorder finishRecordForEdit:^(NSString *taskPath, NSError *error) {
        if (error) {
            s_retryForFinish(error, ^(BOOL isCancel) {
                if (isCancel) {
                    if (completion) {
                        completion(taskPath, error);
                    }
                    return;
                }
                [weakSelf finishRecordSkipMerge:completion];
            });
            return;
        }
        if (completion) {
            completion(taskPath, error);
        }
    }];
}

- (void)finishRecord:(void(^)(NSString *taskPath, NSString *outputPath, NSError *error))completion {
    NSString *taskPath = _recorderConfig.taskPath;
    __weak typeof(self) weakSelf = self;
    [_recorder finishRecord:^(NSString *outputPath, NSError *error) {
        if (error) {
            s_retryForFinish(error, ^(BOOL isCancel) {
                if (isCancel) {
                    if (completion) {
                        completion(taskPath, nil, error);
                    }
                    return;
                }
                [weakSelf finishRecord:completion];
            });
            return;
        }
        if (completion) {
            completion(taskPath, outputPath, error);
        }
    }];
}

- (void) startPreview {
    int ret = [_recorder startPreview];
    if (ret != ALIVC_COMMON_RETURN_SUCCESS) {
        __weak typeof(self) weakSelf = self;
        [self retryWithErrorTitle:AUIUgsvGetString(@"预览失败，是否重试") code:ret action:^(BOOL isCancel) {
            if (!isCancel) {
                [weakSelf startPreview];
            }
        }];
    }
}

- (void) stopPreview {
    [_recorder stopPreview];
}

// MARK: - AliyunRecorderDelegate
- (void) onAliyunRecorder:(AliyunRecorder *)recorder stateDidChange:(AliyunRecorderState)state {
    if (state == AliyunRecorderState_Stop) {
        NSTimeInterval cur = self.duration - self.lastDuration;
        if (cur > 0) {
            [_partDurations addObject:@(cur)];
        }
    }
    
    if ([_delegate respondsToSelector:@selector(onAUIRecorderWrapper:stateDidChange:)]) {
        [_delegate onAUIRecorderWrapper:self stateDidChange:state];
    }
}

- (void) onAliyunRecorder:(AliyunRecorder *)recorder progressWithDuration:(CGFloat)duration {
    if ([_delegate respondsToSelector:@selector(onAUIRecorderWrapper:progressWithDuration:)]) {
        [_delegate onAUIRecorderWrapper:self progressWithDuration:duration];
    }
}

- (void) onAliyunRecorder:(AliyunRecorder *)recorder occursError:(NSError *)error {
    __weak typeof(self) weakSelf = self;
    [AVAlertController showWithTitle:AUIUgsvGetString(@"录制出错了")
                             message:error.localizedDescription
                          needCancel:NO
                         onCompleted:^(BOOL isCanced) {
        [weakSelf cancelRecord];
    }];
}

- (void) onAliyunRecorderDidStopWithMaxDuration:(AliyunRecorder *)recorder {
    if ([_delegate respondsToSelector:@selector(onAUIRecorderWrapperWantFinish:)]) {
        [_delegate onAUIRecorderWrapperWantFinish:self];
    }
}

// MARK: - AliyunRecorderCustomRender
- (CVPixelBufferRef) onAliyunRecorderCustomRenderToPixelBuffer:(AliyunRecorder *)recorder
                                              withSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    CVPixelBufferRef pixelBufferRef = (CVPixelBufferRef)CMSampleBufferGetImageBuffer(sampleBuffer);
    if (!pixelBufferRef) {
        return pixelBufferRef;
    }
    
#ifdef ENABLE_BEAUTY
    [_beautyController createEngine];
    [_beautyController.processPixelBufferAutoAngle processPixelBuffer:pixelBufferRef];
#endif // ENABLE_BEAUTY
    
    return pixelBufferRef;
}

- (void) onAliyunRecorderDidDestory:(AliyunRecorder *)recorder {
#ifdef ENABLE_BEAUTY
    [_beautyController destroyEngine];
#endif // ENABLE_BEAUTY
}

// MARK: - Config
- (void) setupRecorder {
    if (_recorder) {
        return;
    }
    
    NSString *randomPath = [AUIUgsvPath exportFilePath:nil];
    _recorderConfig = [[AliyunRecorderConfig alloc] initWithVideoConfig:_config.videoConfig
                                                             outputPath:randomPath
                                                               usingAEC:_config.isUsingAEC];
    [self setupCamera];
    [self setupMixVideo];
    [self updateRecordLayout];
    
    [self setupWaterMark];

    _recorder = [[AliyunRecorder alloc] initWithConfig:_recorderConfig];
    _recorder.clipManager.minDuration = _config.minDuration;
    _recorder.clipManager.maxDuration = _config.maxDuration;
    _recorder.clipManager.deleteVideoClipsOnExit = _config.deleteVideoClipsOnExit;
    _recorder.delegate = self;
    _recorder.customRender = self;
    
    [_recorder prepare];
}

- (void)setupWaterMark {
    if (_config.waterMarkPath.length == 0 || ![NSFileManager.defaultManager fileExistsAtPath:_config.waterMarkPath]) {
        return;
    }
    
    UIImage *waterImg = [UIImage imageWithContentsOfFile:_config.waterMarkPath];
    

    CGRect frame = _config.waterFrame;
    if (frame.size.width == 0 || frame.size.height == 0) {
        frame.size.width = waterImg.size.width;
        frame.size.height = waterImg.size.height;
        frame.origin.x = frame.size.width;
        frame.origin.y = frame.size.height;
    }
    
    AliyunRecorderImageSticker *waterMark = [[AliyunRecorderImageSticker alloc] initWithImagePath:_config.waterMarkPath];
    waterMark.size = frame.size;
    waterMark.center = CGPointMake(frame.origin.x + 20, frame.origin.y + 20);
    waterMark.autoresizingMask = UIViewAutoresizingNone;
    [_recorderConfig addWaterMark:waterMark];
}

- (void) setupCamera {
    if (_camera) {
        [_recorderConfig removeCamera];
        [_camera removeFromSuperview];
    }
    
    AliyunVideoRecordLayoutParam *layout = [[AliyunVideoRecordLayoutParam alloc] initWithRenderMode:AliyunRenderMode_ResizeAspectFill];
    CGRect frame = _config.cameraFrame;
    CGPoint center = CGPointMake(frame.origin.x + frame.size.width * 0.5, frame.origin.y + frame.size.height * 0.5);
    layout.size = frame.size;
    layout.center = center;
    layout.zPosition = _config.cameraZPosition;
    
    id<AliyunCameraRecordController> controller = [_recorderConfig addCamera:layout];
    _camera = [[AUIRecorderCameraWrapper alloc] initWithCameraController:controller];
    [_containerView insertSubview:_camera atIndex:0];
}

- (void) setupMixVideo {
    if (_mixVideoController) {
        [_recorderConfig removeAVFileSource:_mixVideoController];
        [_mixVideoPreview removeFromSuperview];
        _mixVideoController = nil;
        _mixVideoPreview = nil;
    }
    
    if (_config.isMixRecord) {
        AliyunVideoRecordLayoutParam *layout = [[AliyunVideoRecordLayoutParam alloc] initWithRenderMode:AliyunRenderMode_ResizeAspectFill];
        CGRect frame = _config.mixVideoFrame;
        CGPoint center = CGPointMake(frame.origin.x + frame.size.width * 0.5, frame.origin.y + frame.size.height * 0.5);
        layout.size = frame.size;
        layout.center = center;
        layout.zPosition = _config.mixVideoZPosition;
        
        // 指定View录制源参数
        AliyunFileRecordSource *source = [[AliyunFileRecordSource alloc] initWithAVFilePath:_config.mixVideoFilePath startTime:0 duration:999];
        // 添加录制源，返回控制器
        id<AliyunAVFileRecordController> controller = [_recorderConfig addAVFileSource:source layout:layout];
        _mixVideoController = controller;
        
        _mixVideoPreview = [[UIView alloc] initWithFrame:CGRectZero];
        [_containerView insertSubview:_mixVideoPreview atIndex:1];
        controller.preview = _mixVideoPreview;
        
        _config.maxDuration = source.duration;
        _config.minDuration = source.duration;
    }
}

- (BOOL) changeResolutionRatio:(AUIRecorderResolutionRatio)ratio {
    if (_recorder.state != AliyunRecorderState_Idle) {
        return NO;
    }
    _config.resolutionRatio = ratio;
    _recorderConfig.videoConfig.resolution = _config.videoConfig.resolution;
    [self updateRecordLayout];
    return YES;
}

- (BOOL) changeMixLayout:(AUIRecorderMixType)mixType {
    if (_recorder.state != AliyunRecorderState_Idle) {
        return NO;
    }
    _config.mixType = mixType;
    [self updateRecordLayout];
    return YES;
}

#ifdef ENABLE_BEAUTY
- (void) showBeautyPanel {
    [self.beautyController showPanel:YES];
}

- (void)selectedDefaultBeautyPanel {
    [self beautyController];
}

- (id<AUIBeautyControllerProtocol>)beautyController {
    if (!_beautyController) {
        _beautyController = [AUIBeautyManager createController:_containerView processMode:AUIBeautyProcessModePixelBufferAutoAngle];
        [_beautyController setupPanelController];
    }
    return _beautyController;
}

#endif // ENABLE_BEAUTY

const static CGFloat HeaderHeight = 44.0;
- (void) updateRecordLayout {

    AliyunVideoRecordLayoutParam *cameraLayout = _camera.cameraController.layoutParam;
    if (cameraLayout) {
        CGRect frame = _config.cameraFrame;
        CGPoint center = CGPointMake(frame.origin.x + frame.size.width * 0.5, frame.origin.y + frame.size.height * 0.5);
        cameraLayout.size = frame.size;
        cameraLayout.center = center;
        cameraLayout.zPosition = _config.cameraZPosition;
    }
    AliyunVideoRecordLayoutParam *mixLayout = _mixVideoController.layoutParam;
    if (mixLayout) {
        CGRect frame = _config.mixVideoFrame;
        CGPoint center = CGPointMake(frame.origin.x + frame.size.width * 0.5, frame.origin.y + frame.size.height * 0.5);
        mixLayout.size = frame.size;
        mixLayout.center = center;
        mixLayout.zPosition = _config.mixVideoZPosition;
    }
    
    if (_mixVideoPreview) {
        if (_config.cameraZPosition > _config.mixVideoZPosition) {
            [_containerView sendSubviewToBack:_mixVideoPreview];
        }
        else {
            [_containerView sendSubviewToBack:_camera];
        }
    }
    
    CGSize resolution = _recorderConfig.videoConfig.resolution;
    CGRect validFrame = CGRectMake(0, HeaderHeight + AVSafeTop, _containerView.av_width, _containerView.av_width * resolution.height / resolution.width);
    CGFloat scale = validFrame.size.width / resolution.width;
    CGRect cameraFrame = CGRectMake(_config.cameraFrame.origin.x * scale + validFrame.origin.x,
                               _config.cameraFrame.origin.y * scale + validFrame.origin.y,
                               _config.cameraFrame.size.width * scale,
                               _config.cameraFrame.size.height * scale);
    CGRect mixVideoPreviewFrame = CGRectMake(_config.mixVideoFrame.origin.x * scale + validFrame.origin.x,
                                        _config.mixVideoFrame.origin.y * scale + validFrame.origin.y,
                                        _config.mixVideoFrame.size.width * scale,
                                        _config.mixVideoFrame.size.height * scale);

    [UIView animateWithDuration:0.2 animations:^{
        self.camera.frame = cameraFrame;
        self.mixVideoPreview.frame = mixVideoPreviewFrame;
    }];
}

- (void)applyBGMWithPath:(NSString *)path
               beginTime:(NSTimeInterval)beginTime
                duration:(NSTimeInterval)duration {
    [_recorder.config setBgMusicWithFile:path startTime:beginTime duration:duration];
    // TODO: 当前为单源录制模式，添加背景音移除麦克风；后面需要根据场景修改（混音、回声消除等设置）
    [_recorder.config removeMicrophone];
}

- (void)removeBGM {
    // TODO: 当前为单源录制模式，移除背景音添加麦克风；后面需要根据场景修改（混音、回声消除等设置）
    [_recorder.config removeBgMusic];
    [_recorder.config addMicrophone];
}

// MARK: - Helper
- (void) retryWithErrorTitle:(NSString *)title code:(int)code action:(void(^)(BOOL isCancel))action {
    [AVAlertController showWithTitle:title
                             message:[NSString stringWithFormat:AUIUgsvGetString(@"错误码：%d"), code]
                          needCancel:YES
                         onCompleted:^(BOOL isCanced) {
        if (action) {
            action(isCanced);
        }
    }];
}

// MARK: - passthrough
- (AliyunRecorderState) recorderState {
    return _recorder.state;
}

@end
