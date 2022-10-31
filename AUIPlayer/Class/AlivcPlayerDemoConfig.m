//
//  AlivcPlayerDemoConfig.m
//  AlivcPlayerDemo
//
//  Created by ISS013602000846 on 2022/6/13.
//

#import "AlivcPlayerDemoConfig.h"
#import <AliyunPlayer/AliyunPlayer.h>

#define AlivcPlayerFirstLaunchKey @"AlivcPlayerFirstLaunchKey"
#define AlivcPlayerFirstLaunch_AUIVideoFlow_speedTipKey @"AlivcPlayerFirstLaunch_AUIVideoFlow_speedTipKey"
#define AlivcPlayerFirstLaunch_AUIVideoFlow_FullScreenSpeedTipKey @"AlivcPlayerFirstLaunch_AUIVideoFlow_FullScreenSpeedTipKey"
#define AlivcPlayerFirstLaunch_AUIVideoFlow_FirstLandsacpeSpeedTipKey @"AlivcPlayerFirstLaunch_AUIVideoFlow_FirstLandsacpeSpeedTipKey"
#define AlivcPlayerFirstLaunch_AUIVideoList_HandUpKey @"AlivcPlayerFirstLaunch_AUIVideoList_HandUpKey"

@interface AlivcPlayerDemoConfig ()

@property (nonatomic, assign) BOOL firstLaunching;

@end

@implementation AlivcPlayerDemoConfig

- (void)judgeFirstLaunching {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *lastAppVersion = [userDefaults objectForKey:@"LastAppVersion"];
    NSString *currentAppVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    
    if ([lastAppVersion floatValue] < [currentAppVersion floatValue]) {
        [userDefaults setValue:currentAppVersion forKey:@"LastAppVersion"];
        self.firstLaunching = YES;
    } else {
        self.firstLaunching = NO;
    }
}

- (void)didFinishLaunching {
    [self judgeFirstLaunching];
    
    [self loadPlayerUserDefaults];
    
    NSObject *videoFlowConfig = [self getConfig:@"AUIVideoFlowConfig"];
    if (videoFlowConfig) {
        [self loadVideoFlowUserDefaults];
        
        if ([videoFlowConfig respondsToSelector:@selector(didFinishLaunching)]) {
            [videoFlowConfig performSelector:@selector(didFinishLaunching)];
        }
    }
    
    NSObject *videoListConfig = [self getConfig:@"AUIVideoListConfig"];
    if (videoListConfig) {
        [self loadVideoListUserDefaults];
        
        if ([videoListConfig respondsToSelector:@selector(didFinishLaunching)]) {
            [videoListConfig performSelector:@selector(didFinishLaunching)];
        }
    }
    
    [self loadPlayrLicense];
}

- (void)loadPlayerUserDefaults {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (self.firstLaunching) {
        [userDefaults setBool:YES forKey:AlivcPlayerFirstLaunchKey];
    } else {
        [userDefaults setBool:NO forKey:AlivcPlayerFirstLaunchKey];
    }
}

- (void)loadVideoFlowUserDefaults {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (self.firstLaunching || [userDefaults boolForKey:AlivcPlayerFirstLaunch_AUIVideoFlow_speedTipKey]) {
        [userDefaults setBool:YES forKey:AlivcPlayerFirstLaunch_AUIVideoFlow_speedTipKey];
    } else {
        [userDefaults setBool:NO forKey:AlivcPlayerFirstLaunch_AUIVideoFlow_speedTipKey];
    }
    
    if (self.firstLaunching || [userDefaults boolForKey:AlivcPlayerFirstLaunch_AUIVideoFlow_FullScreenSpeedTipKey]) {
        [userDefaults setBool:YES forKey:AlivcPlayerFirstLaunch_AUIVideoFlow_FullScreenSpeedTipKey];
    } else {
        [userDefaults setBool:NO forKey:AlivcPlayerFirstLaunch_AUIVideoFlow_FullScreenSpeedTipKey];
    }
    
    if (self.firstLaunching || [userDefaults boolForKey:AlivcPlayerFirstLaunch_AUIVideoFlow_FirstLandsacpeSpeedTipKey]) {
        [userDefaults setBool:YES forKey:AlivcPlayerFirstLaunch_AUIVideoFlow_FirstLandsacpeSpeedTipKey];
    } else {
        [userDefaults setBool:NO forKey:AlivcPlayerFirstLaunch_AUIVideoFlow_FirstLandsacpeSpeedTipKey];
    }
}

- (void)loadVideoListUserDefaults {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (self.firstLaunching || [userDefaults boolForKey:AlivcPlayerFirstLaunch_AUIVideoList_HandUpKey]) {
        [userDefaults setBool:YES forKey:AlivcPlayerFirstLaunch_AUIVideoList_HandUpKey];
    } else {
        [userDefaults setBool:NO forKey:AlivcPlayerFirstLaunch_AUIVideoList_HandUpKey];
    }
}

- (void)loadPlayrLicense {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [AliPrivateService initLicenseService];
    });
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientation {
    UIInterfaceOrientationMask mask = UIViewController.av_topViewController.supportedInterfaceOrientations;
    NSObject *videoFlowConfig = [self getConfig:@"AUIVideoFlowConfig"];
    if (videoFlowConfig) {
        if ([videoFlowConfig respondsToSelector:@selector(shouldFlowOrientation)]) {
            BOOL shouldFlowOrientation = [videoFlowConfig performSelector:@selector(shouldFlowOrientation)];
            if (shouldFlowOrientation) {
                if ([videoFlowConfig respondsToSelector:@selector(supportedInterfaceOrientation)]) {
                    mask = [videoFlowConfig performSelector:@selector(supportedInterfaceOrientation)];
                }
            }
        }
    }
    
    if (mask == UIInterfaceOrientationMaskAllButUpsideDown ||
        mask == UIInterfaceOrientationMaskAll) {
        return UIInterfaceOrientationMaskPortrait;
    }
    
    return mask;
}

- (NSObject *)getConfig:(NSString *)configStr {
    Class configClass = NSClassFromString(configStr);
    NSObject *config = [[configClass alloc] init];
    return config;
}

@end
