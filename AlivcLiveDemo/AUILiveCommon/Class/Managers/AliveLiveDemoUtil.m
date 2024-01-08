//
//  AliveLiveDemoUtil.m
//  AliLiveSdk-Demo
//
//  Created by ZhouGuixin on 2020/8/4.
//  Copyright © 2020 alilive. All rights reserved.
//

#import "AliveLiveDemoUtil.h"
#import <AVFoundation/AVCaptureDevice.h>
#import <CommonCrypto/CommonDigest.h>

static NSThread *g_queenRenderThread = nil;

NSThread *getGlobalRenderThread()
{
    if (!g_queenRenderThread)
    {
        g_queenRenderThread = [[NSThread alloc] initWithBlock:^{
            NSPort *renderThreadKeepAlivePort = [NSPort port];
            NSRunLoop *rl = [NSRunLoop currentRunLoop];
            [rl addPort:renderThreadKeepAlivePort forMode: NSRunLoopCommonModes];
            [rl run];
        }];
        g_queenRenderThread.name = @"com.alivc.globalRenderThread";
        [g_queenRenderThread start];
    }
    return g_queenRenderThread;
}

void dispatch_thread_sync(NSThread* thread, dispatch_block_t block)
{
    if ([NSThread currentThread] == thread)
    {
        block();
    }
    else
    {
        [(id)block performSelector:@selector(invoke) onThread:thread withObject:nil waitUntilDone:YES];
    }
}

@implementation AliveLiveDemoUtil

+ (UIViewController *)createSelectUrlSheet:(NSArray *)urlConfig callback:(void (^)(NSString *name, NSString *url))callback {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [urlConfig enumerateObjectsUsingBlock:^(NSArray *arr, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *name = arr[0];
        NSString *url = arr[1];
        UIAlertAction *action = [UIAlertAction actionWithTitle:name style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (callback) {
                callback(name, url);
            }
        }];
        [alertController addAction:action];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:AUILiveCommonString(@"取消") style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:cancelAction];
    return alertController;
}

+ (void)setupApperance {
    UIButton *btnApperance1 = [UIButton appearance];
    [AliveLiveDemoUtil setupButtonApperance:btnApperance1];
}

+ (void)setupButtonApperance:(UIButton *)btnApperance {
    btnApperance.titleLabel.font = [UIFont systemFontOfSize:14];
    [btnApperance setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btnApperance setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    UIImage *normalBg = [AliveLiveDemoUtil roundRectBorderImageWithColor:[UIColor whiteColor]];
    UIImage *hilightBg = [AliveLiveDemoUtil roundRectBorderImageWithColor:[UIColor colorWithWhite:0.8 alpha:1]];
    [btnApperance setBackgroundImage:normalBg forState:UIControlStateNormal];
    [btnApperance setBackgroundImage:hilightBg forState:UIControlStateHighlighted];
    btnApperance.layer.cornerRadius = 5.0f;
    [btnApperance.layer setMasksToBounds:YES];
}

+ (void)showToast:(NSString *)status {
    
    [AliveLiveDemoUtil showToastMessage:status];
}

+(void)showToastMessage:(NSString *)string{
    
    dispatch_async(dispatch_get_main_queue(), ^{
    
//        [[UIApplication sharedApplication].keyWindow.rootViewController.view makeToast:string duration:1.5 position:CSToastPositionCenter];
    });
}

+ (void)showErrorToast:(NSString *)status {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [AliveLiveDemoUtil showToastMessage:status];
        
    });
}

+ (void)showAlertWithTitle:(NSString *)title message:(NSString *)message confirmBlock:(void (^)(void))confirmBlock cancelBlock:(void (^)(void))cancelBlock {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:AUILiveCommonString(@"取消") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            if (cancelBlock) {
                cancelBlock();
            }
        }];
        UIAlertAction *otherAction = [UIAlertAction actionWithTitle:AUILiveCommonString(@"确定") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            if (confirmBlock) {
                confirmBlock();
            }
        }];
        [alertController addAction:cancelAction];
        [alertController addAction:otherAction];
        if ([UIApplication sharedApplication].keyWindow.rootViewController.presentedViewController != nil) {
            [[UIApplication sharedApplication].keyWindow.rootViewController dismissViewControllerAnimated:NO completion:^{
                
            }];
        }
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:^{
        }];
    });
}

+ (void)showTextInputAlert:(NSString *)title confirmBlock:(void (^)(NSString *string))confirmBlock {
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:
UIAlertControllerStyleAlert];
    [alertVc addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
    }];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:AUILiveCommonString(@"确定") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        NSString *string = [[alertVc textFields] objectAtIndex:0].text;
        if (confirmBlock) {
            confirmBlock(string);
        }
    }];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:AUILiveCommonString(@"取消") style:UIAlertActionStyleCancel handler:nil];
    [alertVc addAction:action2];
    [alertVc addAction:action1];
    if ([UIApplication sharedApplication].keyWindow.rootViewController.presentedViewController != nil) {
        [[UIApplication sharedApplication].keyWindow.rootViewController dismissViewControllerAnimated:NO completion:^{
        }];
    }
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertVc animated:YES completion:^{
    }];
}

static NSMutableDictionary *colorImageCache = nil;

+ (UIImage *)roundRectBorderImageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 20.0f, 20.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [[UIColor whiteColor] CGColor]);
    // 外层的圆
    [[UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:5] addClip];
    CGContextSetFillColorWithColor(context, [[UIColor lightGrayColor] CGColor]);
    CGContextFillRect(context, rect);
    // 内层的圆
    CGRect rect1 = CGRectMake(1.0f, 1.0f, 18.0f, 18.0f);
    [[UIBezierPath bezierPathWithRoundedRect:rect1 cornerRadius:4] addClip];
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect1);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImage *image1 = [image stretchableImageWithLeftCapWidth:image.size.width * 0.5 topCapHeight:image.size.height * 0.5];
    return image1;
}

+ (UIImage *)roundRectImageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 20.0f, 20.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [[UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:5] addClip];
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImage *image1 = [image stretchableImageWithLeftCapWidth:image.size.width * 0.5 topCapHeight:image.size.height * 0.5];
    return image1;
}

+ (BOOL)getEssentialRights {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        }];
        return NO;
    } else if (authStatus == AVAuthorizationStatusDenied || authStatus == AVAuthorizationStatusRestricted) {
        [AliveLiveDemoUtil showAlertWithTitle:AUILiveCommonString(@"提示") message:AUILiveCommonString(@"需要相机权限以开启直播功能") confirmBlock:^{
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        } cancelBlock:^{
            
        }];
        return NO;
    }
    
    authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if (authStatus == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
        }];
        return NO;
    } else if (authStatus == AVAuthorizationStatusDenied || authStatus == AVAuthorizationStatusRestricted) {
        [AliveLiveDemoUtil showAlertWithTitle:AUILiveCommonString(@"提示") message:AUILiveCommonString(@"需要麦克风权限以开启直播功能") confirmBlock:^{
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        } cancelBlock:^{
            
        }];
        return NO;
    }
    
    return YES;
}

+ (void)forceTestNetwork {
    NSURL *url = [NSURL URLWithString:@"https://www.taobao.com"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error == nil) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            NSLog(@"%@",dict);
        }
    }];
    [dataTask resume];
}

//将日志写入沙盒mylog.log文件中
+(void)writeLogMessageToLocationFile:(NSString *)logMessagesString isCover:(BOOL)isCover{
        
    // NSDocumentDirectory 要查找的文件
    // NSUserDomainMask 代表从用户文件夹下找
    // 在iOS中，只有一个目录跟传入的参数匹配，所以这个集合里面只有一个元素
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSString *loggingPath = [documentsPath stringByAppendingPathComponent:@"/playerlog.log"];
    //NSLog(@"%@",loggingPath);
    
    //覆盖文件的原先内容
    if(isCover == YES) {
        [logMessagesString writeToFile:loggingPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        
    }
    else {
        NSFileManager *fileManger = [NSFileManager defaultManager];
        if (![fileManger fileExistsAtPath:loggingPath]) {
            [logMessagesString writeToFile:loggingPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        }
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:loggingPath];
        [fileHandle seekToEndOfFile];  //将节点跳到文件的末尾
        
        NSData* stringData  = [logMessagesString dataUsingEncoding:NSUTF8StringEncoding];
        
        [fileHandle writeData:stringData]; //追加写入数据
        
        [fileHandle closeFile];
        
    }

}

#pragma mark -- 下载远程资源文件
+ (NSString *)getExternalStreamResourceSavePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSString *savePath = [documentsPath stringByAppendingPathComponent:@"capture.yuv"];
    return savePath;
}

+ (BOOL)haveExternalStreamResourceSavePath {
    NSString *savePath = [AliveLiveDemoUtil getExternalStreamResourceSavePath];
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:savePath]) {
        return YES;
    } else {
        return NO;
    }
}

+ (NSString *)getRequestExternalStreamResourceURL {
    return @"https://alivc-demo-cms.alicdn.com/versionProduct/resources/livePush/capture0.yuv";
}

+ (void)requestExternalStreamResourceWithCompletion:(void(^)(BOOL success, NSString *errMsg))completion {
    NSString *savePath = [AliveLiveDemoUtil getExternalStreamResourceSavePath];
    
    if ([AliveLiveDemoUtil haveExternalStreamResourceSavePath]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(YES, nil);
            }
        });
        return;
    }

    NSURL *saveURL = [NSURL fileURLWithPath:savePath];
    NSURL *requestURL = [NSURL URLWithString:[AliveLiveDemoUtil getRequestExternalStreamResourceURL]];
    NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:requestURL];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error && location) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            NSString *response_md5 = nil;
            for (NSString *field in httpResponse.allHeaderFields.allKeys) {
                if ([field.lowercaseString isEqualToString:@"etag"]) {
                    response_md5 = [httpResponse.allHeaderFields objectForKey:field];
                    response_md5 = [response_md5 stringByReplacingOccurrencesOfString:@"\"" withString:@""].lowercaseString;
                    break;
                }
            }
            if (!response_md5 || response_md5.length == 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completion) {
                        completion(NO, AUILiveCommonString(@"下载外部音视频文件失败"));
                    }
                });
                return;
            }
            
            NSFileManager *manager = [NSFileManager defaultManager];
            [manager moveItemAtURL:location toURL:saveURL error:nil];
    
            NSString *fileCheck_md5 = [AliveLiveDemoUtil calculateFileMd5WithFilePath:savePath];
            if (![response_md5 isEqualToString:fileCheck_md5]) {
                [manager removeItemAtURL:saveURL error:nil];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completion) {
                        completion(NO, AUILiveCommonString(@"下载外部音视频文件失败"));
                    }
                });
                return;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) {
                    completion(YES, nil);
                }
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) {
                    completion(NO, AUILiveCommonString(@"下载外部音视频文件失败"));
                }
            });
        }
    }];

    [task resume];
}

+ (NSString *)calculateFileMd5WithFilePath:(NSString *)filePath {
    //生成文件的MD5   校验的是压缩包的MD5  判断下载是否正确
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:filePath];
    if( handle == nil ) {
        NSLog(@"文件出错");
        return @"";
    }
    
    CC_MD5_CTX md5;
    CC_MD5_Init(&md5);
    BOOL done = NO;
    while(!done)
    {
        NSData* fileData = [handle readDataOfLength: 256 ];
        CC_MD5_Update(&md5, [fileData bytes], [fileData length]);
        if( [fileData length] == 0 ) done = YES;
    }
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(digest, &md5);
    NSString *fileMD5 = [NSString stringWithFormat: @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                    digest[0], digest[1],
                    digest[2], digest[3],
                    digest[4], digest[5],
                    digest[6], digest[7],
                    digest[8], digest[9],
                    digest[10], digest[11],
                    digest[12], digest[13],
                    digest[14], digest[15]];
    return fileMD5.lowercaseString;
}

+ (BOOL)isLocalZHLanguage {
    NSString *currentLanguageCode = [NSLocale preferredLanguages].firstObject;
    if ([currentLanguageCode hasPrefix:@"zh"]) {
        return YES;
    } else {
        return NO;
    }
}

@end
