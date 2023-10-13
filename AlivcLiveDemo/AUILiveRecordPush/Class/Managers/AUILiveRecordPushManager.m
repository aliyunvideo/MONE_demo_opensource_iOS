//
//  AUILiveRecordPushManager.m
//  AUILiveRecordPush
//
//  Created by zzy on 2023/7/27.
//  Copyright © 2022 com.alibaba. All rights reserved.
//

#import "AUILiveRecordPushManager.h"

#define AUILiveRecordPush_TipPageShowKey @"AUILiveRecordPush_TipPageShowKey"

@implementation AUILiveRecordPushManager

+ (BOOL)isTipPageShow {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (![[userDefaults objectForKey:AUILiveRecordPush_TipPageShowKey] isKindOfClass:[NSString class]]) {
        [self updateTipPageShow:YES];
    }
    
    return [[userDefaults objectForKey:AUILiveRecordPush_TipPageShowKey] boolValue];
}

+ (void)updateTipPageShow:(BOOL)isShow {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:[NSString stringWithFormat:@"%d", isShow] forKey:AUILiveRecordPush_TipPageShowKey];
}

@end
