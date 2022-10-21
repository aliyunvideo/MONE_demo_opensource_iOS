//
//  AUILiveCameraPublishViewController.h
//  AlivcLiveCaptureDev
//
//  Created by TripleL on 17/7/10.
//  Copyright © 2017年 Alivc. All rights reserved.
//

#import "AVBaseViewController.h"

@class AlivcLivePushConfig;

@interface AUILiveCameraPushViewController : UIViewController

// URL
@property (nonatomic, strong) NSString *pushURL;
// SDK
@property (nonatomic, strong) AlivcLivePushConfig *pushConfig;

@property (nonatomic, assign) BOOL beautyOn;

@property (nonatomic, assign) BOOL isUseAsyncInterface;
@property (nonatomic, copy) NSString *authDuration;
@property (nonatomic, copy) NSString *authKey;

@property (nonatomic, assign) BOOL isUserMainStream;

@end
