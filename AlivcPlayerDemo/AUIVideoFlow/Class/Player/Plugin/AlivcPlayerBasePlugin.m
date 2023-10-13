//
//  AlivcPlayerBasePlugin.m
//  AFNetworking
//
//  Created by mengyehao on 2021/7/2.
//

#import "AlivcPlayerBasePlugin.h"
#import "AlivcPlayerManager.h"

@implementation AlivcPlayerBasePlugin

- (NSString *)pluginId
{
    return NSStringFromClass(self.class);
}

- (UIView *)containerView
{
    return [[AlivcPlayerManager manager] viewAtLevel:self.level];
}

- (NSInteger)level
{
    return 1;
}

- (void)onInstall
{
    [[AlivcPlayerManager manager] addEventObserver:self];

}

- (void)onUnInstall
{
    [[AlivcPlayerManager manager] removeEventObserver:self];
}

- (NSArray<NSNumber *> *)eventList
{
    return nil;
}

- (void)onReceivedEvent:(AlivcPlayerEventCenterType)eventType userInfo:(NSDictionary *)userInfo
{
    
}

@end
