//
//  AUIRecorderSliderButtonsView.h
//  AlivcUgsvDemo
//
//  Created by coder.pi on 2022/6/1.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, AUIRecorderSlidBtnType) {
    AUIRecorderSlidBtnTypeMusic,
    AUIRecorderSlidBtnTypeFilter,
    AUIRecorderSlidBtnTypeResolution,
    AUIRecorderSlidBtnTypeSpecialEffects,
    AUIRecorderSlidBtnTypeTakePhoto,
};

typedef NS_ENUM(NSUInteger, AUIRecorderResolutionType) {
    AUIRecorderResolutionType_1_1,
    AUIRecorderResolutionType_9_16,
    AUIRecorderResolutionType_3_4,
};

@class AUIRecorderSliderButtonsView;
@protocol AUIRecorderSliderButtonsViewDelegate <NSObject>
- (void) onAUIRecorderSliderButtonsView:(AUIRecorderSliderButtonsView *)slider btnDidPressed:(AUIRecorderSlidBtnType)btnType;
@end

@interface AUIRecorderSliderButtonsView : UIView
@property (nonatomic, readonly) NSArray<NSNumber *> *showTypes;
@property (nonatomic, weak) id<AUIRecorderSliderButtonsViewDelegate> delegate;
@property (nonatomic, assign) AUIRecorderResolutionType resolution;
@property (nonatomic, assign) BOOL resolutionDisabled;
@property (nonatomic, assign) BOOL musicDisabled;

- (instancetype) initWithShowTypes:(NSArray<NSNumber *> *)showTypes
                          delegate:(id<AUIRecorderSliderButtonsViewDelegate>)delegate;
- (instancetype) initWithDelegate:(id<AUIRecorderSliderButtonsViewDelegate>)delegate;
@end

NS_ASSUME_NONNULL_END
