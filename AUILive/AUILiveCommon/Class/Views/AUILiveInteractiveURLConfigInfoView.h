//
//  AUILiveInteractiveURLConfigInfoView.h
//  AlivcLivePusherDemo
//
//  Created by ISS013602000846 on 2022/9/7.
//  Copyright © 2022 TripleL. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AUILiveInteractiveURLConfigInfoView : UIView

@property (nonatomic, strong) NSString *themeName;
@property (nonatomic, copy) void(^modifyConfig)(void);

- (void)showAppID:(NSString *)appID appKey:(NSString *)appKey playDomain:(NSString *)playDomain;

@end

NS_ASSUME_NONNULL_END
