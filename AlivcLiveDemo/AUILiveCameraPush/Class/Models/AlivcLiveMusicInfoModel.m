//
//  AlivcLiveMusicInfoModel.m
//  AlivcLivePusherTest
//
//  Created by lyz on 2017/11/23.
//  Copyright © 2017年 TripleL. All rights reserved.
//

#import "AlivcLiveMusicInfoModel.h"

@implementation AlivcLiveMusicInfoModel


- (instancetype)initWithMusicName:(NSString *)name
                        musicPath:(NSString *)path
                     musicDuation:(CGFloat)duration
                          isLocal:(BOOL)local{
    
    self = [super init];
    
    if (self) {
        _name = name;
        _path = path;
        _duration = duration;
        _isLocal = local;
    }
    return self;
}

@end
