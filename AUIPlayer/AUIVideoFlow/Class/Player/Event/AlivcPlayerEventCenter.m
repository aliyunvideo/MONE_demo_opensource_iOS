//
//  AlivcPlayerEventCenter.m
//  AFNetworking
//
//  Created by mengyehao on 2021/7/2.
//

#import "AlivcPlayerEventCenter.h"
#import "AlivcPlayerPluginEventProtocol.h"

@interface AlivcPlayerEventCenter ()
@property (nonatomic, strong) NSMutableArray<id<AlivcPlayerPluginEventProtocol>> *observerList;
@end

@implementation AlivcPlayerEventCenter

//- (void)addNotification
//{
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onOrientationDidChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
//}
//
//- (void)onOrientationDidChanged:(NSNotification *)notification
//{
//    UIDevice* device = notification.object;
//    if (![device isKindOfClass:[UIDevice class]]) {
//        return;
//    }
//    NSLog(@"notification:::%@", @(device.orientation));
//
//    [self.observerList enumerateObjectsUsingBlock:^(id<AlivcPlayerPluginEventProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        if ([obj respondsToSelector:@selector(onCurrentDeviceOrientationChanged:)]) {
//            [obj onCurrentDeviceOrientationChanged:device.orientation];
//        }
//    }];
//
//
//}

- (NSMutableArray<id<AlivcPlayerPluginEventProtocol>> *)observerList
{
    if (!_observerList) {
        _observerList = [[NSMutableArray alloc] init];
    }
    return _observerList;
}

#pragma mark - AlivcPlayerEventCenterProtocol

- (void)addEventObserver:(id<AlivcPlayerPluginEventProtocol>)observer
{
    if (observer && ![self.observerList containsObject:observer]) {
        [self.observerList addObject:observer];
    }
}

- (void)removeEventObserver:(id<AlivcPlayerPluginEventProtocol>)observer
{
    
    if (observer) {
        [self.observerList removeObject:observer];
    }
}

- (void)dispatchEvent:(AlivcPlayerEventCenterType)eventType userInfo:(NSDictionary *)userInfo
{
    [self.observerList enumerateObjectsUsingBlock:^(id<AlivcPlayerPluginEventProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray *eventList = [obj eventList];
        NSNumber *evtent = @(eventType);
        if ([eventList containsObject:evtent]) {
            [obj onReceivedEvent:eventType userInfo:userInfo];
        }
    }];
}

@end
