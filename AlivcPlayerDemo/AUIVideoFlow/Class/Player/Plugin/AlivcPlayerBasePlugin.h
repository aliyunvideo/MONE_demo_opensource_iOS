//
//  AlivcPlayerBasePlugin.h
//  AFNetworking
//
//  Created by mengyehao on 2021/7/2.
//

#import <UIKit/UIKit.h>
#import "AlivcPlayerPluginEventProtocol.h"


typedef NS_ENUM(NSUInteger, AlivcPlayerBasePluginLoadOption) {
    AlivcPlayerBasePluginLoadOptionNormal,
    AlivcPlayerBasePluginLoadOptionDelay,
    AlivcPlayerBasePluginLoadOptionLazy,
};

@interface AlivcPlayerBasePlugin : NSObject<AlivcPlayerPluginEventProtocol>

- (NSString *)pluginId;

- (UIView *)containerView;

- (NSInteger)level;

- (void)onInstall;

- (void)onUnInstall;

@end


