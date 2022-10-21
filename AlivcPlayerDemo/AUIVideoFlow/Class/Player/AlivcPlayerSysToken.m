//
//  AlivcPlayerSysToken.m
//  ApsaraVideo
//
//  Created by mengyehao on 2021/7/13.
//

#import "AlivcPlayerSysToken.h"
#import "AlivcPlayerWebApiService.h"
#import "AlivcPlayerServer.h"

@implementation AlivcPlayerSysToken

- (NSString *)requestPath
{
    return @"/api/getSts";
}


- (void)refreshToken
{
    __weak typeof(self) weakSelf = self;
    AlivcPlayerWebApiService *service = [AlivcPlayerWebApiService new];
    service.retainWhenResume = YES;
    service.requestUrl = [AlivcPlayerServer urlWithPath:[self requestPath]];
    [service resumeWithData:nil withURLParamData:nil completion:^(NSDictionary * _Nullable feedbackData, APWebApiResultCode resultCode, NSString * _Nullable msg) {
                
        if (resultCode == APWebApiResCodeSucceed) {
        
            weakSelf.accessKeyId = [feedbackData objectForKey:@"accessKeyId"];
            weakSelf.securityToken = [feedbackData objectForKey:@"securityToken"];
            weakSelf.accessKeySecret = [feedbackData objectForKey:@"accessKeySecret"];
            weakSelf.expirationDuration = [feedbackData objectForKey:@"expirationDuration"];

            if (weakSelf.expirationDuration) {
       
                NSTimeInterval duration =  weakSelf.expirationDuration.floatValue/1000.0;
                [weakSelf performSelector:@selector(refreshToken) withObject:nil afterDelay:duration];
            }

        }
       
    }];
}
@end
