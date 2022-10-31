//
//  AlivcLiveMusicInfoModel.h
//  AlivcLivePusherTest
//
//  Created by lyz on 2017/11/23.
//  Copyright © 2017年 TripleL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AlivcLiveMusicInfoModel : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *path;
@property (nonatomic, assign) CGFloat duration;
@property (nonatomic, assign) BOOL isLocal;// 本地资源 or 网络资源


- (instancetype)initWithMusicName:(NSString *)name
                        musicPath:(NSString *)path
                     musicDuation:(CGFloat)duration
                          isLocal:(BOOL)local;

@end
