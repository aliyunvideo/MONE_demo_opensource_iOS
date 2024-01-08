//
//  AUIUgsvOpenModuleHelper.m
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/6/15.
//

#import "AUIUgsvOpenModuleHelper.h"
#import "AUIUgsvPath.h"
#import "AUIUgsvMacro.h"

#import "AUIPhotoPicker.h"
#import "AUIVideoRecorder.h"
#import "AUIVideoCrop.h"
#import "AUIMediaPublisher.h"

#import "AlivcUgsvSDKHeader.h"
#ifndef USING_SVIDEO_BASIC
#import "AUIVideoEditor.h"
#import "AUIVideoTemplateListViewController.h"
#endif // USING_SVIDEO_BASIC

#ifdef ENABLE_BEAUTY
#import "AUIBeautyManager.h"
#endif // ENABLE_BEAUTY


@implementation AUIUgsvPublishParamInfo
+ (AUIUgsvPublishParamInfo *) InfoWithSaveToAlbum:(BOOL)saveToAlbum needToPublish:(BOOL)needToPublish {
    AUIUgsvPublishParamInfo *info = [AUIUgsvPublishParamInfo new];
    info.saveToAlbum = saveToAlbum;
    info.needToPublish = needToPublish;
    return info;
}
- (instancetype)init {
    self = [super init];
    if (self) {
        _saveToAlbum = YES;
        _needToPublish = NO;
    }
    return self;
}
@end


@implementation AUIUgsvOpenModuleHelper

static AliyunVideoCodecType s_convertCodec(AliyunRecorderEncodeMode mode) {
    if (mode == AliyunRecorderEncodeMode_HardCoding) {
        return AliyunVideoCodecHardware;
    }
    return AliyunVideoCodecTypeAuto;
}

#ifndef USING_SVIDEO_BASIC
static AUIVideoOutputParam * s_convertRecordToEdit(AUIRecorderConfig *config) {
    AUIVideoOutputParam *param = [[AUIVideoOutputParam alloc] initWithOutputSize:config.videoConfig.resolution];
    param.fps = config.videoConfig.fps;
    param.gop = config.videoConfig.gop;
    param.bitrate = config.videoConfig.bitrate;
    param.videoQuality = config.videoConfig.videoQuality;
    param.scaleMode = config.videoConfig.scaleMode;
    param.codecType = s_convertCodec(config.videoConfig.encodeMode);
    return param;
}
#endif // USING_SVIDEO_BASIC

+ (void)openRecorder:(UIViewController *)currentVC
              config:(AUIRecorderConfig *)config
           enterEdit:(BOOL)enterEdit
        publishParam:(AUIUgsvPublishParamInfo *)publishParam {
    
    __weak typeof(currentVC) weakVC = currentVC;
    void (^openBlock)(AUIRecorderConfig *, AUIUgsvPublishParamInfo *) = ^(AUIRecorderConfig *config, AUIUgsvPublishParamInfo *publishParam){
        
        AUIVideoRecorder *recorder = [[AUIVideoRecorder alloc] initWithConfig:config onCompletion:^(AUIVideoRecorder *recorderSelf,
                                                                                                    NSString *taskPath,
                                                                                                    NSString * _Nullable outputPath,
                                                                                                    NSError * _Nullable error) {
            if (error) {   // 拍摄出错了
                NSString *errMsg = [NSString stringWithFormat:@"%@ : %@", AUIUgsvGetString(@"完成录制失败"), error.localizedDescription];
                [AVToastView show:errMsg view:weakVC.view position:AVToastViewPositionTop];
                return;
            }
            
#ifndef USING_SVIDEO_BASIC
            if (enterEdit) {  // 拍摄结束后，需要进入编辑
                AUIVideoEditor *editor = nil;
                if (config.mergeOnFinish) {
                    AUIVideoOutputParam *editParam = s_convertRecordToEdit(config);
                    AliyunClip *clip = [[AliyunClip alloc] initWithVideoPath:outputPath animDuration:0];
                    editor = [[AUIVideoEditor alloc] initWithClips:@[clip] withParam:editParam];
                }
                else {
                    editor = [[AUIVideoEditor alloc] initWithTaskPath:taskPath];
                }
                
                editor.saveToAlbumExportCompleted = publishParam.saveToAlbum;
                editor.needToPublish = publishParam.needToPublish;
                [weakVC.navigationController pushViewController:editor animated:YES];
                return;
            }
#endif // USING_SVIDEO_BASIC
            
            if (config.mergeOnFinish) { // 已经合并并生成最终的MP4
                if (publishParam.saveToAlbum) {  // 保存到相册
                    [AUIPhotoLibraryManager saveVideoWithUrl:[NSURL fileURLWithPath:outputPath] location:nil completion:^(PHAsset * _Nonnull asset, NSError * _Nonnull error) {
                        if (error) {
                            [AVToastView show:AUIUgsvGetString(@"保存相册失败") view:recorderSelf.view position:AVToastViewPositionMid];
                        }
                        else {
                            [AVToastView show:AUIUgsvGetString(@"保存相册成功") view:recorderSelf.view position:AVToastViewPositionMid];
                        }
                    }];
                }
                
                if (publishParam.needToPublish) {  // 发布到云端
                    AUIMediaPublisher *publisher = [[AUIMediaPublisher alloc] initWithVideoFilePath:outputPath withThumbnailImage:nil];
                    publisher.onFinish = ^(UIViewController * _Nonnull current, NSError * _Nullable error, id  _Nullable product) {
                        if (error) {
                            [AVAlertController showWithTitle:AUIUgsvGetString(@"出错了") message:error.description needCancel:NO onCompleted:^(BOOL isCanced) {
                                [current.navigationController popToViewController:recorderSelf animated:YES];
                            }];
                        }
                        else {
                            BOOL isPublish = [current isKindOfClass:AUIMediaPublisher.class];
                            [AVAlertController showWithTitle:nil message:isPublish ? AUIUgsvGetString(@"发布成功") : AUIUgsvGetString(@"导出成功") needCancel:NO onCompleted:^(BOOL isCanced) {
                                [current.navigationController popToViewController:recorderSelf animated:YES];
                            }];
                        }
                    };
                    [recorderSelf.navigationController pushViewController:publisher animated:YES];
                    return;
                }
                
                return;
            }
            
            // 其他处理方式，请自行处理
            
        }];
        [weakVC.navigationController pushViewController:recorder animated:YES];
    };
    
    
    AUIUgsvPublishParamInfo *thisPublishParam = publishParam;
    if (!thisPublishParam) {
        thisPublishParam = [AUIUgsvPublishParamInfo new];
    }
    AUIRecorderConfig *thisConfig = config;
    if (!thisConfig) {
        thisConfig = [AUIRecorderConfig new];
#ifdef USING_SVIDEO_BASIC
        thisConfig.mergeOnFinish = YES;
#endif
    }
    
#ifdef ENABLE_BEAUTY
    id<AUIBeautyResourceProtocol> resource = [AUIBeautyManager resourceChecker];
    if (resource) {
        AVProgressHUD *loading = [AVProgressHUD ShowHUDAddedTo:currentVC.view animated:YES];
        loading.labelText = AUIUgsvGetString(@"正在下载美颜模型中，请等待");
        [[AUIBeautyManager resourceChecker] checkResource:^(BOOL completed) {
            [loading hideAnimated:NO];
            if (completed) {
                openBlock(thisConfig, thisPublishParam);
            }
            else {
                [AVAlertController show:AUIUgsvGetString(@"美颜模型无法加载，退出") vc:currentVC];
            }
        }];
    }
    else {
        openBlock(thisConfig, thisPublishParam);
    }
#else
    openBlock(thisConfig, thisPublishParam);
#endif // ENABLE_BEAUTY
}

// 注意：使用该功能必须开通标准版或专业版的License，否则无法使用
+ (void)openMixRecorder:(UIViewController *)currentVC config:(AUIRecorderConfig *)config enterEdit:(BOOL)enterEdit publishParam:(AUIUgsvPublishParamInfo *)publishParam {
    if (!config) {
        config = [AUIRecorderConfig new];
        config.horizontalResolution = AUIRecorderHorizontalResolution720;
        config.resolutionRatio = AUIRecorderResolutionRatio_1_1;
        config.isUsingAEC = YES;
#ifdef USING_SVIDEO_BASIC
        config.mergeOnFinish = YES;
#endif
    }
    if (!publishParam) {
        publishParam = [AUIUgsvPublishParamInfo new];
    }
    
    if (!config.isMixRecord) {
        __weak typeof(currentVC) weakVC = currentVC;
        AUIPhotoPicker *picker = [[AUIPhotoPicker alloc] initWithMaxPickingCount:1 withAllowPickingImage:NO withAllowPickingVideo:YES withTimeRange:kCMTimeRangeZero];
        [picker onSelectionCompleted:^(AUIPhotoPicker * _Nonnull sender, NSArray<AUIPhotoPickerResult *> * _Nonnull results) {
            if (results.firstObject && results.firstObject.filePath.length > 0) {
                [sender dismissViewControllerAnimated:NO completion:^{
                    config.mixVideoFilePath = results.firstObject.filePath;
                    [self openRecorder:weakVC config:config enterEdit:enterEdit publishParam:publishParam];
                }];
            }
            else {
                [AVAlertController show:AUIUgsvGetString(@"选择的视频出错了或无权限") vc:sender];
            }
        } withOutputDir:[AUIUgsvPath cacheDir]];
        
        [currentVC av_presentFullScreenViewController:picker animated:YES completion:nil];
    }
    else {
        [self openRecorder:currentVC config:config enterEdit:enterEdit publishParam:publishParam];
    }
}

+ (void)openEditor:(UIViewController *)currentVC
             param:(AUIVideoOutputParam *)param
      publishParam:(AUIUgsvPublishParamInfo *)publishParam {
#ifdef USING_SVIDEO_BASIC
    [AVAlertController show:AUIUgsvGetString(@"当前SDK不支持")];
#else // USING_SVIDEO_BASIC
    if (!param) {
        param = [AUIVideoOutputParam Portrait720P];
    }
    if (!publishParam) {
        publishParam = [AUIUgsvPublishParamInfo new];
    }
    
    __weak typeof(currentVC) weakVC = currentVC;
    AUIPhotoPicker *picker = [[AUIPhotoPicker alloc] initWithMaxPickingCount:6 withAllowPickingImage:YES withAllowPickingVideo:YES withTimeRange:CMTimeRangeMake(CMTimeMake(100, 1000), CMTimeMake(3600*1000, 1000))];
    [picker onSelectionCompleted:^(AUIPhotoPicker * _Nonnull sender, NSArray<AUIPhotoPickerResult *> * _Nonnull results) {
        if (results.count > 0) {
            NSMutableArray<AliyunClip *> *clips = [NSMutableArray array];
            [results enumerateObjectsUsingBlock:^(AUIPhotoPickerResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (obj.filePath.length == 0) {
                    return;
                }
                if (obj.model.type == AUIPhotoAssetTypePhoto) {
                    AliyunClip *clip = [[AliyunClip alloc] initWithImagePath:obj.filePath duration:obj.model.assetDuration animDuration:0];
                    [clips addObject:clip];
                }
                else {
                    AliyunClip *clip = [[AliyunClip alloc] initWithVideoPath:obj.filePath animDuration:0];
                    [clips addObject:clip];
                }
            }];
            if (clips.count > 0) {
                [sender dismissViewControllerAnimated:NO completion:^{
                    AUIVideoEditor *editor = [[AUIVideoEditor alloc] initWithClips:clips withParam:param];
                    editor.saveToAlbumExportCompleted = publishParam.saveToAlbum;
                    editor.needToPublish = publishParam.needToPublish;
                    [weakVC.navigationController pushViewController:editor animated:YES];
                    
                }];
            }
            else {
                [AVAlertController show:AUIUgsvGetString(@"选择的视频出错了或无权限") vc:sender];
            }
        }
    } withOutputDir:[AUIUgsvPath cacheDir]];
    [currentVC av_presentFullScreenViewController:picker animated:YES completion:nil];
#endif
}

+ (void)openClipper:(UIViewController *)currentVC
              param:(AUIVideoOutputParam *)param
       publishParam:(AUIUgsvPublishParamInfo *)publishParam {
    if (!param) {
        param = [AUIVideoOutputParam Portrait720P];
    }
    if (!publishParam) {
        publishParam = [AUIUgsvPublishParamInfo new];
    }
    
    __weak typeof(currentVC) weakVC = currentVC;
    AUIPhotoPicker *picker = [[AUIPhotoPicker alloc] initWithMaxPickingCount:1 withAllowPickingImage:NO withAllowPickingVideo:YES withTimeRange:kCMTimeRangeZero];
    [picker onSelectionCompleted:^(AUIPhotoPicker * _Nonnull sender, NSArray<AUIPhotoPickerResult *> * _Nonnull results) {
        if (results.firstObject && results.firstObject.filePath.length > 0) {
            [sender dismissViewControllerAnimated:NO completion:^{
                AUIVideoCrop *crop = [[AUIVideoCrop alloc] initWithFilePath:results.firstObject.filePath withParam:param];
                crop.saveToAlbumExportCompleted = publishParam.saveToAlbum;
                crop.needToPublish = publishParam.needToPublish;
                [weakVC.navigationController pushViewController:crop animated:YES];
            }];
        }
        else {
            [AVAlertController show:AUIUgsvGetString(@"选择的视频出错了或无权限") vc:sender];
        }
    } withOutputDir:[AUIUgsvPath cacheDir]];
    
    [currentVC av_presentFullScreenViewController:picker animated:YES completion:nil];
}

+ (void)openTemplateList:(UIViewController *)currentVC {
#ifdef USING_SVIDEO_BASIC
    [AVAlertController show:AUIUgsvGetString(@"当前SDK不支持")];
#else // USING_SVIDEO_BASIC
    if (![AliyunAETemplateManager canSupport]) {
        [AVAlertController show:AUIUgsvGetString(@"当前机型不支持")];
        return;
    }
    AUIVideoTemplateListViewController *vc = [[AUIVideoTemplateListViewController alloc] init];
    [currentVC.navigationController pushViewController:vc animated:YES];
#endif
}

+ (void)openPickerToPublish:(UIViewController *)currentVC {
    __weak typeof(currentVC) weakVC = currentVC;
    AUIPhotoPicker *picker = [[AUIPhotoPicker alloc] initWithMaxPickingCount:1 withAllowPickingImage:NO withAllowPickingVideo:YES withTimeRange:kCMTimeRangeZero];
    [picker onSelectionCompleted:^(AUIPhotoPicker * _Nonnull sender, NSArray<AUIPhotoPickerResult *> * _Nonnull results) {
        if (results.firstObject) {
            [sender dismissViewControllerAnimated:NO completion:^{
                AUIPhotoPickerResult *result = results.firstObject;
                [self publish:weakVC filePath:result.filePath withThumbnailImage:result.model.thumbnailImage];
            }];
        }
    } withOutputDir:[AUIUgsvPath cacheDir]];
    
    [currentVC av_presentFullScreenViewController:picker animated:YES completion:nil];
}

+ (void)publish:(UIViewController *)currentVC filePath:(NSString *)filePath withThumbnailImage:(UIImage *)thumb  {
    __weak typeof(currentVC) weakVC = currentVC;
    AUIMediaPublisher *publisher = [[AUIMediaPublisher alloc] initWithVideoFilePath:filePath withThumbnailImage:thumb];
    publisher.onFinish = ^(UIViewController * _Nonnull current, NSError * _Nullable error, id  _Nullable product) {
        if (error) {
            [AVAlertController showWithTitle:AUIUgsvGetString(@"出错了") message:error.description needCancel:NO onCompleted:^(BOOL isCanced) {
                [current.navigationController popToViewController:weakVC animated:YES];
            }];
        }
        else {
            [AVAlertController showWithTitle:nil message:AUIUgsvGetString(@"发布成功了") needCancel:NO onCompleted:^(BOOL isCanced) {
                [current.navigationController popToViewController:weakVC animated:YES];
            }];
        }
    };
    [currentVC.navigationController pushViewController:publisher animated:YES];
}

@end

