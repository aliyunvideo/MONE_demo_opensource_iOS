//
//  AUIVideoFlowModule.h
//  AlivcPlayerDemo
//
//  Created by ISS013602000846 on 2022/6/2.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AUIVideoFlowModule : NSObject

- (instancetype)initWithSourceViewController:(UIViewController *)sourceVC;
- (void)open;

@end

NS_ASSUME_NONNULL_END
