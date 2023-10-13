//
//  AUICaptionInputView.m
//  AlivcUgsvDemo
//
//  Created by mengyehao on 2022/5/31.
//

#import "AUICaptionInputView.h"
#import "AUIFoundation.h"
#import "AUIUgsvMacro.h"



@interface AUICaptionInputView ()<UITextViewDelegate>
@property (nonatomic, strong) UITextView *textView;
@end


@implementation AUICaptionInputView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 8, frame.size.width, frame.size.height - 8 *2)];
        [self addSubview:_textView];
        _textView.textAlignment = NSTextAlignmentLeft;
        _textView.textColor = AUIFoundationColor(@"text_strong");
        _textView.font = AVGetRegularFont(12.0f);
        _textView.backgroundColor = AUIFoundationColor(@"fg_strong");
        _textView.delegate = self;
        _textView.scrollEnabled = YES;
        _textView.returnKeyType = UIReturnKeyDefault;
        _textView.autocorrectionType = UITextAutocorrectionTypeNo;
        _textView.spellCheckingType = UITextSpellCheckingTypeNo;
        _textView.layer.cornerRadius = _textView.av_height/2;
        _textView.textContainerInset = UIEdgeInsetsMake(6, 12, 0, 0);
        
        
        // _placeholderLabel
           UILabel *placeHolderLabel = [[UILabel alloc] init];
        placeHolderLabel.text = AUIUgsvGetString(@"Input words");
           placeHolderLabel.numberOfLines = 1;
        placeHolderLabel.textColor = AUIFoundationColor(@"text_weak");
           [placeHolderLabel sizeToFit];
           [_textView addSubview:placeHolderLabel];

           // same font
           placeHolderLabel.font = AVGetRegularFont(12.0f);

           [_textView setValue:placeHolderLabel forKey:@"_placeholderLabel"];
    }
    return self;
}

- (void)textViewResignFirstResponder
{
    if ([_textView isFirstResponder]) {
        [_textView resignFirstResponder];
    }
}

- (void)setTextViewText:(NSString *)text
{
    _textView.text = text;
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView
{
    
    UITextRange *selectedRange = [textView markedTextRange];
    NSString * newText = [textView textInRange:selectedRange];
    if(newText.length>0) {
        return;
    }

    if (self.onTextChanged) {
        self.onTextChanged(textView.text);
    }
}


@end
