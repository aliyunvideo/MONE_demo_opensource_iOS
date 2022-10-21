//
//  AUILiveIntercativeLinkCustomerView.h
//  AUILiveCommon
//
//  Created by ISS013602000846 on 2022/7/22.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, AUILiveLinkCustomerStatus) {
    AUILiveLinkCustomerStatusNone = 0, // 未拉流
    AUILiveLinkCustomerStatusPulling,  // 正在拉流
    AUILiveLinkCustomerStatusError,    // 有报错
};

NS_ASSUME_NONNULL_BEGIN

@interface AUILiveIntercativeLinkCustomerView : UIView

@property (nonatomic, assign) AUILiveLinkCustomerStatus customerStatus;

- (UIView *)getPlayerShow;

@end

NS_ASSUME_NONNULL_END
