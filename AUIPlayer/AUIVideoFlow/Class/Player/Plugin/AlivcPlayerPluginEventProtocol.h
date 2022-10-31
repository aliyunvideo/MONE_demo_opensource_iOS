//
//  AlivcPlayerPluginEventProtocol.h
//  ApsaraVideo
//
//  Created by mengyehao on 2021/7/8.
//

#import <Foundation/Foundation.h>
#import "AlivcPlayerEventCenterProtocol.h"

@protocol AlivcPlayerPluginEventProtocol <NSObject>

- (NSArray<NSNumber *> *)eventList;

- (void)onReceivedEvent:(AlivcPlayerEventCenterType)eventType userInfo:(NSDictionary *)userInfo;

@end
