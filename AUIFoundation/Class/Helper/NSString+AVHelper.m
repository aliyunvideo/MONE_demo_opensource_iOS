//
//  NSString+AVHelper.m
//  AlivcAIO_Demo
//
//  Created by Bingo on 2022/5/18.
//

#import "NSString+AVHelper.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (AVHelper)

+ (NSString *) av_randomString {
    CFUUIDRef puuid = CFUUIDCreate(nil);
    CFStringRef uuidString = CFUUIDCreateString(nil, puuid);
    NSString * result = (NSString *)CFBridgingRelease(CFStringCreateCopy(nil, uuidString));
    CFRelease(puuid);
    CFRelease(uuidString);
    return result;
}

- (NSString *)av_MD5 {
    const char *cStr = [self UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, (CC_LONG)strlen(cStr), digest ); // This is the md5 call
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    return  output;
}

@end
