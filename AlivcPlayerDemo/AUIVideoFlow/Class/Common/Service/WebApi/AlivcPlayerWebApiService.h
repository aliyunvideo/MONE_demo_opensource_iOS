//
//  AlivcPlayerWebApiService.h
//  ApsaraVideo
//
//  Created by Bingo on 2021/7/5.
//

#import <Foundation/Foundation.h>
#import "AlivcPlayerWebApiCommon.h"
#import "AlivcPlayerWebApiUrlSession.h"

NS_ASSUME_NONNULL_BEGIN

@interface AlivcPlayerWebApiService : NSObject

@property (nonatomic, copy) NSString *requestUrl;
@property (nonatomic, assign) APWebApiSessionMethod sessionMethod;
@property (nonatomic, assign) BOOL retainWhenResume;


- (BOOL)running;
- (void)resumeWithData:(nullable id)bodyData completion:(void (^)(id _Nullable feedbackData, APWebApiResultCode resultCode, NSString * _Nullable msg))onCompletion;
- (void)resumeWithData:(nullable id)bodyData withURLParamData:(nullable id)urlParamData completion:(void (^)(id _Nullable feedbackData, APWebApiResultCode resultCode, NSString * _Nullable msg))onCompletion;
- (void)cancel;

// overright
- (AlivcPlayerWebApiUrlSession *)createUrlSessionWithBodyData:(nullable NSDictionary *)bodyData urlParams:(nullable NSDictionary *)urlParamData;
- (id)parseDataWithDataObject:(id)dataObject;

@end


NS_ASSUME_NONNULL_END
