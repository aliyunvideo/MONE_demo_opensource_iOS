//
//  AUIEditorCaptionEditBar.h
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/6/9.
//

#import "AUIEditorMultiTimelineEditBar.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUIEditorCaptionEditBar : AUIEditorMultiTimelineEditBar
@property (nonatomic, copy) void(^onKeyboardShowChanged)(bool show, CGFloat originY);

- (void)textViewResignFirstResponder;

@end

NS_ASSUME_NONNULL_END
