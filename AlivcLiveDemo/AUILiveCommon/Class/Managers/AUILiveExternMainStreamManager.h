//
//  AUILiveExternMainStreamManager.h
//  AlivcLivePusherDemo
//
//  Created by ISS013602000846 on 2023/2/9.
//  Copyright © 2023 TripleL. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AUILiveExternMainStreamManager : NSObject

#ifdef ALIVC_LIVE_ENABLE_LIVEPUSHER
@property (nonatomic, strong) AlivcLivePushConfig *pushConfig;
@property (nonatomic, strong) AlivcLivePusher *livePusher;

- (void)addUserStream;
- (void)releaseUserStream;
#endif

@end

NS_ASSUME_NONNULL_END
