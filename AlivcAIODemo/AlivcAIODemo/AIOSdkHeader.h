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

#elif __has_include(<AliVCSDK_Premium/AliVCSDK_Premium.h>)
#import <AliVCSDK_Premium/AliVCSDK_Premium.h>
#define AIO_DEMO_USING_ALIVCSDK
#define AIO_DEMO_ENABLE_UGSV
#define AIO_DEMO_ENABLE_PLAYER
#define AIO_DEMO_ENABLE_LIVE
#define AIO_DEMO_ENABLE_QUEEN

#elif __has_include(<AliVCSDK_InteractiveLive/AliVCSDK_InteractiveLive.h>)
#import <AliVCSDK_InteractiveLive/AliVCSDK_InteractiveLive.h>
#define AIO_DEMO_USING_ALIVCSDK
#define AIO_DEMO_ENABLE_PLAYER
#define AIO_DEMO_ENABLE_LIVE

#elif __has_include(<AliVCSDK_BasicLive/AliVCSDK_BasicLive.h>)
#import <AliVCSDK_BasicLive/AliVCSDK_BasicLive.h>
#define AIO_DEMO_USING_ALIVCSDK
#define AIO_DEMO_ENABLE_PLAYER
#define AIO_DEMO_ENABLE_LIVE

#elif __has_include(<AliVCSDK_StandardLive/AliVCSDK_StandardLive.h>)
#import <AliVCSDK_StandardLive/AliVCSDK_StandardLive.h>
#define AIO_DEMO_USING_ALIVCSDK
#define AIO_DEMO_ENABLE_PLAYER
#define AIO_DEMO_ENABLE_LIVE

#elif __has_include(<AliVCSDK_PremiumLive/AliVCSDK_PremiumLive.h>)
#import <AliVCSDK_PremiumLive/AliVCSDK_PremiumLive.h>
#define AIO_DEMO_USING_ALIVCSDK
#define AIO_DEMO_ENABLE_PLAYER
#define AIO_DEMO_ENABLE_LIVE

#elif __has_include(<AliVCSDK_UGC/AliVCSDK_UGC.h>)
#import <AliVCSDK_UGC/AliVCSDK_UGC.h>
#define AIO_DEMO_USING_ALIVCSDK
#define AIO_DEMO_ENABLE_UGSV
#define AIO_DEMO_ENABLE_PLAYER

#elif __has_include(<AliVCSDK_UGCPro/AliVCSDK_UGCPro.h>)
#import <AliVCSDK_UGCPro/AliVCSDK_UGCPro.h>
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
#endif

#endif /* AIOSdkHeader_h */
