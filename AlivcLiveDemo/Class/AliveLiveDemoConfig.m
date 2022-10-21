//
//  AliveLiveDemoConfig.m
//  AlivcLiveDemo
//
//  Created by ISS013602000846 on 2022/6/14.
//

#import "AliveLiveDemoConfig.h"

#define AlivcPlayerFirstLaunchKey @"AlivcPlayerFirstLaunchKey"
#define AlivcPlayerFirstLaunch_AUILiveRecordPush_firshOpenKey @"AlivcPlayerFirstLaunch_AUILiveRecordPush_firshOpenKey"

@interface AliveLiveDemoConfig ()

@property (nonatomic, assign) BOOL firstLaunching;

@end

@implementation AliveLiveDemoConfig

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
    [self loadLiveRecordPushUserDefaults];
}

- (void)loadLiveRecordPushUserDefaults {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (self.firstLaunching || [userDefaults boolForKey:AlivcPlayerFirstLaunch_AUILiveRecordPush_firshOpenKey]) {
        [userDefaults setBool:YES forKey:AlivcPlayerFirstLaunch_AUILiveRecordPush_firshOpenKey];
    } else {
        [userDefaults setBool:NO forKey:AlivcPlayerFirstLaunch_AUILiveRecordPush_firshOpenKey];
    }
}


@end
