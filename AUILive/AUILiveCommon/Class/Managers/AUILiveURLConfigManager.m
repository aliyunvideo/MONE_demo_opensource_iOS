//
//  AUILiveURLConfigManager.m
//  AlivcLivePusherDemo
//
//  Created by ISS013602000846 on 2022/9/6.
//  Copyright © 2022 TripleL. All rights reserved.
//

#import "AUILiveURLConfigManager.h"
#import "AliLiveUserSigGenerate.h"

#define kAUILiveURLConfig_AppID_UserDefaultsKey @"AUILiveURLConfig_AppID_UserDefaultsKey"
#define kAUILiveURLConfig_AppKey_UserDefaultsKey @"AUILiveURLConfig_AppKey_UserDefaultsKey"
#define kAUILiveURLConfig_PlayDomain_UserDefaultsKey @"AUILiveURLConfig_PlayDomain_UserDefaultsKey"

#define ERROR_URL_PLACEHOLDER @"PLACEHOLDER"

@implementation AUILiveURLConfigManager

+ (instancetype)manager {
    static AUILiveURLConfigManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[AUILiveURLConfigManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    if (self = [super init]) {
        [self reset];
    }
    return self;
}

- (void)setAppID:(NSString *)appID {
    _appID = appID;
    [[NSUserDefaults standardUserDefaults] setObject:appID forKey:kAUILiveURLConfig_AppID_UserDefaultsKey];
}

- (void)setAppKey:(NSString *)appKey {
    _appKey = appKey;
    [[NSUserDefaults standardUserDefaults] setObject:appKey forKey:kAUILiveURLConfig_AppKey_UserDefaultsKey];
}
- (void)setPlayDomain:(NSString *)playDomain {
    _playDomain = playDomain;
    [[NSUserDefaults standardUserDefaults] setObject:self.playDomain forKey:kAUILiveURLConfig_PlayDomain_UserDefaultsKey];
}

- (BOOL)haveSigGenerateConfig {
    if ((ALILIVE_APPID.length > 0 && ![ALILIVE_APPID isEqualToString:ERROR_URL_PLACEHOLDER]) &&
        (ALILIVE_APPKey.length > 0 && ![ALILIVE_APPKey isEqualToString:ERROR_URL_PLACEHOLDER]) &&
        (ALILIVE_PLAY_DOMAIN.length > 0 && ![ALILIVE_PLAY_DOMAIN isEqualToString:ERROR_URL_PLACEHOLDER])) {
        return YES;
    }
    return NO;
}

- (BOOL)haveConfig {
    if ([self haveSigGenerateConfig]) {
        return YES;
    } else {
        return self.appID.length > 0 && self.appKey.length > 0 && self.playDomain.length > 0;
    }
}


- (BOOL)haveConfigAtUserDefaults {
    NSString *appID = [self getAppIDAtUserDefaults];
    NSString *appKey = [self getAppKeyAtUserDefaults];
    NSString *playDomain = [self getPlayDomainAtUserDefaults];
    BOOL haveConfig = (appID && appID.length > 0) && (appKey && appKey.length > 0) && (playDomain && playDomain.length > 0);
    return haveConfig;
}

- (NSString *)getAppIDAtUserDefaults {
    NSString *appId = [[NSUserDefaults standardUserDefaults] objectForKey:kAUILiveURLConfig_AppID_UserDefaultsKey];
    if (!appId) {
        return @"";
    }
    return appId;
}

- (NSString *)getAppKeyAtUserDefaults {
    NSString *appKey = [[NSUserDefaults standardUserDefaults] objectForKey:kAUILiveURLConfig_AppKey_UserDefaultsKey];
    if (!appKey) {
        return @"";
    }
    return appKey;
}

- (NSString *)getPlayDomainAtUserDefaults {
    NSString *playDomain = [[NSUserDefaults standardUserDefaults] objectForKey:kAUILiveURLConfig_PlayDomain_UserDefaultsKey];
    if (!playDomain) {
        return @"";
    }
    return playDomain;
}

- (void)reset {
    if ([self haveConfigAtUserDefaults]) {
        self.appID = [self getAppIDAtUserDefaults];
        self.appKey = [self getAppKeyAtUserDefaults];
        self.playDomain = [self getPlayDomainAtUserDefaults];
    } else {
        self.appID = @"";
        self.appKey = @"";
        self.playDomain = @"";
    }
}

@end
