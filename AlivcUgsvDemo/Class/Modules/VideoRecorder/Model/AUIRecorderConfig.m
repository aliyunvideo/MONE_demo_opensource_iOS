//
//  AUIRecorderConfig.m
//  AlivcUgsvDemo
//
//  Created by coder.pi on 2022/6/5.
//

#import "AUIRecorderConfig.h"
#import "AUIVideoParamBuilder.h"

@implementation AUIRecorderConfig

- (void) setVideoConfig:(AliyunRecorderVideoConfig *)videoConfig {
    if (!videoConfig) {
        videoConfig = [AliyunRecorderVideoConfig new];
    }
    _videoConfig = videoConfig;
    [self updateResolutionType];
}

const static struct {
    AUIRecorderHorizontalResolution type;
    CGFloat width;
} HorizontalResolutionInfos[] = {
    {AUIRecorderHorizontalResolution480, 480.0},
    {AUIRecorderHorizontalResolution540, 540.0},
    {AUIRecorderHorizontalResolution720, 720.0},
    {AUIRecorderHorizontalResolution1080, 1080.0},
};
const static size_t HorizontalResolutionInfosCount = sizeof(HorizontalResolutionInfos) / sizeof(HorizontalResolutionInfos[0]);

const static struct {
    AUIRecorderResolutionRatio type;
    CGFloat ratio;
} ResolutionRatioInfos[] = {
    {AUIRecorderResolutionRatio_1_1, 1.0},
    {AUIRecorderResolutionRatio_3_4, 3.0/4.0},
    {AUIRecorderResolutionRatio_9_16, 9.0/16.0},
};
const static size_t ResolutionRatioInfosCount = sizeof(ResolutionRatioInfos) / sizeof(ResolutionRatioInfos[0]);

- (void) updateResolutionType {
    CGSize size = _videoConfig.resolution;
    if (size.width <= 0 || size.height <= 0) {
        return;
    }
    
    for (int i = 0; i < HorizontalResolutionInfosCount; ++i) {
        if (HorizontalResolutionInfos[i].width == size.width) {
            _horizontalResolution = HorizontalResolutionInfos[i].type;
            break;
        }
    }
    
    CGFloat minDiff = CGFLOAT_MAX;
    CGFloat ratio = size.width / size.height;
    for (int i = 0; i < ResolutionRatioInfosCount; ++i) {
        CGFloat diff = fabs(ratio - ResolutionRatioInfos[i].ratio);
        if (diff < minDiff) {
            minDiff = diff;
            _resolutionRatio = ResolutionRatioInfos[i].type;
        }
    }
}

- (void) updateVideoResultion {
    CGSize size = CGSizeZero;
    for (int i = 0; i < HorizontalResolutionInfosCount; ++i) {
        if (_horizontalResolution == HorizontalResolutionInfos[i].type) {
            size.width = HorizontalResolutionInfos[i].width;
            break;
        }
    }
    
    for (int i = 0; i < ResolutionRatioInfosCount; ++i) {
        if (_resolutionRatio == ResolutionRatioInfos[i].type) {
            size.height = size.width / ResolutionRatioInfos[i].ratio;
            int validValue = size.height;
            validValue -= validValue & 1;
            size.height = validValue;
            break;
        }
    }

    _videoConfig.resolution = size;
}

- (void) setHorizontalResolution:(AUIRecorderHorizontalResolution)horizontalResolution {
    _horizontalResolution = horizontalResolution;
    [self updateVideoResultion];
}

- (void) setResolutionRatio:(AUIRecorderResolutionRatio)resolutionRatio {
    _resolutionRatio = resolutionRatio;
    [self updateVideoResultion];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _videoConfig = [AliyunRecorderVideoConfig new];
        _videoConfig.resolution = CGSizeMake(720, 1280);
        _videoConfig.encodeMode = AliyunRecorderEncodeMode_HardCoding;
        [self updateResolutionType];
        
        _isUsingAEC = NO;
        _isUsingCamera = YES;
        _minDuration = 3.0;
        _maxDuration = 15.0;
        _deleteVideoClipsOnExit = YES;
        _waterMarkPath = [NSBundle.mainBundle pathForResource:@"AlivcUgsv.bundle/logo_aliyun.png" ofType:@""];
#ifdef USING_SVIDEO_BASIC
        _mergeOnFinish = YES;
#endif // USING_SVIDEO_BASIC
    }
    return self;
}

- (BOOL)deleteVideoClipsOnExit {
    if (!_mergeOnFinish) {
        return NO;
    }
    return _deleteVideoClipsOnExit;
}

- (CGRect) cameraFrame {
    // TODO: 后续根据合拍、多源、单源等模式计算；当前全屏
    CGRect frame = CGRectZero;
    frame.size = _videoConfig.resolution;
    return frame;
}

- (AUIUgsvParamBuilder *)paramBuilder {
    AUIUgsvParamBuilder *builder = [AUIUgsvParamBuilder new];
    builder
        .group(@"VideoOutput", @"视频输出")
            .radioItem(@"ResolutionRatio", @"视频比例")
                .option(@"9:16", @(AUIRecorderResolutionRatio_9_16))
                .option(@"3:4", @(AUIRecorderResolutionRatio_3_4))
                .option(@"1:1", @(AUIRecorderResolutionRatio_1_1))
                .KVC(self, @"resolutionRatio")
            .radioItem(@"HorizontalResolution", @"分辨率")
                .option(@"480p", @(AUIRecorderHorizontalResolution480))
                .option(@"540p", @(AUIRecorderHorizontalResolution540))
                .option(@"720p", @(AUIRecorderHorizontalResolution720))
                .option(@"1080p", @(AUIRecorderHorizontalResolution1080))
                .KVC(self, @"horizontalResolution")
            .radioItem(@"ScaleModel", @"缩放模式")
                .option(@"裁剪", @(AliyunScaleModeFit))
                .option(@"填充", @(AliyunScaleModeFill))
                .KVC(self, @"videoConfig.scaleMode")
            .radioItem(@"EncodeMode", @"编码模式")
                .option(@"硬编码", @(AliyunRecorderEncodeMode_HardCoding))
                .option(@"软编码", @(AliyunRecorderEncodeMode_SoftCoding))
                .KVC(self, @"videoConfig.encodeMode")
            .radioItem(@"VideoQuality", @"视频质量")
                .option(@"优质", @(AliyunVideoQualityVeryHight))
                .option(@"良好", @(AliyunVideoQualityHight))
                .option(@"一般", @(AliyunVideoQualityMedium))
                .option(@"较差", @(AliyunVideoQualityLow))
                .option(@"非常差", @(AliyunVideoQualityPoor))
                .option(@"极度差", @(AliyunVideoQualityExtraPoor))
                .KVC(self, @"videoConfig.videoQuality")
            .textFieldItem(@"Bitrate", @"码率").isInt()
                .placeHolder(@"填入码率会忽略视频质量")
                .unit(@"kbps")
                .converter([AUIBitrateConverter new])
                .KVC(self, @"videoConfig.bitrate")
            .textFieldItem(@"FPS", @"帧率").isInt()
                .KVC(self, @"videoConfig.fps")
            .textFieldItem(@"GOP", @"关键帧间隔").isInt()
                .placeHolder(@"建议3秒（配合帧率计算设置）")
                .KVC(self, @"videoConfig.gop")
        .group(@"Duration", @"录制时间")
            .textFieldItem(@"MinDuration", @"最小时长").isInt()
                .placeHolder(@"建议>1s")
                .KVC(self, @"minDuration")
            .textFieldItem(@"MaxDuration", @"最大时长").isInt()
                .KVC(self, @"maxDuration")
        .group(@"OnFinish", @"结束设置")
            .switchItem(@"NeedMerge", @"输出Mp4")
                .KVC(self, @"mergeOnFinish");
    return builder;
}
@end
