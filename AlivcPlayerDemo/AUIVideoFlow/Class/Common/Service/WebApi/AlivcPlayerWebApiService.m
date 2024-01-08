//
//  AlivcPlayerWebApiService.m
//  ApsaraVideo
//
//  Created by Bingo on 2021/7/5.
//

#import "AlivcPlayerWebApiService.h"
#import "AlivcPlayerFoundation.h"

@interface AlivcPlayerWebApiService ()

@property (nonatomic, strong) AlivcPlayerWebApiUrlSession *urlSession;
@property (nonatomic, assign) BOOL hasRetainSelf;

@end

@implementation AlivcPlayerWebApiService

- (instancetype)init {
    self = [super init];
    if (self) {
        self.sessionMethod = APWebApiSessionMethodGET;
        self.retainWhenResume = NO;
        self.hasRetainSelf = NO;
    }
    return self;
}

- (void)dealloc {
    [self.urlSession cancelTask];
    self.urlSession = nil;
}

- (void)resumeWithData:(id)bodyData completion:(void (^)(id, APWebApiResultCode, NSString *))onCompletion {
    [self resumeWithData:bodyData withURLParamData:nil completion:onCompletion];
}

- (void)resumeWithData:(id)bodyData withURLParamData:(id)urlParamData completion:(void (^)(id, APWebApiResultCode, NSString *))onCompletion {
    if (self.urlSession) {
        [self cancel];
    }
    
    __weak typeof (self) weakSelf = self;
    NSDictionary *reqeustParam = nil;
    {
        if([bodyData isKindOfClass:[NSDictionary class]]) {
            reqeustParam = bodyData;
        }
        else if (bodyData) {
            // todo: transform to dictionary
        }
    }
    
    NSDictionary *requestURLParam = nil;
    {
        if([urlParamData isKindOfClass:[NSDictionary class]]) {
            requestURLParam = urlParamData;
        }
        else if (urlParamData) {
            // todo: transform to dictionary
        }
    }
    
    self.urlSession = [self createUrlSessionWithBodyData:reqeustParam urlParams:requestURLParam];
    if (!self.urlSession) {
        if (onCompletion)
        {
            onCompletion(nil, APWebApiCustomCodeMissParam, @"param error");
        }
        return;
    }

    self.urlSession.completionBlock = ^(AlivcPlayerWebApiUrlSession *urlSession, id data, NSError *error) {
        if (error || !data) {
            onCompletion(nil, error.code, [error.userInfo av_stringValueForKey:NSLocalizedDescriptionKey]);
        }
        else {
            NSDictionary *dataDict = data;
            if ([dataDict isKindOfClass:[NSDictionary class]]) {
                NSInteger code = [dataDict av_intValueForKey:@"code"];
                NSString *msg = [dataDict av_stringValueForKey:@"message"];
                id dataObj = [data objectForKey:@"data"];
                id feedbackData = nil;
                if (code == APWebApiResCodeSucceed)
                {
                    feedbackData = [weakSelf parseDataWithDataObject:dataObj];
                }
                onCompletion(feedbackData, code, msg);
            }
            else {
                onCompletion(nil, APWebApiCustomCodeUnknow, @"unknow");
            }
        }
        [weakSelf releaseSelf];
    };
    if ([self.urlSession startTask])
    {
        [self retainSelf];
    }
}

- (BOOL)running
{
    return [self.urlSession isRunning];
}

- (void)cancel
{
    [self.urlSession cancelTask];
    self.urlSession = nil;
    [self releaseSelf];
}

- (AlivcPlayerWebApiUrlSession *)createUrlSessionWithBodyData:(NSDictionary *)bodyData urlParams:(NSDictionary *)urlParamData
{
    if (!self.requestUrl || self.requestUrl.length == 0)
    {
        return nil;
    }
    
    __block NSString *finalURL = self.requestUrl;
    if(urlParamData.count > 0)
    {
        [[urlParamData allKeys] enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            finalURL = [finalURL stringByAppendingFormat:idx == 0? @"?%@=%@" : @"&%@=%@",obj,[urlParamData objectForKey:obj]];
        }];
    }
    
    AlivcPlayerWebApiUrlSession *urlSession = [[AlivcPlayerWebApiUrlSession alloc] init];
    urlSession.URL = finalURL;
    urlSession.retryCount = 1;
    urlSession.sessionMethod = self.sessionMethod;
    urlSession.body = bodyData;
    [urlSession setHttpHeader:@"application/JSON" forHTTPHeaderField:@"Content-Type"];
    
    return urlSession;
}

- (id)parseDataWithDataObject:(id)dataObject
{
    return dataObject;
}

#pragma mark - private

- (void)retainSelf
{
    if (self.retainWhenResume)
    {
        CFRetain((__bridge CFTypeRef)(self));
        self.hasRetainSelf = YES;
    }
}

- (void)releaseSelf
{
    if (self.hasRetainSelf)
    {
        CFRelease((__bridge CFTypeRef)(self));
    }
    self.hasRetainSelf = NO;
}

@end
