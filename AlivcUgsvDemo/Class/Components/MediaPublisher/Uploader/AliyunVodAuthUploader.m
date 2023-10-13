//
//  AliyunVodAuthUploader.m
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/7/18.
//

#import "AliyunVodAuthUploader.h"
#import <VODUpload/VODUploadClient.h>


@interface AliyunVodAuthUploader ()

@property(nonatomic, strong) VODUploadClient *uploadClient;

@property(nonatomic, copy) NSString *vodUploadAuth;
@property(nonatomic, copy) NSString *vodUploadAddress;

@end


@implementation AliyunVodAuthUploader

- (void)dealloc {
    [_uploadClient clearFiles];
}

- (VODUploadClient *)uploadClient {
    if (!_uploadClient) {
        
        // weak items
        __weak typeof(self) weakSelf = self;

        OnUploadFinishedListener finishCallbackFunc = ^(UploadFileInfo *fileInfo, VodUploadResult *result) {
            [weakSelf.uploadCallback uploaderUploadSuccess:weakSelf];
        };

        OnUploadFailedListener failedCallbackFunc = ^(UploadFileInfo *fileInfo, NSString *code, NSString *message) {
            [weakSelf.uploadCallback uploader:weakSelf uploadFailedWithCode:[code intValue] message:message];
        };

        OnUploadProgressListener progressCallbackFunc = ^(UploadFileInfo *fileInfo, long uploadedSize, long totalSize) {
            [weakSelf.uploadCallback uploader:weakSelf uploadProgressWithUploadedSize:uploadedSize totalSize:totalSize];
        };

        OnUploadTokenExpiredListener tokenExpiredCallbackFunc = ^{
            [weakSelf.uploadCallback uploaderUploadTokenExpired:weakSelf];
        };

        OnUploadRertyListener retryCallbackFunc = ^{
            [weakSelf.uploadCallback uploaderUploadRetry:weakSelf];
        };

        OnUploadRertyResumeListener retryResumeCallbackFunc = ^{
            [weakSelf.uploadCallback uploaderUploadRetryResume:weakSelf];
        };

        OnUploadStartedListener startedCallbackFunc = ^(UploadFileInfo *fileInfo) {
            [weakSelf.uploadClient setUploadAuthAndAddress:fileInfo uploadAuth:weakSelf.vodUploadAuth uploadAddress:weakSelf.vodUploadAddress];
        };

        VODUploadListener *listener = [[VODUploadListener alloc] init];
        listener.finish = finishCallbackFunc;
        listener.failure = failedCallbackFunc;
        listener.progress = progressCallbackFunc;
        listener.expire = tokenExpiredCallbackFunc;
        listener.retry = retryCallbackFunc;
        listener.retryResume = retryResumeCallbackFunc;
        listener.started = startedCallbackFunc;
        
        _uploadClient = [VODUploadClient new];
        //_uploadClient.reportEnabled = YES;
        [_uploadClient setListener:listener];
    }
    return _uploadClient;
}

- (int)uploadWithMediaFilePath:(NSString *)mediaFilePath
                 uploadAddress:(NSString *)vodUploadAddress
                    uploadAuth:(NSString *)vodUploadAuth {
    _vodUploadAuth = vodUploadAuth;
    _vodUploadAddress = vodUploadAddress;
    _mediaFilePath = mediaFilePath;
    [self.uploadClient addFile:mediaFilePath vodInfo:nil];
    BOOL ret = [self.uploadClient start];
    if (!ret) {
        return ALIYUN_VOD_AUTH_UPLOADER_FAILED;
    }
    return 0;
}

- (int)pauseUpload {
    BOOL ret = [_uploadClient pause];
    if (!ret) {
        return ALIYUN_VOD_AUTH_UPLOADER_FAILED;
    }
    return 0;
}

- (int)resumeUpload {
    BOOL ret = [_uploadClient resume];
    if (!ret) {
        return ALIYUN_VOD_AUTH_UPLOADER_FAILED;
    }
    return 0;
}

- (int)cancelUpload {
    BOOL ret = [_uploadClient clearFiles];
    if (!ret) {
        return ALIYUN_VOD_AUTH_UPLOADER_FAILED;
    }
    return 0;
}

- (int)refreshWithUploadAuth:(NSString *)vodUploadAuth {
    _vodUploadAuth = vodUploadAuth;
    BOOL ret = [_uploadClient resumeWithAuth:vodUploadAuth];
    if (!ret) {
        return ALIYUN_VOD_AUTH_UPLOADER_FAILED;
    }
    return 0;
}

@end
