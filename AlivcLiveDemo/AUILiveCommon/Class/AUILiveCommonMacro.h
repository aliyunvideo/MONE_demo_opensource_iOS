//
//  AUILiveCommonMacro.h
//  AUILiveCommon
//
//  Created by ISS013602000846 on 2022/6/7.
//

#ifndef AUILiveCommonMacro_h
#define AUILiveCommonMacro_h

#import "AUIFoundation.h"

#define AUILiveCommonImage(key) AVGetImage(key, @"AUILiveCommon")
#define AUILiveCommonString(key) AVGetString(key, @"AUILiveCommon")
#define AUILiveCommonColor(key) AVGetColor(key, @"AUILiveCommon")
#define AUILiveCommonData(key) [[NSBundle bundleWithPath:[NSBundle.mainBundle.resourcePath stringByAppendingPathComponent:@"AUILiveCommon.bundle/Data"]] pathForResource:key ofType:@""]

#define AlivcScreenWidth  [UIScreen mainScreen].bounds.size.width
#define AlivcScreenHeight  [UIScreen mainScreen].bounds.size.height
#define AlivcSizeWidth(W) (W*(AlivcScreenWidth)/320)
#define AlivcSizeHeight(H) (H*(AlivcScreenHeight)/568)

#define AlivcUserDefaultsIndentifierFirst @"AlivcUserDefaultsIndentifierFirst"

#endif /* AUILiveCommonMacro_h */
