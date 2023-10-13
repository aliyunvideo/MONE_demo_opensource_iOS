//
//  AUIRecorderControlView.h
//  AlivcUgsvDemo
//
//  Created by coder.pi on 2022/6/3.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class AUIRecorderControlView;
@protocol AUIRecorderControlViewDelegate <NSObject>
- (void) onAUIRecorderControlViewWantStart:(AUIRecorderControlView *)recordCtr;
- (void) onAUIRecorderControlViewWantStop:(AUIRecorderControlView *)recordCtr;
@end

@interface AUIRecorderControlView : UIView
@property (nonatomic, weak) id<AUIRecorderControlViewDelegate> delegate;
@property (nonatomic, readonly) UIView *controlView;
@property (nonatomic, assign) BOOL isRecording;
@property (nonatomic, assign) NSTimeInterval maxDuration;
@property (nonatomic, readonly) NSTimeInterval totalDuration;
@property (nonatomic, assign) NSTimeInterval currentPartDuration;
@property (nonatomic, copy) NSArray<NSNumber *> *partDurations;

- (instancetype) initWithDelegate:(id<AUIRecorderControlViewDelegate>)delegate;
@end

NS_ASSUME_NONNULL_END
