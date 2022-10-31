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

#define AlivcScreenWidth  [UIScreen mainScreen].bounds.size.width
#define AlivcScreenHeight  [UIScreen mainScreen].bounds.size.height
#define AlivcSizeWidth(W) (W*(AlivcScreenWidth)/320)
#define AlivcSizeHeight(H) (H*(AlivcScreenHeight)/568)

#define AlivcTextPushURL @"artp://testdomain.com/app/name"


//#define AlivcTextPushURL @"rtmp://liveng-push.alicdn.com/mediaplatform/7f6b02b5-d78d-48d3-b6a0-51e62b442284?auth_key=1561036040-0-0-a9f7a9a2477f6d8769886d7cb2c4cf73"

#define AlivcUserDefaultsIndentifierFirst @"AlivcUserDefaultsIndentifierFirst"

#endif /* AUILiveCommonMacro_h */
