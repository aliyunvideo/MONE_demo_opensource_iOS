//
//  AUIAudioEffectPanel.h
//  AlivcUgsvDemo
//
//  Created by coder.pi on 2022/6/23.
//

#import "AVBaseControllPanel.h"

NS_ASSUME_NONNULL_BEGIN

@class AUIEditorActionManager;
@interface AUIAudioEffectPanel : AVBaseControllPanel
@property (nonatomic, weak) AUIEditorActionManager *actionManager;

+ (AUIAudioEffectPanel *)presentOnView:(UIView *)onView
                     withActionManager:(AUIEditorActionManager *)actionManager;
@end

NS_ASSUME_NONNULL_END
