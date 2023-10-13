//
//  AUIVideoTemplateResouce.m
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/12/14.
//

#import "AUIVideoTemplateResouce.h"
#import "AUIFoundation.h"
#import <AFNetworking/AFNetworking.h>
#import <ZipArchive/ZipArchive.h>

@implementation AUIVideoTemplateResouce


+ (void)checkResouce:(AUIVideoTemplateItem *)item onVC:(UIViewController *)onVC completed:(void(^)(NSString *templatePath))completed {
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"Template.bundle" ofType:nil];
    
    // 处理内置模板
    NSString *templatePath = [bundlePath stringByAppendingPathComponent:item.name];
    if ([[NSFileManager defaultManager] fileExistsAtPath:templatePath]) {
        completed(templatePath);
        return;
    }
    
    // 查找本地存储模板
    templatePath = [[self.class resourceDownloadPath] stringByAppendingPathComponent:[item.name av_MD5]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:templatePath]) {
        completed(templatePath);
        return;
    }
    
    // 从本地zip模板进行解压到本地存储路径
    if (![item.zip hasPrefix:@"http"]) {
        NSString *templateZip = [bundlePath stringByAppendingPathComponent:item.zip];
        if ([self.class unZipFrom:templateZip to:templatePath removeAfterSuccess:NO]) {
            completed(templatePath);
        }
        return;
    }
    
    // 从云端下载并解压到本地存储路径
    AVCircularProgressView *progressView = [AVCircularProgressView presentOnView:onVC.view message:@"下载资源中..."];
    [self downloadWithUrl:item.zip progress:^(CGFloat progress) {
        progressView.progress = progress;
    } completion:^(NSString *path) {
        [AVCircularProgressView dismiss:progressView];
        if (path.length >0 && [self.class unZipFrom:path to:templatePath removeAfterSuccess:YES]) {
            completed(templatePath);
        }
        else {
            [AVAlertController show:@"资源出错了！" vc:onVC];
        }
    }];
}

+ (AFURLSessionManager *)manager {
    static AFURLSessionManager *_urlManager = nil;
    if (!_urlManager) {
        _urlManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:NSURLSessionConfiguration.defaultSessionConfiguration];
    }
    return _urlManager;
}

+ (NSString *)rootPath {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"com.aliyun.video"];
}

// Documents/com.aliyun.video/template_download
+ (NSString *)resourceDownloadPath {
    return [[self rootPath] stringByAppendingPathComponent:@"template_download"];
}

+ (void)downloadWithUrl:(NSString *)urlString progress:(void(^)(CGFloat progress))progress completion:(void(^)(NSString *path))completion {

    if (urlString.length == 0) {
        if (completion) {
            completion(nil);
        }
        return;
    }

    NSFileManager *myFileManager = [NSFileManager defaultManager];
    NSString *dir = [self resourceDownloadPath];
    if (![myFileManager fileExistsAtPath:dir]) {
        [myFileManager createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *fileNamePre = [urlString av_MD5];
    NSArray *paths = [myFileManager contentsOfDirectoryAtPath:dir error:nil];
    for (NSString *path in paths) {
        if ([path hasPrefix:fileNamePre]) {
            if (completion) {
                completion([dir stringByAppendingPathComponent:path]);
            }
            return;
        }
    }
    
    NSURL *url = [NSURL URLWithString:urlString];
    if (!url) {
        if (completion) {
            completion(nil);
        }
        return;
    }

    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    NSURLSessionDownloadTask *task = [self.manager downloadTaskWithRequest:req progress:^(NSProgress * _Nonnull downloadProgress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (progress) {
                progress(downloadProgress.completedUnitCount * 1.0 / downloadProgress.totalUnitCount);
            }
        });
        
    } destination:^NSURL * (NSURL *targetPath, NSURLResponse *response) {
        NSString *path = [[self resourceDownloadPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@", fileNamePre, response.suggestedFilename]];
        return [NSURL fileURLWithPath:path];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        NSString *path = filePath.path;
        if ([path hasPrefix:@"file://"]) {
            path = [path substringFromIndex:@"file://".length];
        }
        completion(path);
    }];
    [task resume];
}

+ (BOOL)unZipFrom:(NSString *)filePath to:(NSString *)toDestination removeAfterSuccess:(BOOL)removed {
    
    ZipArchive *_zipArchive = [[ZipArchive alloc] init];
    [_zipArchive UnzipOpenFile:filePath];
    BOOL isSuccess = [_zipArchive UnzipFileTo:toDestination overWrite:YES];
    [_zipArchive UnzipCloseFile];

    // 解压失败
    if (!isSuccess) {
        return NO;
    }
    
    // 移除压缩包
    if (removed && [[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
    return YES;
}

@end
