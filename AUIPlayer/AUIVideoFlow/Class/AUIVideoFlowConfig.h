//
//  AUIVideoFlowConfig.h
//  AUIVideoFlow
//
//  Created by ISS013602000846 on 2022/6/13.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AUIVideoFlowConfig : NSObject

- (void)didFinishLaunching;
- (BOOL)shouldFlowOrientation;
- (UIInterfaceOrientationMask)supportedInterfaceOrientation;

@end

NS_ASSUME_NONNULL_END
