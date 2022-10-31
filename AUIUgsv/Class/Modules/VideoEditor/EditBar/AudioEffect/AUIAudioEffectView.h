//
//  AUIAudioEffectView.h
//  AlivcUgsvDemo
//
//  Created by coder.pi on 2022/6/23.
//

#import <UIKit/UIKit.h>
#import "AlivcUgsvSDKHeader.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^OnAUIAudioEffectDidChanged)(AliyunAudioEffectType);
@interface AUIAudioEffectView : UIView
@property (nonatomic, assign) AliyunAudioEffectType current;
@property (nonatomic, copy) OnAUIAudioEffectDidChanged onSelectedChanged;
@end

NS_ASSUME_NONNULL_END
