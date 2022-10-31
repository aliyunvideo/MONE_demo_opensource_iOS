//
//  AUIRecorderWrapper.h
//  AlivcUgsvDemo
//
//  Created by coder.pi on 2022/6/5.
//

#import <Foundation/Foundation.h>
#import "AlivcUgsvSDKHeader.h"
#import "AUIRecorderConfig.h"
#import "AUIRecorderCameraWrapper.h"

NS_ASSUME_NONNULL_BEGIN

@class AUIRecorderWrapper;
@protocol AUIRecorderWrapperDelegate <NSObject>
- (void) onAUIRecorderWrapper:(AUIRecorderWrapper *)recorderWrapper stateDidChange:(AliyunRecorderState)state;
- (void) onAUIRecorderWrapper:(AUIRecorderWrapper *)recorderWrapper progressWithDuration:(NSTimeInterval)duration;
- (void) onAUIRecorderWrapperWantFinish:(AUIRecorderWrapper *)recorderWrapper;
- (void) onAUIRecorderWrapperDidCancel:(AUIRecorderWrapper *)recorderWrapper;
@end

@interface AUIRecorderWrapper : NSObject
@property (nonatomic, weak) id<AUIRecorderWrapperDelegate> delegate;
@property (nonatomic, readonly) AUIRecorderConfig *config;
@property (nonatomic, weak, readonly) UIView *containerView;
@property (nonatomic, readonly) AliyunRecorder *recorder;
@property (nonatomic, readonly) AliyunRecorderState recorderState;
@property (nonatomic, readonly) NSTimeInterval duration;
@property (nonatomic, readonly) NSArray<NSNumber *> *partDurations;
@property (nonatomic, assign) BOOL enabledPreview;
@property (nonatomic, readonly) AUIRecorderCameraWrapper *camera;

- (instancetype)initWithConfig:(AUIRecorderConfig *)config containerView:(UIView *)containerView;
- (BOOL)changeResolutionRatio:(AUIRecorderResolutionRatio)ratio;

- (void)startRecord;
- (void)stopRecord;
- (void)finishRecord:(void(^)(NSString *taskPath, NSString *outputPath, NSError *error))completion;
- (void)finishRecordSkipMerge:(void(^)(NSString *taskPath, NSError *error))completion;
- (void)deleteLastPart;

- (void)applyBGMWithPath:(NSString *)path
               beginTime:(NSTimeInterval)beginTime
                duration:(NSTimeInterval)duration;
- (void)removeBGM;

#ifdef INCLUDE_QUEEN
- (void)showBeautyPanel;
- (void)selectedDefaultBeautyPanel;
#endif // INCLUDE_QUEEN
@end

NS_ASSUME_NONNULL_END
