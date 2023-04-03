//
//  AUIVideoListMacro.h
//  AUIVideoList
//
//  Created by ISS013602000846 on 2022/6/7.
//

#ifndef AUIVideoListMacro_h
#define AUIVideoListMacro_h

#import "AUIFoundation.h"
#import <MJRefresh/MJRefresh.h>
#import <SDWebImage/SDWebImage.h>

#define AUIVideoListImage(key) AVGetImage(key, @"AUIVideoList")
#define AUIVideoListString(key) AVGetString(key, @"AUIVideoList")
#define AUIVideoListColor(key)  AVGetColor(key, @"AUIVideoList")
#define AUIVideoListAccessibilityStr(key) [@"AUIVideoList_" stringByAppendingString:key]

#endif /* AUIVideoListMacro_h */
