//
//  AUILiveInteractiveParamManager.m
//  AlivcLivePusherDemo
//
//  Created by ISS013602000846 on 2022/8/31.
//  Copyright © 2022 TripleL. All rights reserved.
//

#import "AUILiveInteractiveParamManager.h"

@implementation AUILiveInteractiveParamManager

+ (instancetype)manager {
    static AUILiveInteractiveParamManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[AUILiveInteractiveParamManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    if (self = [super init]) {
        [self reset];
    }
    return self;
}

- (void)reset {
    self.resolution = AlivcLivePushResolution540P;
    self.videoEncoderMode = AlivcLivePushVideoEncoderModeHard;
    self.audioEncoderMode = AlivcLivePushAudioEncoderModeSoft;
    self.audioOnly = NO;
    self.videoEncodeGop = AlivcLivePushVideoEncodeGOP_2;
    self.videoHardEncoderCodec = AlivcLivePushVideoEncoderModeHardCodecH264;
    self.isUserMainStream = NO;
    self.fps = AlivcLivePushFPS20;
    self.beautyOn = YES;
}

@end
