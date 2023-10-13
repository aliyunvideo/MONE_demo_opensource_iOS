//
//  AUILiveURLUtils.m
//  AUILiveCommon
//
//  Created by ISS013602000846 on 2022/8/2.
//

#import "AUILiveURLUtils.h"
#import "AUILiveURLConfigManager.h"
#import <CommonCrypto/CommonCrypto.h>
#import <CoreFoundation/CoreFoundation.h>
#import <zlib.h>

#define ERROR_URL_PLACEHOLDER @"PLACEHOLDER"

#define ALILIVE_RTC_PREFIX @"artc"
#define ALILIVE_RTC_DEMAIN @"live.aliyun.com"

#define ALILIVE_CDN_PREFIX @"http"

#define ALILIVE_DEFAULT_TIMESTAMP (60 * 60 * 24)

@interface AUILiveURLUtils ()

/**
 *  AppID
 *  应用ID。在控制台应用管理页面创建和查看。
 */
@property (nonatomic, strong) NSString *appID;
/**
 *  AppKey
 *  在控制台应用管理页面创建和查看。
 */
@property (nonatomic, strong) NSString *appKey;
/**
 *  URL前缀字段
 *  例如：rtmp、artc等。
 */
@property (nonatomic, strong) NSString *prefix;
/**
 *  domain地址
 *  固定字段。
 */
@property (nonatomic, strong) NSString *domain;
/**
 *  'AK-'开头的随机码
 *  例如：AK-844dc96d-bfac-49d4-819c-d67d4ca8fe20
 */
@property (nonatomic, strong) NSString *nonce;

/**
 *  Token
 *  SDKAppId、userId、streamName、nonce、timeStamp、AppKey加权得到。
 */
@property (nonatomic, strong) NSString *token;
/**
 *  签名过期时间
 *  时间单位秒，代表令牌有效时间。可设置最大范围是小于等于1天，建议不要设置的过短或超过1天，超过1天会不安全。
 *  默认时间1天。1天 = 60 x  60  x 24。
 */
@property (nonatomic, strong) NSString *timeStamp;

@property (nonatomic, strong) AUILiveURLConfigManager *manager;

@end

@implementation AUILiveURLUtils

- (NSString *)getRTCURL {
    if (self.appID.length == 0 || self.appKey.length == 0 || self.domain.length == 0 ||
        !self.streamName || self.streamName.length == 0 ||
        !self.userId || self.userId.length == 0) {
        return @"";
    }
    
    [self updateToken];

    NSString *urlMode = [self getURLMode];
    NSString *rtcURL = [NSString stringWithFormat:@"%@://%@/%@/%@?", self.prefix, self.domain, urlMode, self.streamName];
    NSString *paramsURL = [NSString stringWithFormat:@"sdkAppId=%@&userId=%@&token=%@&timestamp=%@", self.appID, self.userId, self.token, self.timeStamp];
    rtcURL = [rtcURL stringByAppendingString:paramsURL];
    NSLog(@"rtcURL:%@", rtcURL);
    return rtcURL;
}

- (NSString *)getCDNURL {
    if (self.appID.length == 0 || self.domain.length == 0 ||
        !self.streamName || self.streamName.length == 0 ||
        !self.userId || self.userId.length == 0) {
        return @"";
    }
    
    NSString *urlMode = [self getURLMode];
    NSString *cdnURL = [NSString stringWithFormat:@"%@://%@/%@/", self.prefix,  self.domain, urlMode];
    NSString *streamURL = nil;
    if(self.isAudioOnly)
    {
        streamURL = [NSString stringWithFormat:@"%@_%@_%@_audio.flv", self.appID, self.streamName, self.userId];
    }
    else
    {
        streamURL = [NSString stringWithFormat:@"%@_%@_%@_camera.flv", self.appID, self.streamName, self.userId];
    }
    cdnURL = [cdnURL stringByAppendingString:streamURL];
    NSLog(@"cdnURL:%@", cdnURL);
    return cdnURL;
}

- (NSString *)getURLMode {
    if (self.isRTC) {
        if (self.isPlay) {
            return @"play";
        } else {
            return @"push";
        }
    } else {
        return @"live";
    }
}

#pragma mark -- update Nonce
- (void)updateNonce {
    // AK-8位-4位-4位-4位-12位
    NSString *noncePrefixString = @"AK-";
    
    CFUUIDRef nonce_uuid_ref = CFUUIDCreate(NULL);
    CFStringRef nonce_uuid_string_ref = CFUUIDCreateString(NULL, nonce_uuid_ref);
    NSString *nonce_randomString = [NSString stringWithString:(__bridge NSString *)nonce_uuid_string_ref];
    CFRelease(nonce_uuid_ref);
    CFRelease(nonce_uuid_string_ref);
    
    self.nonce = [noncePrefixString stringByAppendingString:nonce_randomString];
}

#pragma mark -- update Token
- (void)updateToken {
    const char *str = [[NSString stringWithFormat:@"%@%@%@%@%@", self.appID, self.appKey, self.streamName, self.userId, self.timeStamp] UTF8String];
    unsigned char result[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(str, (CC_LONG)strlen(str), result);
    
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02x", result[i]];
    }
    self.token = [ret lowercaseString];
}

#pragma mark -- lazy load
- (NSString *)appID {
    if (!_appID || _appID.length == 0) {
        if (ALILIVE_APPID.length == 0 || [ALILIVE_APPID isEqualToString:ERROR_URL_PLACEHOLDER]) {
            _appID = self.manager.appID;
        } else {
            _appID = ALILIVE_APPID;
        }
    }
    return _appID;
}

- (NSString *)appKey {
    if (!_appKey || _appKey.length == 0) {
        if (ALILIVE_APPKey.length == 0 || [ALILIVE_APPKey isEqualToString:ERROR_URL_PLACEHOLDER]) {
            _appKey = self.manager.appKey;
        } else {
            _appKey = ALILIVE_APPKey;
        }
    }
    return _appKey;
}

- (NSString *)prefix {
    if (!_prefix || _prefix.length == 0) {
        if (self.isRTC) {
            _prefix = ALILIVE_RTC_PREFIX;
        } else {
            _prefix = ALILIVE_CDN_PREFIX;
        }
    }
    return _prefix;
}

- (NSString *)domain {
    if (!_domain || _domain.length == 0) {
        if (self.isRTC) {
            _domain = ALILIVE_RTC_DEMAIN;
        } else {
            if (ALILIVE_PLAY_DOMAIN.length == 0 || [ALILIVE_PLAY_DOMAIN isEqualToString:ERROR_URL_PLACEHOLDER]) {
                _domain = self.manager.playDomain;
            } else {
                _domain = ALILIVE_PLAY_DOMAIN;
            }
        }
    }
    return _domain;
}

- (NSString *)timeStamp {
    if (!_timeStamp || _timeStamp.length == 0) {
        long timeStamp_gap = ALILIVE_TIMESTAMP;
        if (timeStamp_gap == 0) {
            timeStamp_gap = ALILIVE_DEFAULT_TIMESTAMP;
        }
        
        NSDate *timeStamp_date = [NSDate dateWithTimeIntervalSinceNow:timeStamp_gap];
        NSTimeInterval timeStamp_int = [timeStamp_date timeIntervalSince1970];
        _timeStamp = [NSString stringWithFormat:@"%.0f", timeStamp_int];
    }
    return _timeStamp;
}

- (AUILiveURLConfigManager *)manager {
    if (!_manager) {
        _manager = [AUILiveURLConfigManager manager];
    }
    return _manager;
}

@end
