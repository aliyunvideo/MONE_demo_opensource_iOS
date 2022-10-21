//
//  AUIRecorderHeaderButtonsView.h
//  AlivcUgsvDemo
//
//  Created by coder.pi on 2022/6/2.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, AUIRecorderHeaderBtnType) {
    AUIRecorderHeaderBtnTypeCountDown,
    AUIRecorderHeaderBtnTypeCameraTorch,
    AUIRecorderHeaderBtnTypeCameraPosition,
};

@class AUIRecorderHeaderButtonsView;
@protocol AUIRecorderHeaderButtonsViewDelegate <NSObject>
- (void) onAUIRecorderHeaderButtonsView:(AUIRecorderHeaderButtonsView *)header btnDidPressed:(AUIRecorderHeaderBtnType)btnType;
@end

@interface AUIRecorderHeaderButtonsView : UIView
@property (nonatomic, readonly) NSArray<NSNumber *> *showTypes;
@property (nonatomic, weak) id<AUIRecorderHeaderButtonsViewDelegate> delegate;
@property (nonatomic, assign) BOOL torchDisabled;
@property (nonatomic, assign) BOOL torchOpened;
@property (nonatomic, assign) BOOL isRecording;
@property (nonatomic, assign) BOOL countDownDisabled;
- (instancetype) initWithShowTypes:(NSArray<NSNumber *> *)showTypes
                          delegate:(id<AUIRecorderHeaderButtonsViewDelegate>)delegate;
- (instancetype) initWithDelegate:(id<AUIRecorderHeaderButtonsViewDelegate>)delegate;
@end

NS_ASSUME_NONNULL_END
