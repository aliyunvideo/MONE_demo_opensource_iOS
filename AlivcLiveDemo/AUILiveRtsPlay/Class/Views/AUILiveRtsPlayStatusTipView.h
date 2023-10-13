//
//  AUILiveRtsPlayStatusTipView.h
//  AUILiveRtsPlay
//
//  Created by ISS013602000846 on 2022/11/17.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AUILiveRtsPlayStatusTipView : UIView

@property (nonatomic, strong) NSString *errMsg;
@property (nonatomic, strong) NSString *downgradeMsg;
- (void)showErrMsg:(BOOL)isShowErrMsg downgradeMsg:(BOOL)isShowDowngradeMsg;

@end

NS_ASSUME_NONNULL_END
