//
//  AlivcPlayerDemoMacro.h
//  AlivcPlayerDemo
//
//  Created by ISS013602000846 on 2022/5/31.
//

#ifndef AlivcPlayerDemoMacro_h
#define AlivcPlayerDemoMacro_h

#import "AUIFoundation.h"

#define AlivcPlayerImage(key) AVGetImage(key, @"AlivcPlayer")
#define AlivcPlayerString(key) AVGetString(key, @"AlivcPlayer")
#define AlivcPlayerData(key) [[NSBundle bundleWithPath:[NSBundle.mainBundle.resourcePath stringByAppendingPathComponent:@"AlivcPlayer.bundle/Data"]] pathForResource:key ofType:@""]


#if __has_include("AUIVideoFlowViewController.h")
#define ALIVC_PLAYER_DEMO_ENABLE_VIDEOFLOW
#endif

#if __has_include("AUIPlayerFullScreenPlayViewController.h")
#define ALIVC_PLAYER_DEMO_ENABLE_VIDEOFULLSCREEN
#endif

#if __has_include("AUIVideoFunctionListView.h")
#define ALIVC_PLAYER_DEMO_ENABLE_ENABLE_VIDEOLIST_FUNCTIONLIST
#endif

#if __has_include("AUIVideoStandradListView.h")
#define ALIVC_PLAYER_DEMO_ENABLE_ENABLE_VIDEOLIST_STANDRADLIST
#endif

#endif /* AlivcPlayerDemoMacro_h */
