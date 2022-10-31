//
//  AUIPlayerTopActionView.h
//  ApsaraVideo
//
//  Created by mengyehao on 2021/7/16.
//

#import <UIKit/UIKit.h>
typedef NS_OPTIONS(NSUInteger, AUIPlayerTopViewButtonType) {
    AUIPlayerTopViewButtonTypeNone                 = 0,
    AUIPlayerTopViewButtonTypeListen               = 1 << 1,
};


@interface AUIPlayerTopActionView : UIView
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *buttonsContainer;

@property (nonatomic, copy) void(^onButtonBlock)(NSUInteger type);
@property (nonatomic, copy) void(^onBackButtonBlock)(void);


@property (nonatomic, assign) BOOL landScape;

- (void)updateUI:(BOOL)listening;

@end
