//
//  AUIPlayerBomButtonView.h
//  ApsaraVideo
//
//  Created by mengyehao on 2021/7/20.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSInteger, AUIPlayerBomButtonViewMode) {
    AUIPlayerBomButtonViewModeNormal,
    AUIPlayerBomButtonViewModeListen,
};



@protocol AUIPlayerBomButtonViewDelegate <NSObject>

//下一集
- (void)bomButtonViewDidClickPlayNext;

//媒体字幕
- (void)bomButtonViewDidClickSubtitle;

//倍速
- (void)bomButtonViewDidClickSpeed;

//码率
- (void)bomButtonViewDidClickBitrate;

//开发者
- (void)bomButtonViewDidClickDebug;

//点击输入框
- (void)bomButtonViewDidClickInput;

//恢复半屏
- (void)bomButtonViewDidClickHalfScreen;

@end

@interface AUIPlayerBomButtonView : UIView

@property (nonatomic, weak) id<AUIPlayerBomButtonViewDelegate>delegate;
@property (nonatomic, assign) AUIPlayerBomButtonViewMode mode;
@property (nonatomic, assign) NSUInteger playStatus;

- (void)updateBitrateTitle:(NSString *)title;

- (void)updateSpeedTitle:(NSString *)title;


@end

