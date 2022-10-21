//
//  AUILiveInteractiveParamConfigViewController.h
//  AlivcLivePusherDemo
//
//  Created by ISS013602000846 on 2022/8/24.
//  Copyright © 2022 TripleL. All rights reserved.
//

#import "AVBaseViewController.h"
#import "AUILiveInteractiveParamManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUILiveInteractiveParamConfigViewController : AVBaseViewController

@property (nonatomic, copy) void(^changeParam)(void);

@end

NS_ASSUME_NONNULL_END
