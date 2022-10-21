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

#endif /* AlivcPlayerDemoMacro_h */
