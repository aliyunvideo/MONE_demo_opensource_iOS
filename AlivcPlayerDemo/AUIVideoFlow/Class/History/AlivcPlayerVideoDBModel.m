//
//  AlivcPlayerVideoDBModel.m
//  ApsaraVideo
//
//  Created by mengyehao on 2021/7/13.
//

#import "AlivcPlayerVideoDBModel.h"

@implementation AlivcPlayerVideoDBModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        _vaildTime = 30 * 24 * 60 * 60;
    }
    return self;
}

@end
