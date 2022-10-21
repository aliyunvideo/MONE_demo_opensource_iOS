//
//  AUILiveInputNumberAlert.h
//  AUILiveLinkMic
//
//  Created by ISS013602000846 on 2022/8/2.
//

#import <Foundation/Foundation.h>

#define kAUILiveInputAlertNotMaxNumer -1

NS_ASSUME_NONNULL_BEGIN

@interface AUILiveInputNumberAlert : UIView

+ (void)show:(NSArray<NSString *> *)messages view:(UIView *)view maxNumber:(NSInteger)maxNumber inputAction:(void(^)(BOOL ok, NSArray<NSString *> *inputs))inputAction;

@end

NS_ASSUME_NONNULL_END
