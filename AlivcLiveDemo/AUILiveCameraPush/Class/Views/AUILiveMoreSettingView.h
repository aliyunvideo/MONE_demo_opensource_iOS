//
//  AUILiveMoreSettingView.h
//  AlivcLiveDemo
//
//  Created by ISS013602000846 on 2022/7/5.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class AlivcLiveSettingConfig;
@interface AUILiveMoreSettingView : UIView

@property (nonatomic, copy) void(^newConfigAction)(AlivcLiveSettingConfig *config);

- (void)show;

@end

NS_ASSUME_NONNULL_END
