//
//  AUIVideoTemplateEditTextInput.h
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/12/23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AUIVideoTemplateEditTextInput : UIView

+ (void)show:(NSString *)text completed:(void (^)(NSString *inputText))completed;

@end

NS_ASSUME_NONNULL_END
