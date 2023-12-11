//
//  AUIRecorderConfig.h
//  AlivcUgsvDemo
//
//  Created by coder.pi on 2022/6/5.
//

#import <Foundation/Foundation.h>
#import "AlivcUgsvSDKHeader.h"
#import "AUIUgsvParamBuilder.h"

NS_ASSUME_NONNULL_BEGIN

// 录制一般为竖屏，所以使用宽不使用高(P)
typedef NS_ENUM(NSUInteger, AUIRecorderHorizontalResolution) {
    AUIRecorderHorizontalResolution480,
    AUIRecorderHorizontalResolution540,
    AUIRecorderHorizontalResolution720,
    AUIRecorderHorizontalResolution1080,
};

typedef NS_ENUM(NSUInteger, AUIRecorderResolutionRatio) {
    AUIRecorderResolutionRatio_9_16,
    AUIRecorderResolutionRatio_3_4,
    AUIRecorderResolutionRatio_1_1,
    
    AUIRecorderResolutionRatioMax,
};

typedef NS_ENUM(NSUInteger, AUIRecorderMixType) {
    AUIRecorderMixTypeLeftRight = 0,  // 左合拍视频，右拍摄视频
    AUIRecorderMixTypeRightLeft,
    AUIRecorderMixTypeTopBottom,
    AUIRecorderMixTypeBottomTop,
    AUIRecorderMixTypeBackFront,
    AUIRecorderMixTypeFrontBack,
};

@interface AUIRecorderConfig : NSObject
@property (nonatomic, strong) AliyunRecorderVideoConfig *videoConfig;
@property (nonatomic, assign) AUIRecorderHorizontalResolution horizontalResolution;
@property (nonatomic, assign) AUIRecorderResolutionRatio resolutionRatio;
@property (nonatomic, assign) BOOL mergeOnFinish;
@property (nonatomic, assign) BOOL deleteVideoClipsOnExit;

@property (nonatomic, assign) NSTimeInterval minDuration;
@property (nonatomic, assign) NSTimeInterval maxDuration;

@property (nonatomic, copy) NSString *waterMarkPath;
@property (nonatomic, assign) CGRect waterFrame;

@property (nonatomic, assign, readonly) BOOL isMixRecord;  // 是否合拍
@property (nonatomic, copy, nullable) NSString *mixVideoFilePath;
@property (nonatomic, assign) BOOL isUsingAEC;
@property (nonatomic, assign) AUIRecorderMixType mixType;
@property (nonatomic, assign, readonly) CGRect mixVideoFrame; // 合拍视图布局
@property (nonatomic, assign, readonly) int mixVideoZPosition; // 合拍视图层次
@property (nonatomic, assign, readonly) CGRect cameraFrame;  // 拍摄视图布局
@property (nonatomic, assign, readonly) int cameraZPosition;  // 拍摄视图层次

- (AUIUgsvParamBuilder *)paramBuilder;
- (AUIUgsvParamBuilder *)mixRecordParamBuilder;

@end

NS_ASSUME_NONNULL_END
