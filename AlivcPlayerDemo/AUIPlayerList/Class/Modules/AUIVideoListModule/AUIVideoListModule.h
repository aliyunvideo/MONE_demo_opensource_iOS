//
//  AUIVideoListModule.h
//  AlivcPlayerDemo
//
//  Created by ISS013602000846 on 2022/5/30.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AUIVideoListModule : NSObject

- (instancetype)initWithSourceViewController:(UIViewController *)sourceVC;
- (void)openFunctionListPage;
- (void)openStandradListPage;

@end

NS_ASSUME_NONNULL_END
