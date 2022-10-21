//
//  AlivcPlayerWebApiCommon.m
//  ApsaraVideo
//
//  Created by Bingo on 2021/7/5.
//

#import "AlivcPlayerWebApiCommon.h"

NSString *APWebApiErrorDomain = @"err.webapi.op";

@implementation NSError (APWebApi)

+ (NSError *)ap_webApiErrorWithCode:(APWebApiResultCode)code desc:(NSString *)desc
{
    NSDictionary *errDesc = nil;
    if (desc.length > 0)
    {
        errDesc = [NSDictionary dictionaryWithObjectsAndKeys:desc ?: @"", NSLocalizedDescriptionKey, nil];
    }
    
    return [NSError errorWithDomain:APWebApiErrorDomain code:code userInfo:errDesc];
}

@end
