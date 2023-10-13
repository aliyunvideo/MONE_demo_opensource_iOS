//
//  AUIVideoTemplatePopMenu.h
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/12/22.
//

#import <UIKit/UIKit.h>
#import "AUIVideoTemplateEditMenuData.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUIVideoTemplatePopMenuItem : UIView

@property (nonatomic, strong) AUIVideoTemplateEditMenuData *data;

- (void)updateData;

@end

@interface AUIVideoTemplatePopMenuBar : UIView

+ (void)show:(UIView *)aboveView canCrop:(BOOL)canCrop canDelete:(BOOL)canDelete clickItemBlock:(void (^)(AUIVideoTemplateEditMenuType))clickItemblock;

@end

NS_ASSUME_NONNULL_END
