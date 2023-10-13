//
//  AUIUgsvParamsViewController.h
//  AlivcUgsvDemo
//
//  Created by coder.pi on 2022/6/14.
//

#import "AVBaseViewController.h"
#import "AUIUgsvParamModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUIUgsvParamsViewController : AVBaseViewController
@property (nonatomic, copy) NSString *titleText;
@property (nonatomic, copy) NSString *confirmText;
@property (nonatomic, strong) AUIUgsvParamWrapper *paramWrapper;
@property (nonatomic, copy) void(^onConfirm)(AUIUgsvParamsViewController *);
@end

NS_ASSUME_NONNULL_END
