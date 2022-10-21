//
//  AUIRecorderBottomButtonsView.h
//  AlivcUgsvDemo
//
//  Created by coder.pi on 2022/6/2.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, AUIRecorderBottomBtnType) {
    AUIRecorderBottomBtnTypeBeauty, // 美颜
    AUIRecorderBottomBtnTypeProps,  // 道具
};

@class AUIRecorderBottomButtonsView;
@protocol AUIRecorderBottomButtonsViewDelegate <NSObject>
- (void) onAUIRecorderBottomButtonsView:(AUIRecorderBottomButtonsView *)bottom btnDidPressed:(AUIRecorderBottomBtnType)btnType;
- (void) onAUIRecorderBottomButtonsViewWantDelete:(AUIRecorderBottomButtonsView *)bottom;
- (void) onAUIRecorderBottomButtonsViewWantFinish:(AUIRecorderBottomButtonsView *)bottom;
@end

@interface AUIRecorderBottomButtonsView : UIView
@property (nonatomic, readonly) NSArray<NSNumber *> *showTypes;
@property (nonatomic, weak) id<AUIRecorderBottomButtonsViewDelegate> delegate;
@property (nonatomic, assign) NSUInteger partCount;
@property (nonatomic, assign) NSTimeInterval minDuration;
@property (nonatomic, assign) NSTimeInterval duration;
- (instancetype) initWithShowTypes:(NSArray<NSNumber *> *)showTypes
                          delegate:(id<AUIRecorderBottomButtonsViewDelegate>)delegate;
- (instancetype) initWithDelegate:(id<AUIRecorderBottomButtonsViewDelegate>)delegate;
@end

NS_ASSUME_NONNULL_END
