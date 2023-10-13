//
//  AlivcPlayerAccountManager.m
//  ApsaraVideo
//
//  Created by mengyehao on 2021/7/14.
//

#import "AlivcPlayerAccountManager.h"

@implementation AlivcPlayerAccountManager

+ (instancetype)manager
{
    static AlivcPlayerAccountManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _currentUserId = @"20212021";
    }
    return self;
}


@end
