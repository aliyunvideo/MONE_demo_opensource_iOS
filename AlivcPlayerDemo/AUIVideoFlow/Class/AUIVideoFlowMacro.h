//
//  AUIVideoFlowMacro.h
//  AUIVideoFlow
//
//  Created by ISS013602000846 on 2022/6/2.
//

#ifndef AUIVideoFlowMacro_h
#define AUIVideoFlowMacro_h

#import "AUIFoundation.h"
#import "AlivcPlayerAsset.h"
#import <Masonry/Masonry.h>
#import <MJRefresh/MJRefresh.h>
#import <SDWebImage/SDWebImage.h>
#import <MBProgressHUD/MBProgressHUD.h>

#define AUIVideoFlowImage(key) AVGetImage(key, @"AUIVideoFlow")
#define AUIVideoFlowString(key) AVGetString(key, @"AUIVideoFlow")
#define AUIVideoFlowColor(key)  AVGetColor(key, @"AUIVideoFlow")
#define AUIVideoFlowAccessibilityStr(key) [@"AUIVideoFlow_" stringByAppendingString:key]

#endif /* AUIVideoFlowMacro_h */
