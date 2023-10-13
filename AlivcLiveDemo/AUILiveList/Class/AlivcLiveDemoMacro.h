//
//  AlivcLiveDemoMacro.h
//  AlivcLivePusherDemo
//
//  Created by zzy on 2022/5/31.
//  Copyright © 2022 TripleL. All rights reserved.
//

#ifndef AlivcLiveDemoMacro_h
#define AlivcLiveDemoMacro_h

#import "AUIFoundation.h"

#define AlivcLiveImage(key) AVGetImage(key, @"AlivcLive")
#define AlivcLiveString(key) AVGetString(key, @"AlivcLive")
#define AlivcLiveColor(key) AVGetColor(key, @"AlivcLive")

#if __has_include("AUILivePushConfigViewController.h")
#define ALIVC_LIVE_DEMO_ENABLE_CAMERAPUSH
#endif

#if __has_include("AUILivePushReplayKitConfigViewController.h")
#define ALIVC_LIVE_DEMO_ENABLE_RECORDPUSH
#endif

#if __has_include("AUILivePullTestViewController.h")
#define ALIVC_LIVE_DEMO_ENABLE_PULLPLAY
#endif

#if __has_include("AUILiveRtsPlayInputViewController.h")
#define ALIVC_LIVE_DEMO_ENABLE_RTSPLAY
#endif

#ifdef ALIVC_LIVE_INTERACTIVE_MODE
#if __has_include("AUILiveLinkMicConfigViewController.h")
#define ALIVC_LIVE_DEMO_ENABLE_LINKMIC
#endif

#if __has_include("AUILivePKConfigViewController.h")
#define ALIVC_LIVE_DEMO_ENABLE_PK
#endif
#endif

#endif /* AlivcLiveDemoMacro_h */
