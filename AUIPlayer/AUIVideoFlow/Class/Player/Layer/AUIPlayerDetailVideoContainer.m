//
//  AUIPlayerDetailVideoContainer.m
//  ApsaraVideo
//
//  Created by mengyehao on 2021/7/21.
//

#import "AUIPlayerDetailVideoContainer.h"

@implementation AUIPlayerDetailVideoContainer

- (NSDictionary<NSString *, NSNumber*> *)pluginMap
{
    return   @{
        @"AlivcPlayerGesturePlugin":@0,
        @"AlivcPlayerPlayControlPlugin":@0,
        @"AlivcPlayerBottomToolPlugin":@1,
        @"AlivcPlayerLandscapePlugin":@0,
        @"AlivcPlayerBackgroudModePlugin":@1,
        @"AlivcPlayerListenPlugin":@2,
        // zzy 20220630 暂时注释功能
        // @"AlivcPlayerTopToolPlugin":@1,
        // zzy 20220630 暂时注释功能
    };
}

- (int)playscene
{
    return 1;
}

@end
