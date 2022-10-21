//
//  AUIMediaTokenService.m
//  qusdk
//
//  Created by Worthy Zhang on 2019/1/2.
//  Copyright © 2019 Alibaba Group Holding Limited. All rights reserved.
//

#import "AUIMediaTokenService.h"

#warning 尊敬的客户，AUIMediaTokenService使用的域名及接口只用于demo演示使用，在集成到APP时请搭建自己的Server服务，此次仅供参考。如何集成自己的Server服务详见文档：https://help.aliyun.com/document_detail/108783.html?spm=a2c4g.11186623.6.1075.a70a3a4895Qysq。

static NSString * const kAlivcMediaServiceDomainString =  @"https://alivc-demo.aliyuncs.com";

@implementation AUIMediaTokenService

+ (void)getImageUploadAuthWithToken:(NSString *)tokenString title:(NSString *)title filePath:(NSString *)filePath tags:(NSString *)tags handler:(void (^)(NSString * _Nullable, NSString * _Nullable, NSString * _Nullable, NSString * _Nullable, NSError * _Nullable))handler{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:@{
                                       @"imageType":@"cover",
                                       @"imageExt":filePath.lastPathComponent.pathExtension
                                       }];
    if (title) {
        [params addEntriesFromDictionary:@{@"title":title}];
    }
    if (tags) {
        [params addEntriesFromDictionary:@{@"tags":tags}];
    }
    
    NSString *getUrl = @"/demo/getImageUploadAuth";
    if (tokenString) {
        [params addEntriesFromDictionary:@{@"token":tokenString}];
    }
 
    [self getWithPath:getUrl params:params completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            handler(nil, nil, nil, nil, error);
        }
        else {
            NSString *uploadAddress = [responseObject objectForKey:@"uploadAddress"];
            NSString *uploadAuth = [responseObject objectForKey:@"uploadAuth"];
            NSString *imageURL = [responseObject objectForKey:@"imageURL"];
            NSString *imageId = [responseObject objectForKey:@"imageId"];
            handler(uploadAddress, uploadAuth, imageURL, imageId, nil);
        }
    }];
}

+ (void)getVideoUploadAuthWithWithToken:(NSString *)tokenString title:(NSString *)title filePath:(NSString *)filePath coverURL:(NSString *)coverURL desc:(NSString *)desc tags:(NSString *)tags handler:(void (^)(NSString * _Nullable, NSString * _Nullable, NSString * _Nullable, NSError * _Nullable))handler{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:@{
                                       @"title":title,
                                       @"fileName":filePath.lastPathComponent
                                       }];
    if (coverURL) {
        [params addEntriesFromDictionary:@{@"coverURL":coverURL}];
    }
    if (desc) {
        [params addEntriesFromDictionary:@{@"description":desc}];
    }
    if (tags) {
        [params addEntriesFromDictionary:@{@"tags":tags}];
    }
   
    NSString *getUrl = @"/demo/getVideoUploadAuth";
    if (tokenString) {
        [params addEntriesFromDictionary:@{@"token":tokenString}];
    }
    
    [self getWithPath:getUrl params:params completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            handler(nil, nil, nil, error);
        }
        else {
            NSString *uploadAddress = [responseObject objectForKey:@"uploadAddress"];
            NSString *uploadAuth = [responseObject objectForKey:@"uploadAuth"];
            NSString *videoId = [responseObject objectForKey:@"videoId"];
            handler(uploadAddress, uploadAuth, videoId, nil);
        }
    }];
}


+ (void)refreshVideoUploadAuthWithToken:(NSString *)tokenString videoId:(NSString *)videoId handler:(void (^)(NSString * _Nullable, NSString * _Nullable, NSError * _Nullable))handler{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (videoId) {
        [params addEntriesFromDictionary:@{@"videoId":videoId}];
    }
    
    NSString *getUrl = @"/demo/refreshVideoUploadAuth";
    if (tokenString) {
        [params addEntriesFromDictionary:@{@"token":tokenString}];
    }
    [self getWithPath:getUrl params:params completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            handler(nil, nil, error);
        }
        else {
            NSString *uploadAddress = [responseObject objectForKey:@"uploadAddress"];
            NSString *uploadAuth = [responseObject objectForKey:@"uploadAuth"];
            handler(uploadAddress, uploadAuth, nil);
        }
    }];
}

#pragma mark - Private Method

+ (void)getWithPath:(NSString *)path params:(NSDictionary *)params completionHandler:(void (^)(NSURLResponse *response, id responseObject,  NSError * error))completionHandler {
    NSMutableDictionary *mutableParaDic = [[NSMutableDictionary alloc]initWithDictionary:params];
    
    NSString *paramsString = [self getParamsString:mutableParaDic];
    NSString *urlString = [NSString
                    stringWithFormat:@"%@%@?%@", kAlivcMediaServiceDomainString, path, paramsString];
    
    NSURLSessionConfiguration *sessionConfiguration =
    [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSURLSession *session =
    [NSURLSession sessionWithConfiguration:sessionConfiguration];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest addValue:@"application/json"
      forHTTPHeaderField:@"Content-Type"];
    [urlRequest addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    NSDictionary *appInfo = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Name = [appInfo objectForKey:@"CFBundleDisplayName"];
    NSString *app_Version = [appInfo objectForKey:@"CFBundleShortVersionString"];
    app_Version = [app_Version stringByReplacingOccurrencesOfString:@"." withString:@""];
    NSString *bundleId =[NSBundle mainBundle].bundleIdentifier;
    
    [urlRequest setValue:app_Name forHTTPHeaderField:@"appName"];
    [urlRequest setValue:app_Version forHTTPHeaderField:@"appVersionCode"];
    [urlRequest setValue:bundleId forHTTPHeaderField:@"bundleId"];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:urlRequest
                                            completionHandler:^(NSData *_Nullable data, NSURLResponse *_Nullable response, NSError *_Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (error) {
                if (completionHandler) {
                    completionHandler(response, nil, error);
                }
                return;
            }
            
            if (data == nil) {
                NSError *emptyError = [[NSError alloc] initWithDomain:@"AUIMediaTokenService" code:-10000 userInfo:nil];
                if (completionHandler) {
                    completionHandler(response, nil, emptyError);
                }
                return;
            }
            
            NSError *jsonError = nil;
            id jsonObj = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
            if (jsonError) {
                completionHandler(response, nil, jsonError);
                return;
            }
            
            NSInteger code = [[jsonObj objectForKey:@"code"] integerValue];
            if (code != 200) {
                NSError *retError = [NSError errorWithDomain:@"AUIMediaTokenService" code:code userInfo:jsonObj];
                if (completionHandler) {
                    completionHandler(response, nil, retError);
                }
                return;
            }
            
            if (completionHandler) {
                completionHandler(response, [jsonObj objectForKey:@"data"], nil);
            }
        });
    }];
    
    [task resume];
}


+ (NSString *)getParamsString:(NSDictionary *)params {
    NSMutableArray *parts = [NSMutableArray array];
    for (id key in params.allKeys) {
        id value = [params objectForKey:key];
        NSString *part = [NSString stringWithFormat:@"%@=%@", [self percentEncode:key], [self percentEncode:value]];
        [parts addObject: part];
    }
    
    NSArray<NSString *> *sortedArray = [parts sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    NSString *string = [sortedArray componentsJoinedByString:@"&"];
    return string;
}

+ (NSString *)percentEncode:(id)object {
    NSString *string = [NSString stringWithFormat:@"%@", object];
    
    NSString * const kAFCharactersGeneralDelimitersToEncode = @":#[]@?/"; // does not include "?" or "/" due to RFC 3986 - Section 3.4
    NSString * const kAFCharactersSubDelimitersToEncode = @"!$&'()*+,;=";
    NSMutableCharacterSet * allowedCharacterSet = [[NSCharacterSet URLQueryAllowedCharacterSet] mutableCopy];
    [allowedCharacterSet removeCharactersInString:[kAFCharactersGeneralDelimitersToEncode stringByAppendingString:kAFCharactersSubDelimitersToEncode]];
    
    
    NSString *percentstring = [string stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacterSet];
    NSString * plusReplaced = [percentstring stringByReplacingOccurrencesOfString:@"+" withString:@"%20"];
    NSString * starReplaced = [plusReplaced stringByReplacingOccurrencesOfString:@"*" withString:@"%2A"];
    NSString * waveReplaced = [starReplaced stringByReplacingOccurrencesOfString:@"%7E" withString:@"~"];
    return waveReplaced;
}

@end
