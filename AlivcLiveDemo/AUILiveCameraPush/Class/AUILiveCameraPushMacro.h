//
//  AUILiveCameraPushMacro.h
//  AUILiveCameraPush
//
//  Created by ISS013602000846 on 2022/6/7.
//

#ifndef AUILiveCameraPushMacro_h
#define AUILiveCameraPushMacro_h

#import "AUIFoundation.h"
#import "AUILiveCommon.h"

#define AUILiveCameraPushImage(key) AVGetImage(key, @"AUILiveCameraPush")
#define AUILiveCameraPushString(key) AVGetString(key, @"AUILiveCameraPush")
#define AUILiveCameraPushColor(key)  AVGetColor(key, @"AUILiveCameraPush")
#define AUILiveCameraPushData(key) [[NSBundle bundleWithPath:[NSBundle.mainBundle.resourcePath stringByAppendingPathComponent:@"AUILiveCameraPush.bundle/Data"]] pathForResource:key ofType:@""]

#endif /* AUILiveCameraPushMacro_h */
