//
//  AUIPlayerFeedListVideoContainer.m
//  ApsaraVideo
//
//  Created by mengyehao on 2021/7/21.
//

#import "AUIPlayerFeedListVideoContainer.h"

@implementation AUIPlayerFeedListVideoContainer


- (NSDictionary<NSString *, NSNumber*> *)pluginMap
{
    return   @{
        @"AlivcPlayerGesturePlugin":@0,
        // zzy 20220630 信息流播放有几率出现滑动崩溃修改
        // @"AlivcPlayerPlayControlPlugin":@0,
        @"AlivcPlayerPlayControlPlugin":@1,
        // zzy 20220630 信息流播放有几率出现滑动崩溃修改
        @"AlivcPlayerBottomToolPlugin":@1,
        @"AlivcPlayerLandscapePlugin":@1,
        @"AlivcPlayerBackgroudModePlugin":@1,
        @"AlivcPlayerListenPlugin":@2,

    };
}

- (int)playscene
{
    return 0;
}

@end
