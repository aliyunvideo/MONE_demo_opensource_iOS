//
//  AUIVideoAugmentationPanel.h
//  AlivcUgsvDemo
//
//  Created by coder.pi on 2022/6/23.
//

#import "AVBaseControllPanel.h"

NS_ASSUME_NONNULL_BEGIN

@class AUIEditorActionManager;
@interface AUIVideoAugmentationPanel : AVBaseControllPanel
@property (nonatomic, weak) AUIEditorActionManager *actionManager;

+ (AUIVideoAugmentationPanel *)presentOnView:(UIView *)onView
                           withActionManager:(AUIEditorActionManager *)actionManager;
@end

NS_ASSUME_NONNULL_END
