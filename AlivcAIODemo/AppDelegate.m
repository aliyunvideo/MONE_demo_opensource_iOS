//
//  AppDelegate.m
//  AlivcAIODemo
//
//  Created by Bingo on 2022/5/23.
//

#import "AppDelegate.h"
#import "AIOHomeViewController.h"
#import "AIOSdkHeader.h"

#if __has_include(<WPKMobi/WPKSetup.h>)
#import <WPKMobi/WPKSetup.h>
#define AIO_DEMO_ENABLE_ITRACE
#endif

#ifdef AIO_DEMO_ENABLE_PLAYER
#import "AlivcPlayerDemoConfig.h"
#endif

#ifdef AIO_DEMO_ENABLE_UGSV
#import "AlivcUgsvSDKHeader.h"
#endif

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)setupUgsv {
#ifdef AIO_DEMO_ENABLE_UGSV
    
#if DEBUG
    [AliyunVideoSDKInfo setLogLevel:AlivcLogDebug];
#endif
    
    [AliyunVideoSDKInfo registerSDK];
    
#endif // AIO_DEMO_ENABLE_UGSV
}

- (void)setupPlayer {
#ifdef AIO_DEMO_ENABLE_PLAYER
    // 播放器启动加载文件
    AlivcPlayerDemoConfig *config = [AlivcPlayerDemoConfig new];
    [config didFinishLaunching];
#endif // AIO_DEMO_ENABLE_PLAYER
}

- (void)setupQueen {
#ifdef AIO_DEMO_ENABLE_QUEEN
    [[QueenMaterial sharedInstance] requestMaterial:kQueenMaterialModel];
#endif // AIO_DEMO_ENABLE_QUEEN
}

- (void)setupCrash {
#ifdef AIO_DEMO_ENABLE_ITRACE
    // init itrace crashsdk
    [WPKSetup startWithAppName:@"你的itraceId"];
    // 异步上传崩溃日志，您也可以在您想要的时机去调用日志上传,如启动3s后
    [WPKSetup sendAllReports];
#endif // AIO_DEMO_ENABLE_ITRACE
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    AlivcBase.IntegrationWay = @"Demo_AIO";
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    // 仅支持暗黑模式
    AVTheme.supportsAutoMode = NO;
    AVTheme.currentMode = AVThemeModeDark;
    
    AVNavigationController *nav =[[AVNavigationController alloc]initWithRootViewController:[AIOHomeViewController new]];
    [self.window setRootViewController:nav];
    [self.window makeKeyAndVisible];
    
    [self setupUgsv];
    [self setupPlayer];
    [self setupQueen];
    
    [self setupCrash];
    return YES;
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    UIInterfaceOrientationMask orientationMask = UIViewController.av_topViewController.supportedInterfaceOrientations;
#ifdef AIO_DEMO_ENABLE_PLAYER
    // 播放器相关横竖屏适配
    AlivcPlayerDemoConfig *config = [AlivcPlayerDemoConfig new];
    orientationMask = [config supportedInterfaceOrientation];
#endif // AIO_DEMO_ENABLE_PLAYER
    return orientationMask;
}

@end
