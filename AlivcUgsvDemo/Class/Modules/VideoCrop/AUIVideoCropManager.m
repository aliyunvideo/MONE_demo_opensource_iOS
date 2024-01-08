//
//  AUIVideoCropManager.m
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/12/23.
//

#import "AUIVideoCropManager.h"
#import "AUIVideoCropExport.h"
#import "AlivcUgsvSDKHeader.h"
#import "AUIUgsvPath.h"
#import "AUIUgsvMacro.h"

@implementation AUIVideoCropManager

static AUIVideoCropExport *_cropExport = nil;

+ (void)startVideoCrop:(NSString *)videoFilePath
             startTime:(NSTimeInterval)startTime
               endTime:(NSTimeInterval)endTime
              cropRect:(CGRect)cropRect
                 param:(AUIVideoOutputParam *)param
              progress:(void (^)(float progress))progress
             completed:(void (^)(NSError *error, NSString *outputPath))completed {
    if (_cropExport) {
        if (completed) {
            completed([NSError errorWithDomain:@"" code:-1 userInfo:nil], nil);
        }
        return;
    }
    
    AUIVideoCropExport *cropExport = [[AUIVideoCropExport alloc] initWithVideoFilePath:videoFilePath startTime:startTime endTime:endTime cropRect:cropRect param:param];
//    cropExport.saveToAlbumExportCompleted = YES;
    cropExport.onMediaDoProgress = progress;
    cropExport.onMediaFinishProgress = ^(NSError * _Nullable error, id  _Nullable product) {
        _cropExport = nil;
        if (completed) {
            completed(error, product);
        }
    };
    [cropExport mediaStartProgress];
    _cropExport = cropExport;
}

+ (void)startPhotoCrop:(NSString *)imageFilePath
              cropRect:(CGRect)cropRect
            outputSize:(CGSize)outputSize
             completed:(void (^)(NSError * _Nullable error, NSString *outputPath))completed {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *originImage = [UIImage imageWithContentsOfFile:imageFilePath];
        AliyunImageCrop *imageCrop  = [[AliyunImageCrop alloc] init];
        imageCrop.originImage = originImage;
        imageCrop.outputSize = outputSize;
        imageCrop.cropRect = cropRect;
        imageCrop.cropMode = AliyunImageCropModeAspectCut;
        UIImage *outputImage = [imageCrop generateImage];
        NSData *imageData = UIImageJPEGRepresentation(outputImage, 0.8);
        NSString *path = [AUIUgsvPath exportFilePath:[[NSUUID UUID].UUIDString stringByAppendingString:@".jpg"]];
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        [imageData writeToFile:path atomically:YES];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completed) {
                completed(nil, path);
            }
        });
    });
}

+ (void)cropOnCutter:(AUIVideoCutterParam *)param cancelBlock:(void (^)(void))cancelBlock completedBlock:(void (^)(NSString *outputPath))completedBlock {
    AUIVideoCutter *cutter = [[AUIVideoCutter alloc] initWithParam:param completed:^BOOL(BOOL isCancel, AUIVideoCutterParam * _Nonnull param, AUIVideoCutterResult * _Nullable result, AUIVideoCutter *sender) {
        if (isCancel) {
            if (cancelBlock) {
                cancelBlock();
            }
            return YES;
        }
        if (!isCancel) {
            
            if (param.isImage) {
                AVProgressHUD *hud = [AVProgressHUD ShowHUDAddedTo:sender.view animated:YES];
                hud.labelText = AUIUgsvGetString(@"正在导出中...");
                [AUIVideoCropManager startPhotoCrop:param.inputPath cropRect:result.frame outputSize:param.outputAspectRatio completed:^(NSError * _Nullable error, NSString * _Nullable outputPath) {
                    [hud hideAnimated:YES];
                    if (error) {
                        [AVAlertController show:AUIUgsvGetString(@"导出失败了。。。") vc:sender];
                        return;
                    }
                    if (completedBlock) {
                        completedBlock(outputPath);
                    }
                    [sender dismissViewControllerAnimated:YES completion:nil];
                }];
            }
            else {
                AVCircularProgressView *progressView = [AVCircularProgressView presentOnView:sender.view message:AUIUgsvGetString(@"正在导出中...")];
                AUIVideoOutputParam *cropParam = [[AUIVideoOutputParam alloc] initWithOutputSize:param.outputAspectRatio];
                cropParam.scaleMode = AliyunScaleModeFit;
                [AUIVideoCropManager startVideoCrop:param.inputPath startTime:result.startTime endTime:result.startTime+param.outputDuration cropRect:result.frame param:cropParam progress:^(float progress) {
                    progressView.progress = progress;
                } completed:^(NSError * _Nullable error, NSString * _Nullable outputPath) {
                    [AVCircularProgressView dismiss:progressView];
                    if (error) {
                        [AVAlertController show:AUIUgsvGetString(@"导出失败了。。。") vc:sender];
                        return;
                    }
                    if (completedBlock) {
                        completedBlock(outputPath);
                    }
                    [sender dismissViewControllerAnimated:YES completion:nil];
                }];
            }
        }
        return NO;
    }];
    [UIViewController.av_topViewController av_presentFullScreenViewController:cutter animated:YES completion:nil];
}


@end
