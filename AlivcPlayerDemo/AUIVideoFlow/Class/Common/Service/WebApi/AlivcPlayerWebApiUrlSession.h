//
//  AlivcPlayerWebApiUrlSession.h
//  ApsaraVideo
//
//  Created by Bingo on 2021/7/5.
//

#import <Foundation/Foundation.h>
#import "AlivcPlayerWebApiCommon.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, AlivcPlayerWebApiUrlSessionState)
{
    AlivcPlayerWebApiUrlSessionStateIdle = 0,
    AlivcPlayerWebApiUrlSessionStateRunning,
    AlivcPlayerWebApiUrlSessionStateRetrying,
    AlivcPlayerWebApiUrlSessionStateFinish,
    AlivcPlayerWebApiUrlSessionStateCancel
};

typedef NS_ENUM(NSUInteger, APWebApiSessionMethod) {
    APWebApiSessionMethodGET,
    APWebApiSessionMethodPOST,
};

@class AlivcPlayerWebApiUrlSession;

typedef void(^AlivcPlayerWebApiUrlSessionCompletionBlock)(AlivcPlayerWebApiUrlSession *session, id data,  NSError * _Nullable error);
typedef void(^AlivcPlayerWebApiUrlSessionBeginRetryBlock)(AlivcPlayerWebApiUrlSession *session, NSError * _Nullable error);

@interface AlivcPlayerWebApiUrlSession : NSObject

@property (nonatomic, copy) NSString *URL;                      // 要请求的URL
@property (nonatomic, copy, readonly) NSURL *requestURL;        // 最终发起请求的URL对象

@property (nonatomic, strong) id body;                          // 如果有，必须是NSDictionary或NSArray

@property (nonatomic, assign, readonly) AlivcPlayerWebApiUrlSessionState state;         // 任务状态
@property (nonatomic, assign) APWebApiSessionMethod sessionMethod;
@property (nonatomic, assign, readonly) NSInteger currentTryNum;                // 当前尝试次数
@property (nonatomic, assign) NSInteger retryCount;             // 失败时重试次数
@property (nonatomic, assign) float timeoutSeconds;             // 超时，默认30s
@property (nonatomic, strong) NSDictionary *userInfo;           // 设置用于标示task的用户信息

@property (nonatomic, copy) AlivcPlayerWebApiUrlSessionCompletionBlock completionBlock;
@property (nonatomic, copy) AlivcPlayerWebApiUrlSessionBeginRetryBlock beginRetryBlock;

- (void)setHttpHeader:(NSString *)value forHTTPHeaderField:(NSString *)field;
- (BOOL)isRunning;
- (BOOL)startTask;
- (void)cancelTask;

@end

NS_ASSUME_NONNULL_END
