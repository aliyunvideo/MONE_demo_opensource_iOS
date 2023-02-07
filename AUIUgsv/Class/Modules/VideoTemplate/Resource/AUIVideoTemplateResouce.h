//
//  AUIVideoTemplateResouce.h
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/12/14.
//

#import <UIKit/UIKit.h>
#import "AUIVideoTemplateItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUIVideoTemplateResouce : NSObject

+ (void)checkResouce:(AUIVideoTemplateItem *)item onVC:(UIViewController *)onVC completed:(void(^)(NSString *templatePath))completed;

@end

NS_ASSUME_NONNULL_END
