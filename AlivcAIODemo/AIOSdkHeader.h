//
//  AIOSdkHeader.h
//  AlivcAIODemo
//
//  Created by Bingo on 2022/8/9.
//

#ifndef AIOSdkHeader_h
#define AIOSdkHeader_h



#if __has_include(<AliVCSDK_Standard/AliVCSDK_Standard.h>)
#import <AliVCSDK_Standard/AliVCSDK_Standard.h>
#define AIO_DEMO_USING_ALIVCSDK
#define AIO_DEMO_ENABLE_UGSV
#define AIO_DEMO_ENABLE_PLAYER
#define AIO_DEMO_ENABLE_LIVE
#define AIO_DEMO_ENABLE_RTC
#define AIO_DEMO_ENABLE_QUEEN

#elif __has_include(<AliVCSDK_InteractiveLive/AliVCSDK_InteractiveLive.h>)
#import <AliVCSDK_InteractiveLive/AliVCSDK_InteractiveLive.h>
#define AIO_DEMO_USING_ALIVCSDK
#define AIO_DEMO_ENABLE_PLAYER
#define AIO_DEMO_ENABLE_LIVE
#define AIO_DEMO_ENABLE_RTC
#define AIO_DEMO_ENABLE_QUEEN

#elif __has_include(<AliVCSDK_BasicLive/AliVCSDK_BasicLive.h>)
#import <AliVCSDK_BasicLive/AliVCSDK_BasicLive.h>
#define AIO_DEMO_USING_ALIVCSDK
#define AIO_DEMO_ENABLE_PLAYER
#define AIO_DEMO_ENABLE_LIVE
#define AIO_DEMO_ENABLE_QUEEN


#elif __has_include(<AliVCSDK_UGC/AliVCSDK_UGC.h>)
#import <AliVCSDK_UGC/AliVCSDK_UGC.h>
#define AIO_DEMO_USING_ALIVCSDK
#define AIO_DEMO_ENABLE_UGSV
#define AIO_DEMO_ENABLE_PLAYER
#define AIO_DEMO_ENABLE_QUEEN

#endif



#if __has_include(<AlivcLivePusher/AlivcLivePusher.h>)
#import <AlivcLivePusher/AlivcLivePusher.h>
#define AIO_DEMO_ENABLE_LIVE
#endif

#if __has_include(<AliyunPlayer/AliyunPlayer.h>)
#import <AliyunPlayer/AliyunPlayer.h>
#define AIO_DEMO_ENABLE_PLAYER
#endif

#if __has_include(<AliyunVideoSDKPro/AliyunVideoSDKPro.h>)
#import <AliyunVideoSDKPro/AliyunVideoSDKPro.h>
#define AIO_DEMO_ENABLE_UGSV
#elif __has_include(<AliyunVideoSDKBasic/AliyunVideoSDKBasic.h>)
#import <AliyunVideoSDKBasic/AliyunVideoSDKBasic.h>
#define AIO_DEMO_ENABLE_UGSV
#endif

#if __has_include(<Queen/Queen.h>)
#import <Queen/Queen.h>
#define AIO_DEMO_ENABLE_QUEEN
#define AIO_DEMO_ENABLE_QUEEN_PRO
#endif

#endif /* AIOSdkHeader_h */
