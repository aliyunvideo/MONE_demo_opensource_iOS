//
//  AUILiveRecordPushManager.h
//  AUILiveRecordPush
//
//  Created by zzy on 2023/7/27.
//  Copyright © 2022 com.alibaba. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AUILiveRecordPushManager : NSObject

+ (BOOL)isTipPageShow;
+ (void)updateTipPageShow:(BOOL)isShow;

@end
