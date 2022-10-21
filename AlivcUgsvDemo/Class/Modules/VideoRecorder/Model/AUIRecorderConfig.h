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

@interface AUIRecorderConfig : NSObject
@property (nonatomic, strong) AliyunRecorderVideoConfig *videoConfig;
@property (nonatomic, assign) AUIRecorderHorizontalResolution horizontalResolution;
@property (nonatomic, assign) AUIRecorderResolutionRatio resolutionRatio;
@property (nonatomic, assign) BOOL mergeOnFinish;
@property (nonatomic, assign) BOOL deleteVideoClipsOnExit;

@property (nonatomic, assign) NSTimeInterval minDuration;
@property (nonatomic, assign) NSTimeInterval maxDuration;
@property (nonatomic, readonly) BOOL isUsingAEC; // 暂时没有混音场景，设置为NO，暂不可改
@property (nonatomic, readonly) BOOL isUsingCamera; // 暂时只有摄像头，设置为YES，暂不可改
@property (nonatomic, readonly) CGRect cameraFrame; // 后续根据合拍、多源、单源等类型内置设置，暂时只有全屏
@property (nonatomic, copy) NSString *waterMarkPath;
@property (nonatomic, assign) CGRect waterFrame;

- (AUIUgsvParamBuilder *)paramBuilder;
@end

NS_ASSUME_NONNULL_END
