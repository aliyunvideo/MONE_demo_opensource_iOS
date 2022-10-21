//
//  AUIVolumePanel.h
//  AlivcUgsvDemo
//
//  Created by coder.pi on 2022/6/22.
//

#import "AVBaseControllPanel.h"

NS_ASSUME_NONNULL_BEGIN

@class AUIEditorActionManager;

@interface AUIVolumePanel : AVBaseControllPanel
@property (nonatomic, weak) AUIEditorActionManager *actionManager;

+ (AUIVolumePanel *)presentOnView:(UIView *)onView
                withActionManager:(AUIEditorActionManager *)actionManager;
+ (AUIVolumePanel *)presentWithActionManager:(AUIEditorActionManager *)actionManager;

@end

NS_ASSUME_NONNULL_END
