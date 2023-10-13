//
//  AUILiveInputNumberView.h
//  AUILiveLinkMic
//
//  Created by ISS013602000846 on 2022/8/1.
//

#import <UIKit/UIKit.h>

#define kAUILiveInputNotMaxNumer -1

typedef NS_ENUM(NSInteger, AUILiveInputNumberType) {
    AUILiveInputNumberTypeInput = 0,    // 输入
    AUILiveInputNumberTypeInputAndScan, // 输入加扫码
};

NS_ASSUME_NONNULL_BEGIN

@interface AUILiveInputNumberView : UIView

@property (nonatomic, strong) NSString *themeName;
@property (nonatomic, assign) NSInteger maxNumber;
@property (nonatomic, strong) NSString *defaultInput;
// 是否允许输入额外特殊字符。默认不允许。开启后支持"."、"-"。
@property (nonatomic, assign) BOOL isAllowExtraSpecialCharacters;
@property (nonatomic, copy) void(^inputChanged)(NSString *value);

- (instancetype)initWithFrame:(CGRect)frame type:(AUILiveInputNumberType)type sourceVC:(UIViewController *)sourceVC;
- (void)resignInputStatus;

@end

NS_ASSUME_NONNULL_END
