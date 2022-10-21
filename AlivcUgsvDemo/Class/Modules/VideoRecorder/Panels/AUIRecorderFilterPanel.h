//
//  AUIRecorderFilterPanel.h
//  AlivcUgsvDemo
//
//  Created by coder.pi on 2022/6/7.
//

#import "AVBaseControllPanel.h"
#import "AUIFilterModel.h"
#import "AUIFilterPanel.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, AUIRecorderFilterPanelType) {
    AUIRecorderFilterPanelTypeFilter,
    AUIRecorderFilterPanelTypeAnimationEffects,
};

@interface AUIRecorderFilterPanel : AUIFilterPanel
@property (nonatomic, readonly) AUIRecorderFilterPanelType filterType;
+ (AUIRecorderFilterPanel *) present:(UIView *)onView
                   onSelectedChanged:(OnFilterSelectedChanged)selectedChanged
                             forType:(AUIRecorderFilterPanelType)type;
@end

NS_ASSUME_NONNULL_END
