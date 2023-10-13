//
//  AUILiveRtsPlayInputUrlView.h
//  AUILiveRtsPlay
//
//  Created by ISS013602000846 on 2022/8/1.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AUILiveRtsPlayInputUrlView : UIView

@property (nonatomic, strong) NSString *themeName;
@property (nonatomic, strong) NSString *placeholder;
@property (nonatomic, copy) void(^inputChanged)(NSString *value);

- (instancetype)initWithFrame:(CGRect)frame sourceVC:(UIViewController *)sourceVC;
- (void)resignInputStatus;

@end

NS_ASSUME_NONNULL_END
