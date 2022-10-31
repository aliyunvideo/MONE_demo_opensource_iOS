//
//  AUIMediaPublisherProgress.m
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/6/13.
//

#import "AUIMediaPublisherProgress.h"
#import "AUIFoundation.h"
#import "AVAsset+UgsvHelper.h"
#import "AliyunVodAuthUploader.h"

#import "AUIMediaTokenService.h"

typedef NS_ENUM(NSUInteger, AUIMediaPublisherProgressStep) {
    AUIMediaPublisherProgressStepInit = 0,
    AUIMediaPublisherProgressStepExport,
    AUIMediaPublisherProgressStepUploadCover,
    AUIMediaPublisherProgressStepUploadVideo,
    AUIMediaPublisherProgressStepCompleted
};

@interface AUIMediaPublisherProgress () <AliyunVodAuthUploaderCallback>

@property (nonatomic, strong) AUIMediaPublisherRequestInfo *requestInfo;
@property (nonatomic, strong) id<AUIMediaProgressProtocol> exprotProgress;

@property (nonatomic, strong) AliyunVodAuthUploader *coverUploader;
@property (nonatomic, strong) AliyunVodAuthUploader *videoUploader;
@property (nonatomic, strong) AUIMediaPublisherResponseInfo *responseInfo;

@property (nonatomic, assign) AUIMediaPublisherProgressStep currentStep;
@property (nonatomic, assign) BOOL needExport;
@property (nonatomic, assign) BOOL needUploadCover;
@property (nonatomic, assign) BOOL needUploadVideo;
@property (nonatomic, copy) NSArray *progressSegment;


@end

@implementation AUIMediaPublisherProgress

@synthesize onMediaDoProgress;
@synthesize onMediaFinishProgress;
@synthesize requestCoverImageBlock;

- (instancetype)initWithRequestInfo:(nonnull AUIMediaPublisherRequestInfo *)requestInfo {
    self = [super init];
    if (self) {
        _currentStep = AUIMediaPublisherProgressStepInit;
        _responseInfo = [AUIMediaPublisherResponseInfo new];
        
        _requestInfo = requestInfo;
        self.requestCoverImageBlock = ^(void (^ _Nonnull completedBlock)(UIImage * _Nonnull)) {
            if (completedBlock) {
                completedBlock([UIImage imageWithContentsOfFile:requestInfo.coverImagePath]);
            }
        };
        
        _coverUploader = [[AliyunVodAuthUploader alloc] init];
        _coverUploader.uploadCallback = self;
        _videoUploader = [[AliyunVodAuthUploader alloc] init];
        _videoUploader.uploadCallback = self;
    }
    return self;
}

- (instancetype)initWithExportProgress:(id<AUIMediaProgressProtocol>)exportProgress withPublishRequestInfo:(nonnull AUIMediaPublisherRequestInfo *)requestInfo {
    self = [self initWithRequestInfo:requestInfo];
    if (self) {
        __weak typeof(self) weakSelf = self;
        _exprotProgress = exportProgress;
        if ([_exprotProgress respondsToSelector:@selector(setOnMediaFinishProgress:)]) {
            [_exprotProgress setOnMediaFinishProgress:^(NSError * _Nonnull error, id _Nonnull product) {
                [weakSelf onExportFinish:product error:error];
            }];
        }
        if ([_exprotProgress respondsToSelector:@selector(setOnMediaDoProgress:)]) {
            [_exprotProgress setOnMediaDoProgress:^(float progress) {
                [weakSelf onExportProgress:progress];
            }];
        }
    }
    return self;
}

- (CGSize)coverImageSize {
    if (self.exprotProgress) {
        return [self.exprotProgress coverImageSize];
    }
    
    if (self.requestInfo.videoFilePath.length > 0) {
        AVAsset *asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:self.requestInfo.videoFilePath]];
        return asset.ugsv_getResolution;
    }
    
    return CGSizeZero;
}

- (void)mediaCancelProgress {
    if (self.currentStep == AUIMediaPublisherProgressStepExport) {
        [self cancelExport];
    }
    else if (self.currentStep == AUIMediaPublisherProgressStepUploadCover || self.currentStep == AUIMediaPublisherProgressStepUploadVideo) {
        [self cancelUpload];
    }
}

/*
 1. export then generate a new media file
 2. upload cover file if need
 3. updload video file
 */
- (void)mediaStartProgress {
    self.needExport = self.exprotProgress != nil;
    self.needUploadVideo = self.requestInfo.videoFilePath.length > 0 || self.needExport;
    self.needUploadCover = self.requestInfo.coverImagePath.length > 0 && self.needUploadVideo;
    
    if (!self.needUploadVideo) {
        return;
    }
    [self updateProgressSegment];
    
    [self startExport];
}

- (void)onFinalFinish:(id)product error:(NSError *)error {
    if (self.onMediaFinishProgress) {
        self.onMediaFinishProgress(error, product);
    }
}

- (void)onFinalProgress:(float)subProgress {
    
    NSInteger currentIndex = self.currentStep - AUIMediaPublisherProgressStepExport;
    __block float finalProgress = 0;
    [self.progressSegment enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx < currentIndex) {
            finalProgress += [obj floatValue];
        }
        else if (idx == currentIndex) {
            finalProgress += [obj floatValue] * subProgress;
        }
    }];
    NSLog(@"final progress:%f", finalProgress);
    if (self.onMediaDoProgress) {
        self.onMediaDoProgress(finalProgress);
    }
}

- (void)updateProgressSegment {
    NSInteger key = 0;
    if (self.needExport) {
        key = key | 0x100;
    }
    if (self.needUploadCover) {
        key = key | 0x010;
    }
    if (self.needUploadVideo) {
        key = key | 0x001;
    }
    self.progressSegment = [[self.class progressSegmentMap] objectForKey:@(key)];
}

+ (NSDictionary *)progressSegmentMap {
    
    return @{
        @(0x111):@[@(0.5),@(0.1),@(0.4)],
        @(0x011):@[@(0.0),@(0.2),@(0.8)],
        @(0x001):@[@(0.0),@(0.0),@(1.0)],
        @(0x101):@[@(0.5),@(0.0),@(0.5)],
    };
}

#pragma mark - Export

- (void)startExport {
    self.currentStep = AUIMediaPublisherProgressStepExport;
    if (self.needExport) {
        [self.exprotProgress mediaStartProgress];
    }
    else {
        [self startUploadCover];
    }
}

- (void)cancelExport {
    [self.exprotProgress mediaCancelProgress];
}

- (void)onExportProgress:(float)progress {
    [self onFinalProgress:progress];
}

- (void)onExportFinish:(id)product error:(NSError *)error {
    
    if (product) {
        [self onFinalProgress:1.0];
        NSString *filePath = (NSString *)product;
        if ([filePath isKindOfClass:NSString.class]) {
            self.requestInfo.videoFilePath = filePath;
            [self startUploadCover];
            return;
        }
    }
    if (!error) {
        error = [NSError errorWithDomain:@"error.publisher" code:-1 userInfo:@{}];
    }
    [self onFinalFinish:nil error:error];
}

#pragma mark - Upload

- (void)startUploadCover
{
    self.currentStep = AUIMediaPublisherProgressStepUploadCover;
    if (self.needUploadCover) {
        [AUIMediaTokenService getImageUploadAuthWithToken:nil title:@"DefaultTitle" filePath:self.requestInfo.coverImagePath tags:@"DefaultTags" handler:^(NSString * _Nullable uploadAddress, NSString * _Nullable uploadAuth, NSString * _Nullable imageURL, NSString * _Nullable imageId, NSError * _Nullable error) {
            if (error) {
                [self onFinalFinish:nil error:error];
                return;
            }
            self.responseInfo.coverImageURL = imageURL;
            [self.coverUploader uploadWithMediaFilePath:self.requestInfo.coverImagePath uploadAddress:uploadAddress uploadAuth:uploadAuth];
        }];
    }
    else {
        [self startUploadVideo];
    }
}

- (void)startUploadVideo
{
    self.currentStep = AUIMediaPublisherProgressStepUploadVideo;
    if (self.needUploadVideo) {
        [AUIMediaTokenService getVideoUploadAuthWithWithToken:nil title:@"DefaultTitle" filePath:self.requestInfo.videoFilePath coverURL:self.responseInfo.coverImageURL desc:self.requestInfo.desc tags:@"DefaultTags" handler:^(NSString * _Nullable uploadAddress, NSString * _Nullable uploadAuth, NSString * _Nullable videoId, NSError * _Nullable error) {
            if (error) {
                [self onFinalFinish:nil error:error];
                return;
            }
            self.responseInfo.videoId = videoId;
            [self.videoUploader uploadWithMediaFilePath:self.requestInfo.videoFilePath uploadAddress:uploadAddress uploadAuth:uploadAuth];
        }];
    }
    else {
        self.currentStep = AUIMediaPublisherProgressStepCompleted;
    }
}
    
- (void)refreshUploadVideoToken
{
    [AUIMediaTokenService refreshVideoUploadAuthWithToken:nil videoId:self.responseInfo.videoId handler:^(NSString * _Nullable uploadAddress, NSString * _Nullable uploadAuth, NSError * _Nullable error) {
        if (error) {
            [self onFinalFinish:nil error:error];
            return;
        }
        [self.videoUploader refreshWithUploadAuth:uploadAuth];
    }];
}

- (void)cancelUpload {
    if (self.currentStep == AUIMediaPublisherProgressStepUploadCover) {
        [self.coverUploader cancelUpload];
    }
    else if (self.currentStep == AUIMediaPublisherProgressStepUploadVideo) {
        [self.videoUploader cancelUpload];
    }
}

#pragma mark - AliyunIVodUploadCallback

- (void)uploaderUploadSuccess:(AliyunVodAuthUploader *)uploader {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (uploader == self.coverUploader) {
            NSLog(@"upload cover image success");
            [self onFinalProgress:1.0];
            [self startUploadVideo];
        }
        else {
            NSLog(@"upload video file success");
            [self onFinalProgress:1.0];
            self.currentStep = AUIMediaPublisherProgressStepCompleted;
            [self onFinalFinish:self.responseInfo error:nil];
        }
    });
}

- (void)uploader:(AliyunVodAuthUploader *)uploader uploadFailedWithCode:(int)code message:(NSString *)message {
    NSLog(@"upload failed code:%d, message:%@", code, message);
    dispatch_async(dispatch_get_main_queue(), ^{
        NSError *error = [NSError errorWithDomain:@"error.publisher" code:-2 userInfo:@{@"code":@(code), @"message":message ?: @""}];
        [self onFinalFinish:nil error:error];
    });
}

- (void)uploader:(AliyunVodAuthUploader *)uploader uploadProgressWithUploadedSize:(long long)uploadedSize totalSize:(long long)totalSize {
    
    NSLog(@"uploadType:%@ uploadSize:%lld, totalSize:%lld", uploader == self.videoUploader ? @"Video" : @"Image", uploadedSize, totalSize);
    dispatch_async(dispatch_get_main_queue(), ^{
        if (totalSize) {
             CGFloat progressValue = uploadedSize / (double)totalSize;
            [self onFinalProgress:progressValue];
        }
    });
}

- (void)uploaderUploadTokenExpired:(AliyunVodAuthUploader *)uploader {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (uploader == self.coverUploader) {
            [self startUploadCover];
        }
        else {
            if (self.responseInfo.videoId) {
                [self refreshUploadVideoToken];
            }
            else{
                [self startUploadVideo];
            }
        }
    });
}

@end
