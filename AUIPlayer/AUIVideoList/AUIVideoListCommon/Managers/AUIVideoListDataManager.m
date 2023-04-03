//
//  AUIVideoListDataManager.m
//  AUIVideoList
//
//  Created by zzy on 2022/3/23.
//  Copyright © 2022 com.alibaba. All rights reserved.
//

#import "AUIVideoListDataManager.h"
#import <AFNetworking/AFNetworking.h>
#import "NSDictionary+AVHelper.h"
#import "NSString+AVHelper.h"

#define AUIVideoList_SlideIndicationShowKey @"AUIVideoList_SlideIndicationShowKey"

@implementation AUIVideoListDataManager

#pragma mark -- request videoInfo data
- (void)requestVideoInfos:(BOOL)isAdd completion:(void(^)(BOOL success, NSArray<AUIVideoInfo *> *sources, NSError *error))completion {
    if (!self.requestUrl || self.requestUrl.length == 0) {
        return;
    }
    if (isAdd && !self.nextIndex) {
        return;
    }
    
    id parameters = nil;
    if (isAdd) {
        parameters = self.nextIndex;
    }
    AFHTTPSessionManager *sessionManager = [AFHTTPSessionManager manager];
    __weak typeof(self) weakSelf = self;
    NSURLSessionDataTask *task = [sessionManager GET:self.requestUrl parameters:parameters headers:@{} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        __strong typeof(self) strongSelf = weakSelf;
        if (![responseObject isKindOfClass:[NSArray class]]) {
            if (completion) {
                NSError *error = [NSError errorWithDomain:@"" code:0 userInfo:@{NSLocalizedDescriptionKey: AUIVideoListString(@"Request_Data_Format_Error")}];
                completion(NO, nil, error);
            }
        } else {
            NSArray *requestData = [strongSelf convertSourceData:(NSArray *)responseObject];
            if (completion) {
                completion(YES, requestData, nil);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (completion) {
            completion(NO, nil, error);
        }
    }];
    [task resume];
}

#pragma mark -- convert videoInfo data
- (NSArray<AUIVideoInfo *> *)convertSourceData:(NSArray<NSDictionary *> *)data {
    NSArray<NSDictionary *> *sourceData = data;
    __block NSMutableArray<AUIVideoInfo *> *sourceDataArr = [NSMutableArray array];
    __weak typeof(self) weakSelf = self;
    [sourceData enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        __strong typeof(self) strongSelf = weakSelf;
        __block AUIVideoInfo *listModel = [[AUIVideoInfo alloc] init];
        listModel.author = [obj av_stringValueForKey:@"author"];
        listModel.title = [obj av_stringValueForKey:@"title"];
        listModel.url = [obj av_stringValueForKey:@"url"];
        listModel.coverURL = [obj av_stringValueForKey:@"coverURL"];
        if ([obj.allKeys containsObject:@"uid"]) {
            listModel.uid = [obj av_stringValueForKey:@"uid"];
        } else {
            listModel.uid = [NSString av_randomString];
        }
        if ([obj.allKeys containsObject:@"nextIndex"]) {
            strongSelf.nextIndex = [obj objectForKey:@"nextIndex"];
        }
        [sourceDataArr addObject:listModel];
    }];
    return sourceDataArr.copy;
}

+ (NSArray<NSDictionary *> *)getDefaultJsonSourceData {
    NSString *sourceDataPath = [[[NSBundle mainBundle] pathForResource:@"AUIVideoList" ofType:@"bundle"] stringByAppendingPathComponent:@"/Resource/videoList.json"];
    NSData *jsonData = [[NSData alloc] initWithContentsOfFile:sourceDataPath];
    NSArray *sourceData = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
    return sourceData;
}

#pragma mark -- slideIndication data
+ (BOOL)isSlideIndicationShow:(NSString *)pageName {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *userKey = [AUIVideoList_SlideIndicationShowKey stringByAppendingFormat:@"_%@", pageName];
    if (![[userDefaults objectForKey:userKey] isKindOfClass:[NSString class]]) {
        [self updateSlideIndicationShow:YES pageName:pageName];
    }
    
    return [[userDefaults objectForKey:userKey] boolValue];
}

+ (void)updateSlideIndicationShow:(BOOL)isShow pageName:(NSString *)pageName {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *userKey = [AUIVideoList_SlideIndicationShowKey stringByAppendingFormat:@"_%@", pageName];
    [userDefaults setObject:[NSString stringWithFormat:@"%d", isShow] forKey:userKey];
}

@end
