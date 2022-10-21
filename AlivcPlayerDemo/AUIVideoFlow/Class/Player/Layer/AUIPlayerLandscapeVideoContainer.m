//
//  AUIPlayerLandscapeVideoContainer.m
//  ApsaraVideo
//
//  Created by mengyehao on 2021/7/21.
//

#import "AUIPlayerLandscapeVideoContainer.h"

@implementation AUIPlayerLandscapeVideoContainer

- (NSDictionary<NSString *, NSNumber*> *)pluginMap
{
    return   @{
        @"AlivcPlayerGesturePlugin":@0,
        @"AlivcPlayerPlayControlPlugin":@0,
        @"AlivcPlayerBottomToolPlugin":@1,
        @"AlivcPlayerLandscapePlugin":@1,
        @"AlivcPlayerBackgroudModePlugin":@1,
        @"AlivcPlayerListenPlugin":@2,
        @"AlivcPlayerLockPlugin":@1,
        @"AlivcPlayerTopToolPlugin":@1,
        @"AlivcPlayerRecommendPlugin":@2,
    };
}

- (int)playscene
{
    return 2;
}


@end
