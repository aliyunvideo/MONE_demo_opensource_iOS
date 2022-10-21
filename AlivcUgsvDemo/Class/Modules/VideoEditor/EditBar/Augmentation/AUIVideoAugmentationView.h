//
//  AUIVideoAugmentationView.h
//  AlivcUgsvDemo
//
//  Created by coder.pi on 2022/6/23.
//

#import <UIKit/UIKit.h>
#import "AlivcUgsvSDKHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUIVideoAugmentationInfo : NSObject
@property (nonatomic, assign) AliyunVideoAugmentationType type;
@property (nonatomic, assign) float value;
+ (AUIVideoAugmentationInfo *)InfoWithType:(AliyunVideoAugmentationType)type value:(float)value;
+ (AUIVideoAugmentationInfo *)InfoWithType:(AliyunVideoAugmentationType)type;
@end

typedef void(^OnSelectedDidChanged)(AUIVideoAugmentationInfo *);
@interface AUIVideoAugmentationView : UIView
@property (nonatomic, readonly) AUIVideoAugmentationInfo *current;
@property (nonatomic, copy) NSArray<AUIVideoAugmentationInfo *> *infos;
@property (nonatomic, copy) OnSelectedDidChanged onSelectedDidChanged;

- (BOOL)selectWithType:(AliyunVideoAugmentationType)type;
@end

NS_ASSUME_NONNULL_END
