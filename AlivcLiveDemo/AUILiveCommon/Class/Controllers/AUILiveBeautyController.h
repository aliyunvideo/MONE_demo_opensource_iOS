//
//  AUILiveBeautyController.h
//  AlivcLivePusherDemo
//
//  Created by zhangjc on 2022/5/7.
//  Copyright © 2022 TripleL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AUILiveSDKHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUILiveBeautyController : NSObject

#ifdef ALIVC_LIVE_ENABLE_QUEENUIKIT
+ (AUILiveBeautyController *)sharedInstance;

- (void)setupBeautyController:(BOOL)processPixelBuffer;
- (void)detectVideoBuffer:(long)buffer withWidth:(int)width withHeight:(int)height withVideoFormat:(AlivcLivePushVideoFormat)videoFormat withPushOrientation:(AlivcLivePushOrientation)pushOrientation;
- (int)processGLTextureWithTextureID:(int)textureID withWidth:(int)width withHeight:(int)height;
- (BOOL)processPixelBuffer:(CVPixelBufferRef)pixelBufferRef withPushOrientation:(AlivcLivePushOrientation)pushOrientation;
- (void)destroyBeautyController;

- (void)setupBeautyControllerUIWithView:(UIView *)view;
- (void)showPanel:(BOOL)animated;
- (void)destroyBeautyControllerUI;
#endif

@end

NS_ASSUME_NONNULL_END
