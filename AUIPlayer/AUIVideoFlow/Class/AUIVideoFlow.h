//
//  AUIVideoFlow.h
//  AUIVideoFlow
//
//  Created by ISS013602000846 on 2022/6/2.
//

#ifndef AUIVideoFlow_h
#define AUIVideoFlow_h

#import "AUIVideoFlowMacro.h"

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
#elif __has_include(<AliVCSDK_UGC/AliVCSDK_UGC.h>)
#import <AliVCSDK_UGC/AliVCSDK_UGC.h>
#elif __has_include(<AliVCSDK_UGCPro/AliVCSDK_UGCPro.h>)
#import <AliVCSDK_UGCPro/AliVCSDK_UGCPro.h>
#endif

#if __has_include(<AliyunPlayer/AliyunPlayer.h>)
#import <AliyunPlayer/AliyunPlayer.h>
#endif



#endif /* AUIVideoFlow_h */
