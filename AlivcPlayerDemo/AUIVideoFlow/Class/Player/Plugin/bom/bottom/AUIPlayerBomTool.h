//
//  AUIPlayerBomTool.h
//  ApsaraVideo
//
//  Created by mengyehao on 2021/7/20.
//

#import <UIKit/UIKit.h>
#import "AUIPlayerBomProgressView.h"
#import "AUIPlayerBomButtonView.h"
#import "AUIPlayerBomPortraitButtons.h"
#import "AUIPlayerWatchPointContainer.h"



@protocol AUIPlayerBomToolDelegate <NSObject>

- (void)bomToolOnFullScreenClick;
- (void)apBomSlideValueChanged:(float)progress;
- (void)apBomSlideTouchBegin:(float)progress;
- (void)apBomSlideTouchEnd:(float)progress;

@end


@interface AUIPlayerBomTool : UIView
@property (nonatomic, strong) AUIPlayerBomProgressView *progressView;
@property (nonatomic, strong) AUIPlayerBomButtonView *buttonView;
@property (nonatomic, strong) AUIPlayerBomPortraitButtons *portraitButtonView;
@property (nonatomic, weak) id<AUIPlayerBomToolDelegate> delegate;
@property (nonatomic, strong) AUIPlayerWatchPointContainer *watchPointContainer;


@property (nonatomic, assign) BOOL fullScreen;

@end


