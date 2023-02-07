//
//  AUILiveSDKHeader.h
//  AUILiveSDKHeader
//
//  Created by zzy on 2022/5/31.
//  Copyright © 2022 TripleL. All rights reserved.
//

#ifndef AUILiveSDKHeader_h
#define AUILiveSDKHeader_h


#if __has_include(<AliVCSDK_Standard/AliVCSDK_Standard.h>)
#import <AliVCSDK_Standard/AliVCSDK_Standard.h>
#elif __has_include(<AliVCSDK_Premium/AliVCSDK_Premium.h>)
#import <AliVCSDK_Premium/AliVCSDK_Premium.h>
#elif __has_include(<AliVCSDK_InteractiveLive/AliVCSDK_InteractiveLive.h>)
#import <AliVCSDK_InteractiveLive/AliVCSDK_InteractiveLive.h>
#elif __has_include(<AliVCSDK_BasicLive/AliVCSDK_BasicLive.h>)
#import <AliVCSDK_BasicLive/AliVCSDK_BasicLive.h>
#elif __has_include(<AliVCSDK_StandardLive/AliVCSDK_StandardLive.h>)
#import <AliVCSDK_StandardLive/AliVCSDK_StandardLive.h>
#elif __has_include(<AliVCSDK_PremiumLive/AliVCSDK_PremiumLive.h>)
#import <AliVCSDK_PremiumLive/AliVCSDK_PremiumLive.h>
#endif

#if __has_include(<Queen/Queen.h>)
#import <Queen/Queen.h>
#endif

#if __has_include(<AliyunPlayer/AliyunPlayer.h>)
#import <AliyunPlayer/AliyunPlayer.h>
#endif

#if __has_include(<RtsSDK/rts_messages.h>)
#import <RtsSDK/rts_messages.h>
#endif

#if __has_include("AUILiveLinkMicConfigViewController.h")
#define ALIVC_LIVE_INTERACTIVE_MODE
#elif __has_include("AUILivePKConfigViewController.h")
#define ALIVC_LIVE_INTERACTIVE_MODE
#endif

#endif /* AUILiveSDKHeader_h */
