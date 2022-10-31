//
//  AUIVideoPlayTimeView.h
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/6/3.
//

#import <UIKit/UIKit.h>
#import "AUIVideoPlayProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUIVideoPlayTimeView : UIView

@property (nonatomic, strong, readonly) UIButton *playButton;
@property (nonatomic, strong, readonly) UILabel *timeLabel;
@property (nonatomic, strong, readonly) UIButton *fullScreenBtn;

@property (nonatomic, weak, nullable) id<AUIVideoPlayProtocol> player;
@property (nonatomic, copy) void(^onEnterFullScreenClicked)(void);

@end

NS_ASSUME_NONNULL_END
