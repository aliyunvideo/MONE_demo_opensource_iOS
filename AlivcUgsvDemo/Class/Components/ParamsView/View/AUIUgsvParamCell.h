//
//  AUIUgsvParamCell.h
//  AlivcUgsvDemo
//
//  Created by coder.pi on 2022/6/13.
//

#import <UIKit/UIKit.h>
#import "AUIUgsvParamModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUIUgsvParamCell : UITableViewCell
@property (nonatomic, strong) AUIUgsvParamItemModel *model;
@end

@class AUIUgsvParamTextFieldCell;
@protocol AUIUgsvParamTextFieldCellDelegate <NSObject>
- (void) onAUIUgsvParamTextFieldCell:(AUIUgsvParamTextFieldCell *)cell
                becomeFirstResponder:(UITextField *)textField;
@end

@interface AUIUgsvParamTextFieldCell : AUIUgsvParamCell
@property (nonatomic, weak) id<AUIUgsvParamTextFieldCellDelegate> textFieldDelegate;
@end

@interface AUIUgsvParamSwitchCell : AUIUgsvParamCell
@end

@interface AUIUgsvParamRadioCell : AUIUgsvParamCell
@end

NS_ASSUME_NONNULL_END
