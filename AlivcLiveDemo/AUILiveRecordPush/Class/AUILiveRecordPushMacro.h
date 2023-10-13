//
//  AUILiveRecordPushMacro.h
//  AUILiveRecordPush
//
//  Created by ISS013602000846 on 2022/6/7.
//

#ifndef AUILiveRecordPushMacro_h
#define AUILiveRecordPushMacro_h

#import "AUIFoundation.h"
#import "AUILiveCommon.h"

#define AUILiveRecordPushImage(key) AVGetImage(key, @"AUILiveRecordPush")
#define AUILiveRecordPushString(key) AVGetString(key, @"AUILiveRecordPush")
#define AUILiveRecordPushColor(key)  AVGetColor(key, @"AUILiveRecordPush")

#endif /* AUILiveRecordPushMacro_h */
