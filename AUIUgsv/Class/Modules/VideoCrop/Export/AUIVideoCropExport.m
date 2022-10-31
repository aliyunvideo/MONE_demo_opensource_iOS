//
//  AUIVideoCropExport.m
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/6/10.
//

#import "AUIVideoCropExport.h"
#import "AlivcUgsvSDKHeader.h"
#import "AUIUgsvPath.h"
#import "AUIPhotoLibraryManager.h"

@interface AUIVideoCropExport () <AliyunCropDelegate>

@property (nonatomic, strong) AliyunCrop *crop;
@property (nonatomic, copy) NSString *outputPath;

@end

@implementation AUIVideoCropExport

@synthesize onMediaDoProgress;
@synthesize onMediaFinishProgress;
@synthesize requestCoverImageBlock;

- (instancetype)initWithVideoFilePath:(NSString *)videoFilePath
                            startTime:(NSTimeInterval)startTime
                              endTime:(NSTimeInterval)endTime
                             cropRect:(CGRect)cropRect
                                param:(AUIVideoOutputParam *)param {
    self = [super init];
    if (self) {
        self.outputPath = [AUIUgsvPath exportFilePath:nil];
        self.crop = [[AliyunCrop alloc] initWithDelegate:self];
        self.crop.inputPath = videoFilePath;
        self.crop.outputPath = self.outputPath;
        self.crop.startTime = startTime;
        self.crop.endTime = endTime;
        if (param) {
            self.crop.outputSize = param.outputSize;
            if (CGRectEqualToRect(cropRect, CGRectZero)) {
                cropRect = CGRectMake(0, 0, param.outputSize.width, param.outputSize.height);
            }
            self.crop.rect = cropRect;
            self.crop.cropMode = [self cutMode:param.scaleMode];
            self.crop.fps = param.fps;
            self.crop.gop = param.gop;
            self.crop.videoQuality = param.videoQuality;
            self.crop.encodeMode = [self encodeMode:param.codecType];
            self.crop.bitrate = param.bitrate;
        }
        else {
            self.crop.shouldOptimize = YES;
        }
    }
    return self;
}

- (AliyunCropCutMode)cutMode:(AliyunScaleMode)scaleMode {
    if (scaleMode == AliyunScaleModeFill) {
        return AliyunCropCutModeScaleAspectFill;
    }
    return AliyunCropModeScaleAspectCut;
}

- (int)encodeMode:(AliyunVideoCodecType)type {
    if (type == AliyunVideoCodecOpenh264) {
        return 0;
    }
    return 1;
}

- (CGSize)coverImageSize {
    return self.crop.outputSize;
}

- (void)mediaStartProgress {
    int ret = [self.crop startCrop];
    if (ret != ALIVC_COMMON_RETURN_SUCCESS) {
        [self cropOnError:ret];
    }
}

- (void)mediaCancelProgress {
    [self.crop cancel];
}

#pragma mark - AliyunCropDelegate

- (void)cropTaskOnProgress:(float)progress {
    if (self.saveToAlbumExportCompleted) {
        progress = progress * 0.95;
    }
    NSLog(@"crop progress:%f", progress);
    if (self.onMediaDoProgress) {
        self.onMediaDoProgress(progress);
    }
}

- (void)cropOnError:(int)error {
    NSLog(@"crop error:%@", @(error));
    if (self.onMediaFinishProgress) {
        self.onMediaFinishProgress([NSError errorWithDomain:@"error.crop" code:error userInfo:nil], nil);
    }
}

- (void)cropTaskOnComplete {
    NSLog(@"crop completed");
    if (self.saveToAlbumExportCompleted) {
        [AUIPhotoLibraryManager saveVideoWithUrl:[NSURL fileURLWithPath:self.outputPath] location:nil completion:^(PHAsset * _Nonnull asset, NSError * _Nonnull error) {
            if (error) {
                NSLog(@"保存相册失败");
            }
            if (self.onMediaDoProgress) {
                self.onMediaDoProgress(1.0);
            }
            if (self.onMediaFinishProgress) {
                self.onMediaFinishProgress(nil, self.outputPath);
            }
        }];
    }
    else {
        if (self.onMediaFinishProgress) {
            self.onMediaFinishProgress(nil, self.outputPath);
        }
    }
}

- (void)cropTaskOnCancel {
    NSLog(@"crop cancel");
}

@end
