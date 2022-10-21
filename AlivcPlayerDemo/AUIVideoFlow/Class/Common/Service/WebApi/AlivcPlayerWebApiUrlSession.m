//
//  AlivcPlayerWebApiUrlSession.m
//  ApsaraVideo
//
//  Created by Bingo on 2021/7/5.
//

#import "AlivcPlayerWebApiUrlSession.h"

#define DefTimeOutInterval 30.0
#define DefDelayRetryInterval 3

#define DefNetworkErrMaxRetryCount 5

@interface AlivcPlayerWebApiUrlSession() <NSURLSessionDelegate>

@property (nonatomic, strong) NSMutableDictionary *dictHeaderFields;
@property (nonatomic, assign) NSInteger currentTryNum;  //当前尝试次数
@property (nonatomic, strong) NSURLSession *urlSession;
@property (nonatomic, weak)   NSURLSessionTask *task;
@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, assign) AlivcPlayerWebApiUrlSessionState state;
@property (nonatomic, strong) NSError *error;
@property (nonatomic, copy) NSURL *requestURL;        // 最终发起请求的URL对象

@end

@implementation AlivcPlayerWebApiUrlSession

- (instancetype)init {
    self = [super init];
    if (self) {
        self.dictHeaderFields = [[NSMutableDictionary alloc] init];
        self.retryCount = 0;
        self.timeoutSeconds = DefTimeOutInterval;
        self.state = AlivcPlayerWebApiUrlSessionStateIdle;
    }
    return self;
}

- (BOOL)isRunning {
    if (self.state == AlivcPlayerWebApiUrlSessionStateRunning
        || self.state == AlivcPlayerWebApiUrlSessionStateRetrying) {
        return YES;
    }
    else {
        return NO;
    }
}

- (void)setHttpHeader:(NSString *)value forHTTPHeaderField:(NSString *)field {
    [self.dictHeaderFields setObject:value forKey:field];
}

- (BOOL)startTask {
    if ([self isRunning]) {
        return NO;
    }
    
    self.currentTryNum = 0;
    if(self.URL.length <= 0) {
        self.state = AlivcPlayerWebApiUrlSessionStateFinish;
        [self notifyDelegateRequestFailedWithError:[NSError ap_webApiErrorWithCode:APWebApiCustomCodeMissParam desc:nil] data:nil];
        return YES;
    }
    
    self.state = AlivcPlayerWebApiUrlSessionStateRunning;
    self.currentTryNum++;
    return [self makeNormalRequest];
}

- (void)cancelTask {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    self.state = AlivcPlayerWebApiUrlSessionStateCancel;
    [self.task cancel];
    self.task = nil;
    self.responseData = nil;
}

- (void)retryTask {
    if ([self isRunning]) {
        return;
    }
    
    [self notifyDelegateRequestRetryWithError:self.error];

    self.state = AlivcPlayerWebApiUrlSessionStateRetrying;
    self.currentTryNum++;
    [self makeNormalRequest];
}

- (void)notifyDelegateRequestRetryWithError:(NSError *)error {
    if (self.beginRetryBlock) {
        __weak typeof(self) weakSelf = self;
        self.beginRetryBlock(weakSelf, error);
    }
}

#pragma mark - request

- (BOOL)makeNormalRequest {
    if (self.URL.length > 0) {
        [self startRequest:self.URL];
        return YES;
    }
    return NO;
}

- (NSString *)httpMethod {
    if (self.sessionMethod == APWebApiSessionMethodGET) {
        return @"GET";
    }
    
    if (self.sessionMethod == APWebApiSessionMethodPOST) {
        return @"POST";
    }
    
    NSAssert(NO, @"Method error...");
    return nil;
}

- (void)startRequest:(NSString *)url {
    NSData *body = [self requestBodyData];
    NSString *finalUrl = url;
    
    self.requestURL = [NSURL URLWithString:finalUrl];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:self.requestURL];
    [request setHTTPMethod:[self httpMethod]];
    [request setTimeoutInterval:self.timeoutSeconds];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    for (NSString *key in [self.dictHeaderFields allKeys]) {
        [request setValue:[self.dictHeaderFields objectForKey:key] forHTTPHeaderField:key];
    }
    
    if (self.sessionMethod == APWebApiSessionMethodPOST) {
        if (body) {
            [request setHTTPBody:body];
        }
    }
   
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    self.urlSession = session;
    
    NSURLSessionTask *task = [self.urlSession dataTaskWithRequest:request];
    self.task = task;
    [task resume];
}

- (NSData *)requestBodyData {
    NSData *requestData = nil;
    
    if (self.sessionMethod == APWebApiSessionMethodPOST && self.body && ([self.body isKindOfClass:[NSDictionary class]] || [self.body isKindOfClass:[NSArray class]])) {
        NSError *error = nil;
        if ([NSJSONSerialization isValidJSONObject:self.body]) {
            requestData = [NSJSONSerialization dataWithJSONObject:self.body options:NSJSONWritingPrettyPrinted error:&error];
        }
    }
    
    return requestData;
}

#pragma mark NSURLConnectionDelegate

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data {
    if (!self.responseData) {
        self.responseData = [[NSMutableData alloc] init];
    }
    
    [self.responseData appendData:data];
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error {
    if (error) {
        [self notifyRequestFailedWithError:error data:nil];
    }
    else {
        NSHTTPURLResponse *res = (NSHTTPURLResponse *)task.response;
        NSDictionary *resultDict;
        if (self.responseData) {
            resultDict = [self parseResponseData:self.responseData withResponseHeaders:res.allHeaderFields];
        }
        if ([resultDict isKindOfClass:[NSDictionary class]]) {
            NSNumber *code = [resultDict objectForKey:@"code"];
            if (code &&( [code isKindOfClass:[NSNumber class]] || [code isKindOfClass:[NSString class]])) {
                [self notifyRequestSucceedWithData:resultDict];
            }
            else {
                [self notifyRequestFailedWithError:[NSError ap_webApiErrorWithCode:APWebApiCustomCodeJsonLostParam desc:@"lost param 'code'"] data:self.responseData];
            }
        }
        else {
            [self notifyRequestFailedWithError:[NSError ap_webApiErrorWithCode:APWebApiCustomCodeJsonParse desc:nil] data:self.responseData];
        }
    }
    
    [session finishTasksAndInvalidate];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
 willCacheResponse:(NSCachedURLResponse *)proposedResponse
 completionHandler:(void (^)(NSCachedURLResponse * _Nullable cachedResponse))completionHandler {
    completionHandler(nil);
}

- (id)parseResponseData:(NSData *)resData withResponseHeaders:(NSDictionary *)resHeaders {
    NSData *finalData = resData;
    id returnObject = [NSJSONSerialization JSONObjectWithData:finalData options:NSJSONReadingMutableContainers error:nil];
    return returnObject;
}

#pragma mark - notify succeed

- (void)notifyRequestSucceedWithData:(NSDictionary *)data {
    if ([NSThread isMainThread]) {
        [self dispatchRequestSucceedWithData:data];
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self dispatchRequestSucceedWithData:data];
        });
    }
}

- (void)dispatchRequestSucceedWithData:(NSDictionary *)data {
    self.state = AlivcPlayerWebApiUrlSessionStateFinish;
    self.task = nil;
    self.error = nil;
    self.responseData = nil;
    
    [self notifyDelegateRequestSucceedWithData:data];
}

- (void)notifyDelegateRequestSucceedWithData:(id)data {
    if (self.completionBlock)
    {
        __weak typeof(self) weakSelf = self;
        self.completionBlock(weakSelf, data, nil);
    }
}

#pragma mark - notify failed

- (void)notifyRequestFailedWithError:(NSError*)error data:(id) data {
    if ([NSThread isMainThread]) {
        [self dispatchRequestFailedWithError:error data:data];
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self dispatchRequestFailedWithError:error data:data];
        });
    }
}

- (void)dispatchRequestFailedWithError:(NSError *)error data:(id)data {
    if (self.state == AlivcPlayerWebApiUrlSessionStateCancel) {
        return;
    }
    
    self.responseData = nil;
    [self.task cancel];
    self.task = nil;
    self.state = AlivcPlayerWebApiUrlSessionStateFinish;

    if (self.currentTryNum > self.retryCount) {
        [self notifyDelegateRequestFailedWithError:error data:data];
    }
    else {
        self.error = error;
        [self retryTask];
    }
}

- (void)notifyDelegateRequestFailedWithError:(NSError *)error data:(id)data {
    if (self.completionBlock) {
        __weak typeof(self) weakSelf = self;
        self.completionBlock(weakSelf, data, error);
    }
}

@end
