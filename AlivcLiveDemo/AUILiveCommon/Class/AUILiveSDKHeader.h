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
#define ALIVC_LIVE_ENABLE_LIVEPUSHER
#define ALIVC_LIVE_ENABLE_QUEEN

#elif __has_include(<AliVCSDK_InteractiveLive/AliVCSDK_InteractiveLive.h>)
#import <AliVCSDK_InteractiveLive/AliVCSDK_InteractiveLive.h>
#define ALIVC_LIVE_ENABLE_LIVEPUSHER
#define ALIVC_LIVE_ENABLE_QUEEN

#elif __has_include(<AliVCSDK_BasicLive/AliVCSDK_BasicLive.h>)
#import <AliVCSDK_BasicLive/AliVCSDK_BasicLive.h>
#define ALIVC_LIVE_ENABLE_LIVEPUSHER
#define ALIVC_LIVE_ENABLE_QUEEN

#elif __has_include(<AlivcLivePusher/AlivcLivePusherHeader.h>)
#import <AlivcLivePusher/AlivcLivePusherHeader.h>
#define ALIVC_LIVE_ENABLE_LIVEPUSHER

#endif




#if __has_include(<Queen/Queen.h>)
#import <Queen/Queen.h>
#define ALIVC_LIVE_ENABLE_QUEEN
#define ALIVC_LIVE_ENABLE_QUEEN_PRO
#endif

#if __has_include(<AliyunQueenUIKit/AliyunQueenUIKit.h>)
#import <AliyunQueenUIKit/AliyunQueenUIKit.h>
#define ALIVC_LIVE_ENABLE_QUEENUIKIT
#endif

#if __has_include(<AliyunPlayer/AliyunPlayer.h>)
#import <AliyunPlayer/AliyunPlayer.h>
#endif

#if __has_include(<RtsSDK/rts_messages.h>)
#import <RtsSDK/rts_messages.h>
#endif

#if __has_include(<AliVCSDK_Standard/AlivcLivePlayer.h>)
#define ALIVC_LIVE_INTERACTIVE_MODE

#elif __has_include(<AliVCSDK_InteractiveLive/AlivcLivePlayer.h>)
#define ALIVC_LIVE_INTERACTIVE_MODE

#elif __has_include(<AliVCSDK_BasicLive/AlivcLivePlayer.h>)
#define ALIVC_LIVE_INTERACTIVE_MODE

#elif __has_include(<AlivcLivePusher/AlivcLivePlayer.h>)
#import <AlivcLivePusher/AlivcLivePlayer.h>
#define ALIVC_LIVE_INTERACTIVE_MODE
#endif

#endif /* AUILiveSDKHeader_h */
