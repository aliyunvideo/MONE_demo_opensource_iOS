//
//  AliyunVodAuthUploader.h
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/7/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class AliyunVodAuthUploader;

@protocol AliyunVodAuthUploaderCallback <NSObject>

- (void)uploaderUploadSuccess:(AliyunVodAuthUploader *)uploader;

- (void)uploader:(AliyunVodAuthUploader *)uploader uploadFailedWithCode:(int)code message:(NSString *)message;

- (void)uploader:(AliyunVodAuthUploader *)uploader uploadProgressWithUploadedSize:(long long)uploadedSize totalSize:(long long)totalSize;

- (void)uploaderUploadTokenExpired:(AliyunVodAuthUploader *)uploader;

@optional

- (void)uploaderUploadRetry:(AliyunVodAuthUploader *)uploader;

- (void)uploaderUploadRetryResume:(AliyunVodAuthUploader *)uploader;

@end

#define ALIYUN_VOD_AUTH_UPLOADER_FAILED -20012001


@interface AliyunVodAuthUploader : NSObject

@property (nonatomic, weak) id<AliyunVodAuthUploaderCallback> uploadCallback;

@property (nonatomic, readonly) NSString *mediaFilePath;


- (int)uploadWithMediaFilePath:(NSString *)mediaFilePath
                 uploadAddress:(NSString *)vodUploadAddress
                    uploadAuth:(NSString *)vodUploadAuth;

- (int)pauseUpload;
- (int)resumeUpload;
- (int)cancelUpload;
- (int)refreshWithUploadAuth:(NSString *)vodUploadAuth;

@end

NS_ASSUME_NONNULL_END
