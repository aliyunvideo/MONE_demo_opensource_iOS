//
//  AUIVideoTemplateEditMenuItem.h
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/12/21.
//

#import <UIKit/UIKit.h>
#import "AUIVideoTemplateEditMenuData.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUIVideoTemplateEditMenuItem : UIView

@property (nonatomic, strong) AUIVideoTemplateEditMenuData *data;

- (void)updateData;

@end


@interface AUIVideoTemplateEditMenuBar : UIView

- (instancetype)initWithFrame:(CGRect)frame itemTypes:(NSArray<NSNumber *> *)types selectedBlock:(void(^)(AUIVideoTemplateEditMenuType type))selectedBlock;

@property (nonatomic, assign, readonly) AUIVideoTemplateEditMenuType selectedType;

@end

NS_ASSUME_NONNULL_END
