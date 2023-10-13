//
//  AUICaptionControllPanel.h
//  AlivcUgsvDemo
//
//  Created by mengyehao on 2022/5/31.
//

#import "AVBaseControllPanel.h"
#import "AUIEditorActionManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUICaptionControllPanel : AVBaseControllPanel
@property (nonatomic, weak) AEPCaptionTrack *aep;
@property (nonatomic, weak) AUIEditorActionManager *actionManger;
@property (nonatomic, copy) void(^onKeyboardShowChanged)(bool show, CGFloat originY);

- (void)textViewResignFirstResponder;
@end

NS_ASSUME_NONNULL_END
