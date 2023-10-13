//
//  AUIPlayerFullScreenPlayViewController.h
//  ApsaraVideo
//
//  Created by Bingo on 2021/7/1.
//

#import "AVBaseViewController+AUIPlayerFlowSpecial.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUIPlayerFullScreenPlayViewController : AVBaseViewController

- (void)requestURL:(void (^)(BOOL success))completion;

@end

NS_ASSUME_NONNULL_END
