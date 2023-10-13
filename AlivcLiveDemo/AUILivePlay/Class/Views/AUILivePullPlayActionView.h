//
//  AUILivePullPlayActionView.h
//  AlivcLiveDemo
//
//  Created by ISS013602000846 on 2022/6/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AUILivePullPlayActionView : UIView

@property (nonatomic, copy) dispatch_block_t stopPlayAction;
@property (nonatomic, copy) void(^mutedAction)(BOOL muted);
@property (nonatomic, copy) dispatch_block_t dataIndicatorAction;
@property (nonatomic, assign) BOOL muted;

@end

NS_ASSUME_NONNULL_END
