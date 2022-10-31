//
//  AUIAepHelper.h
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/6/23.
//

#import <Foundation/Foundation.h>
#import "AlivcUgsvSDKHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUIAepHelper : NSObject

+ (AEPEffectTimeTrack *)aepTimeEffect:(AliyunEditor *)editor;
+ (CGFloat)timeSpeed:(AliyunEditor *)editor;

+ (AEPVideoTrackClip *)aepVideo:(AliyunEditor *)editor playTime:(NSTimeInterval)playTime;

@end

NS_ASSUME_NONNULL_END
