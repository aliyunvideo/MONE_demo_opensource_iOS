//
//  AUILiveURLConfigManager.h
//  AlivcLivePusherDemo
//
//  Created by ISS013602000846 on 2022/9/6.
//  Copyright © 2022 TripleL. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AUILiveURLConfigManager : NSObject

/**
 *  AppID
 */
@property (nonatomic, strong) NSString *appID;

/**
 *  AppKey
 */
@property (nonatomic, strong) NSString *appKey;

/**
 *  播流域名
 */
@property (nonatomic, strong) NSString *playDomain;

+ (instancetype)manager;
- (BOOL)haveSigGenerateConfig;
- (BOOL)haveConfig;

@end

NS_ASSUME_NONNULL_END
