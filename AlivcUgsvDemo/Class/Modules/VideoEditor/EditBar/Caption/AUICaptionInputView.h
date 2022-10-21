//
//  AUICaptionInputView.h
//  AlivcUgsvDemo
//
//  Created by mengyehao on 2022/5/31.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AUICaptionInputView : UIView

@property (nonatomic, copy) void(^onTextChanged)(NSString *);


- (void)textViewResignFirstResponder;

- (void)setTextViewText:(NSString *)text;

@end

NS_ASSUME_NONNULL_END
