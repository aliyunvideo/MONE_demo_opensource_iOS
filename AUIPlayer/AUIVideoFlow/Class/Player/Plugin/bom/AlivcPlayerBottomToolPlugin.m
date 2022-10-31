//
//  AlivcPlayerBottomToolPlugin.m
//  ApsaraVideo
//
//  Created by mengyehao on 2021/7/7.
//

#import "AlivcPlayerBottomToolPlugin.h"
#import "AlivcPlayerManager.h"
#import "AlivcPlayerManager.h"
#import "AlivcPlayerAsset.h"
#import "AUIPlayerBomTool.h"
#import "AUIPlayerLandScapeSpeedView.h"
#import "UIView+AUIPlayerHelper.h"
#import "AUIPlayerLandScapeResolutionView.h"
#import <Masonry/Masonry.h>
#import "AUIPlayerThumbnailView.h"
#import "AlivcPlayerRouter.h"
#import "AUIPlayerSpeedTipView.h"

#define kDelayTime 3

@interface AlivcPlayerBottomToolPlugin()<AUIPlayerBomToolDelegate,AUIPlayerBomButtonViewDelegate>
@property (nonatomic, strong) UILabel *tipsLabel;

@property (nonatomic, strong) AUIPlayerBomTool *bomView;

@property (nonatomic, strong) AUIPlayerThumbnailView *thumbnailView;

@property (nonatomic, strong) AUIPlayerSpeedTipView *speedTipView;

@property (nonatomic, assign) BOOL needPip;


@end

@implementation AlivcPlayerBottomToolPlugin

- (AUIPlayerBomTool *)bomView
{
    if (!_bomView) {
        _bomView = [[AUIPlayerBomTool alloc] initWithFrame:CGRectMake(0, self.containerView.av_height - 42, self.containerView.av_width, 42)];
        _bomView.accessibilityIdentifier = AUIVideoFlowAccessibilityStr(@"bomView");
        _bomView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
        _bomView.delegate = self;
        _bomView.buttonView.delegate = self;
    }
    return _bomView;
}

- (AUIPlayerThumbnailView *)thumbnailView
{
    if (!_thumbnailView) {
        _thumbnailView = [[AUIPlayerThumbnailView alloc] initWithFrame:CGRectMake(0, 0, 208, 55)];
        _thumbnailView.accessibilityIdentifier = AUIVideoFlowAccessibilityStr(@"thumbnailView");
        _thumbnailView.center = self.containerView.center;
        _thumbnailView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    }
    return _thumbnailView;
}

- (AUIPlayerSpeedTipView *)speedTipView {
    if (!_speedTipView) {
        _speedTipView = [[AUIPlayerSpeedTipView alloc] initWithFrame:CGRectMake(self.containerView.av_width - 23 - 145, 0, 145, 117)];
        _speedTipView.accessibilityIdentifier = AUIVideoFlowAccessibilityStr(@"speedTipView");
        _speedTipView.av_centerY = self.containerView.av_centerY;
        _speedTipView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    }
    return _speedTipView;
}

- (NSInteger)level
{
    return 3;
}

- (void)onInstall
{
    [super onInstall];

    [self.containerView addSubview:self.bomView];
    [self.containerView addSubview:self.thumbnailView];

    [self updateUIHidden];
    
    self.thumbnailView.hidden = YES;
}

- (void)onUnInstall
{
    [super onUnInstall];
    [_bomView removeFromSuperview];
    _bomView = nil;
    [_thumbnailView removeFromSuperview];
    _thumbnailView = nil;
    _speedTipView = nil;
}

- (NSArray<NSNumber *> *)eventList
{
    return @[@(AlivcPlayerEventCenterTypePlayerEventType),
             @(AlivcPlayerEventCenterTypePlayerPlayProgress),
             @(AlivcPlayerEventCenterTypePlayerBufferedProgress),
             @(AlivcPlayerEventCenterTypeLockChanged),
             @(AlivcPlayerEventCenterTypeControlToolHiddenChanged),
             @(AlivcPlayerEventCenterTypeOrientationChanged),
             @(AlivcPlayerEventCenterTypePlayerDisableVideoChanged),
             @(AlivcPlayerEventCenterTypeSliderChangedAction),
             @(AlivcPlayerEventCenterTypeSliderDragAction),
             @(AlivcPlayerEventCenterTypePlayListSourceDidChanged),
             @(AlivcPlayerEventCenterTypePlayerEventAVPStatus),
             @(AlivcPlayerEventCenterTypeSpeedTipShowAction),
    ];
}

- (void)onReceivedEvent:(AlivcPlayerEventCenterType)eventType userInfo:(NSDictionary *)userInfo
{
    if (eventType == AlivcPlayerEventCenterTypePlayerEventType) {
        AVPEventType type = [[userInfo objectForKey:@"eventType"] integerValue];
        if (type == AVPEventPrepareDone) {
            
            if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
                return;
            }
            int64_t watchTime = [[AlivcPlayerManager manager] localWatchTime:[AlivcPlayerManager manager].currentVideoId];
            float duration = [AlivcPlayerManager manager].duration;
            if (watchTime > 0 && duration && watchTime < duration) {
                CGFloat progress = watchTime/duration;
                [[AlivcPlayerManager manager] seekToTimeProgress:watchTime/duration seekMode:AVP_SEEKMODE_ACCURATE];
                
                [self.bomView.progressView updateSliderValue:watchTime duration:duration];
                [self.bomView.progressView updateCacheProgressValue:watchTime duration:duration];
              
                [self showWatchTipsUI:progress];
                [self performSelector:@selector(hideWatchTipsUI) withObject:nil afterDelay:kDelayTime];
            
            }
        } else if (type == AVPEventCompletion) {
            if (self.speedTipView.superview) {
                [self.speedTipView removeFromSuperview];
            }
        } else if (type == AVPEventFirstRenderedStart) {
            if ([AlivcPlayerManager manager].pageEventFrom == AlivcPlayerPageEventFromDetailPage) {
                if ([AlivcPlayerManager manager].pageEventJump == AlivcPlayerPageEventJumpFlowToDetailPage &&
                    ![[AlivcPlayerManager manager] isHideSpeedTip] &&
                    ![[AlivcPlayerManager manager] isHideFirstLandsacpeSpeedTip]) {
                    [self showSpeedTipWithBack:nil];
                    [[AlivcPlayerManager manager] hideFirstLandsacpeSpeedTip];
                    [[AlivcPlayerManager manager] hideSpeedTip];
                }
            } else if ([AlivcPlayerManager manager].pageEventFrom == AlivcPlayerPageEventFromFullScreenPlayPage) {
                if (![[AlivcPlayerManager manager] isHideFullScreenSpeedTip]) {
                    [self showSpeedTipWithBack:nil];
                    [[AlivcPlayerManager manager] hideFullScreenSpeedTip];
                }
            }
        }
    } else if (eventType == AlivcPlayerEventCenterTypePlayerPlayProgress) {
        CGFloat position = [[userInfo objectForKey:@"position"] floatValue];
        CGFloat duration = [[userInfo objectForKey:@"duration"] floatValue];

        [self.bomView.progressView updateSliderValue:position duration:duration];
    } else if (eventType == AlivcPlayerEventCenterTypePlayerBufferedProgress) {
        CGFloat position = [[userInfo objectForKey:@"position"] floatValue];
        CGFloat duration = [[userInfo objectForKey:@"duration"] floatValue];
        [self.bomView.progressView updateCacheProgressValue:position duration:duration];
    } else if (eventType == AlivcPlayerEventCenterTypeLockChanged) {
        [self updateUIHidden];
    }  else if (eventType == AlivcPlayerEventCenterTypeControlToolHiddenChanged) {
        [self updateUIHidden];
    } else if (eventType == AlivcPlayerEventCenterTypeOrientationChanged) {
        [self updateUIOrientation];
        [self updateWatchPointUI];
        
        if ([AlivcPlayerManager manager].pageEventFrom == AlivcPlayerPageEventFromFlowPage) {
            BOOL fullscreen = [AlivcPlayerManager manager].currentOrientation != 0;
            if (fullscreen) {
                if (![[AlivcPlayerManager manager] isHideFirstLandsacpeSpeedTip] &&
                    ![[AlivcPlayerManager manager] isHideSpeedTip]) {
                    [self showSpeedTipWithBack:nil];
                    [[AlivcPlayerManager manager] hideFirstLandsacpeSpeedTip];
                    [[AlivcPlayerManager manager] hideSpeedTip];
                }
            } else {
                [self hideSpeedTipWithBack:^{
                    [[AlivcPlayerManager manager] hideFirstLandsacpeSpeedTip];
                    [[AlivcPlayerManager manager] hideSpeedTip];
                }];
            }
        } else if ([AlivcPlayerManager manager].pageEventFrom == AlivcPlayerPageEventFromDetailPage) {
            if ([AlivcPlayerManager manager].pageEventJump == AlivcPlayerPageEventJumpFlowToDetailPage) {
                [self hideSpeedTipWithBack:^{
                    [[AlivcPlayerManager manager] hideFirstLandsacpeSpeedTip];
                    [[AlivcPlayerManager manager] hideSpeedTip];
                }];
            }
        } else if ([AlivcPlayerManager manager].pageEventFrom == AlivcPlayerPageEventFromFullScreenPlayPage) {
            [self hideSpeedTipWithBack:^{
                [[AlivcPlayerManager manager] hideFullScreenSpeedTip];
            }];
        }
    } else if (eventType == AlivcPlayerEventCenterTypePlayerDisableVideoChanged) {
        [self updateUIHidden];
    } else if (eventType == AlivcPlayerEventCenterTypeSliderChangedAction) {
        CGFloat position = [[userInfo objectForKey:@"position"] floatValue];
        CGFloat duration = [[userInfo objectForKey:@"duration"] floatValue];
        [self.bomView.progressView updateSliderValue:position duration:duration];
    } else if (eventType == AlivcPlayerEventCenterTypeSliderDragAction) {
        self.thumbnailView.hidden = NO;
        BOOL changeThumbail = [[userInfo objectForKey:@"changeThumbail"] boolValue];
        BOOL isPortrait = [[userInfo objectForKey:@"portrait"] boolValue];
        CGFloat position = [[userInfo objectForKey:@"position"] floatValue];
        CGFloat duration = [[userInfo objectForKey:@"duration"] floatValue];
        if (isPortrait) {
            self.thumbnailView.style = AUIPlayerThumbnailStylePortrait;
            [self.thumbnailView updateThumbnail:nil positionTimeValue:position duration:duration];
        } else {
            if (changeThumbail) {
                self.thumbnailView.style = AUIPlayerThumbnailStyleLandscapeHasThumbnail;
                UIImage *thumbail = [userInfo objectForKey:@"thumbail"];
                [self.thumbnailView updateThumbnail:thumbail positionTimeValue:position duration:duration];
            } else {
                self.thumbnailView.style = AUIPlayerThumbnailStyleLandscapeWithoutThumbnail;
                [self.thumbnailView updateThumbnail:nil positionTimeValue:position duration:duration];
            }
        }
    } else if (eventType == AlivcPlayerEventCenterTypePlayerEventAVPStatus) {
        NSUInteger status = [[userInfo objectForKey:@"status"] intValue];
        self.bomView.buttonView.playStatus = status;
    } else if (eventType == AlivcPlayerEventCenterTypeSpeedTipShowAction) {
        if ([AlivcPlayerManager manager].playerStatus == AVPStatusIdle ||
            [AlivcPlayerManager manager].playerStatus == AVPStatusInitialzed ||
            [AlivcPlayerManager manager].playerStatus == AVPStatusError) {
            return;
        }
        
        if ([AlivcPlayerManager manager].pageEventFrom == AlivcPlayerPageEventFromDetailPage) {
            if ([AlivcPlayerManager manager].pageEventJump == AlivcPlayerPageEventJumpFlowToDetailPage &&
                ![[AlivcPlayerManager manager] isHideSpeedTip] &&
                ![[AlivcPlayerManager manager] isHideFirstLandsacpeSpeedTip]) {
                [self showSpeedTipWithBack:nil];
                [[AlivcPlayerManager manager] isHideFirstLandsacpeSpeedTip];
                [[AlivcPlayerManager manager] hideSpeedTip];
            }
        } else if ([AlivcPlayerManager manager].pageEventFrom == AlivcPlayerPageEventFromFullScreenPlayPage) {
            if (![[AlivcPlayerManager manager] isHideFullScreenSpeedTip]) {
                [self showSpeedTipWithBack:nil];
                [[AlivcPlayerManager manager] hideFullScreenSpeedTip];
            }
        }
    }
}

- (void)updateUIHidden
{
    bool hidden =  [AlivcPlayerManager manager].controlToolHidden || [AlivcPlayerManager manager].lock;
    
    self.bomView.hidden = hidden;
    
   
    self.tipsLabel.frame = CGRectMake(12,self.containerView.av_height - self.tipsLabel.av_height -  (self.bomView.hidden?12: self.bomView.av_height), self.tipsLabel.av_width, self.tipsLabel.av_height);
    
    NSString *title =@"自动";
    if (![AlivcPlayerManager manager].autoTrack) {
       AVPTrackInfo *track = [[AlivcPlayerManager manager] getCurrentTrack:AVPTRACK_TYPE_SAAS_VOD];
        title = [self formatBitrateTitleWithKey:track.trackDefinition];
        title = [title componentsSeparatedByString:@"\n"].lastObject;
    }
    
    [self.bomView.buttonView updateBitrateTitle:title];
    
    title = @"倍速";
    if ([AlivcPlayerManager manager].rate > 1.0 || [AlivcPlayerManager manager].rate < 1.0) {
        
        NSArray *tempList =  @[@"2.0X",@"1.5X",@"1.25X",@"1.0X",@"0.75X",@"0.5X"];
        for (NSString *obj in tempList) {
            if ([AlivcPlayerManager manager].rate == [obj floatValue]) {
                title = obj;
                break;
            }
        }
    }
    [self.bomView.buttonView updateSpeedTitle:title];

    
    bool landScape = [AlivcPlayerManager manager].currentOrientation != 0 ;
    CGFloat bommtom = (self.bomView.hidden?12: (landScape?88:42));
    
    [self.tipsLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.containerView).mas_offset(-bommtom);
    }];
    
    self.bomView.watchPointContainer.hidden = self.bomView.hidden;
}

- (NSString *)formatBitrateTitleWithKey:(NSString *)key
{
    if (!key) {
        return  @"";
    }
    NSDictionary *dict = @{
        @"OD":@"1080P\n原画",
        @"HD":@"1080P\n超清",
        @"SD":@"720P\n高清",
        @"LD":@"480P\n清晰",
        @"FD":@"360P\n流畅",
        @"AUTO":@"720P\n自动",
    };
    
    NSString *value = dict[key];
    return value?:key;
}

- (void)updateUIOrientation
{
    BOOL fullscreen = [AlivcPlayerManager manager].currentOrientation != 0;
    self.bomView.av_height = fullscreen ? 88 : 42;
    self.bomView.av_top = self.containerView.bounds.size.height - self.bomView.av_height;
    self.bomView.fullScreen = fullscreen;
    
    bool landScape = [AlivcPlayerManager manager].currentOrientation != 0 ;
    CGFloat bommtom = (self.bomView.hidden?12: (landScape?88:42));
    
    [self.tipsLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.containerView).mas_offset(-bommtom);
    }];
    
    [self updateUIHidden];
    
    if (self.tipsLabel.superview) {
        [self.tipsLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.containerView).mas_offset([self tipsLabelSafeLeft]);
        }];
    }
    
    if (fullscreen) {
        self.thumbnailView.av_height = 166;
    } else {
        self.thumbnailView.av_height = 55;
    }
}

- (void)showSpeedTipWithBack:(nullable void(^)(void))back {
    if (!self.speedTipView.superview) {
        [self.containerView addSubview:self.speedTipView];
        __weak typeof(self) weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            __strong typeof(self) strongSelf = weakSelf;
            [strongSelf hideSpeedTipWithBack:^{
                if (back) {
                    back();
                }
            }];
        });
    }
}

- (void)hideSpeedTipWithBack:(void(^)(void))back {
    if (self.speedTipView.superview) {
        [self.speedTipView removeFromSuperview];
        _speedTipView = nil;
        if (back) {
            back();
        }
    }
}

- (void)updateWatchPointUI
{
    if ([AlivcPlayerManager manager].currentOrientation != 0) {
        self.bomView.watchPointContainer.superContainer = self.containerView;
        [self.bomView.watchPointContainer updateData];
        self.bomView.watchPointContainer.hidden = NO;

    } else {
        self.bomView.watchPointContainer.hidden = YES;
    }
}

- (void)showWatchTipsUI:(float)progress
{
    [self cancelHideWatchTipsUI];
    
    UILabel *tipsLabel = [[UILabel alloc] init];
    tipsLabel.accessibilityIdentifier = AUIVideoFlowAccessibilityStr(@"bottomTool_tipsLabel");
    
    NSString *text = @"已为您切换到上次观看位置  ";
    NSString *suffText = @"取消";
    
    NSMutableAttributedString *richText = [[NSMutableAttributedString alloc] init];
    
    NSAttributedString *textRich = [[NSAttributedString alloc] initWithString:text attributes:@{NSForegroundColorAttributeName:UIColor.whiteColor}];
    [richText appendAttributedString:textRich];
    
    NSAttributedString *suffRich = [[NSAttributedString alloc] initWithString:suffText attributes:@{NSForegroundColorAttributeName:APGetColor(APColorTypeCyanBg)}];
    [richText appendAttributedString:suffRich];
    
    
    tipsLabel.clipsToBounds = YES;
    tipsLabel.layer.cornerRadius = 4;
    [tipsLabel setAttributedText:richText];
    tipsLabel.textAlignment = NSTextAlignmentCenter;
    [tipsLabel setBackgroundColor:APGetColor(APColorTypeVideoBg40)];
    tipsLabel.font = AVGetRegularFont(12);
    [self.containerView addSubview:tipsLabel];
    
    [tipsLabel sizeToFit];
    
    
    CGFloat width = tipsLabel.bounds.size.width + 24;
    CGFloat height = 36;
    
    tipsLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSeekStartClick:)];
    [tipsLabel addGestureRecognizer:tapGesture];
    self.tipsLabel = tipsLabel;
    
   
    CGFloat left = [self tipsLabelSafeLeft];
    
    [self.tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(height);
        make.width.mas_equalTo(width);
        make.left.equalTo(self.containerView).mas_offset(left);
        make.bottom.equalTo(self.containerView).mas_offset(-(self.bomView.hidden?12: self.bomView.av_height));
    }];
   
}

- (CGFloat)tipsLabelSafeLeft
{
    CGFloat left = 12;
    if ([UIView av_isIphoneX]) {
        left =  [AlivcPlayerManager manager].currentOrientation == AlivcPlayerEventCenterTypeOrientationLandsacpeLeft ? 34 + 12 : 12;
    }
    return left;
}

- (void)cancelHideWatchTipsUI
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideWatchTipsUI) object:nil];
    [self hideWatchTipsUI];
}

- (void)hideWatchTipsUI
{
    [self.tipsLabel removeFromSuperview];
    self.tipsLabel = nil;
}

- (void)onSeekStartClick:(id)sender
{
    [self cancelHideWatchTipsUI];
    [[AlivcPlayerManager manager] seekToTimeProgress:0 seekMode:AVP_SEEKMODE_ACCURATE];
}


#pragma mark - AUIPlayerBomToolDelegate

- (void)bomToolOnFullScreenClick
{
    [AlivcPlayerManager manager].currentOrientation = AlivcPlayerEventCenterTypeOrientationLandsacpeLeft;
}

- (void)apBomSlideValueChanged:(float)progress
{
    [[AlivcPlayerManager manager] seekToTimeProgress:progress seekMode:AVP_SEEKMODE_ACCURATE];
    
}

- (void)apBomSlideTouchBegin:(float)progress
{
    [[AlivcPlayerManager manager] getThumbnail:progress];
}

- (void)apBomSlideTouchEnd:(float)progress
{
    self.thumbnailView.hidden = YES;
    [[AlivcPlayerManager manager] dispatchEvent:AlivcPlayerEventCenterTypeSliderTouchEndAction userInfo:nil];
}

#pragma mark - AUIPlayerBomButtonViewDelegate

//下一集
- (void)bomButtonViewDidClickPlayNext
{
    [[AlivcPlayerManager manager] playNext];
    [AlivcPlayerManager manager].playContainView.hidden = NO;
    [AlivcPlayerManager manager].controlToolHidden = YES;
}

//媒体字幕
- (void)bomButtonViewDidClickSubtitle
{

}

//倍速
- (void)bomButtonViewDidClickSpeed
{
    [[AlivcPlayerManager manager] setControlToolHidden:YES];

    AUIPlayerLandScapeSpeedView *view = [[AUIPlayerLandScapeSpeedView alloc] initWithFrame:self.containerView.bounds];
    view.accessibilityIdentifier = AUIVideoFlowAccessibilityStr(@"landScapeSpeedView");
    [self.containerView addSubview:view];
    [view updateSeletedRate:[AlivcPlayerManager manager].rate];
    __weak typeof (self) weakSelf = self;

    view.onRateChanged = ^(float rate) {
        if (rate != [AlivcPlayerManager manager].rate) {
            [AlivcPlayerManager manager].rate = rate;
            NSString *text =  [NSString stringWithFormat:@"已切换为 %.2f 倍速度播放",rate];
            [AVToastView show:text view:weakSelf.containerView position:AVToastViewPositionMid];
        }
    };
    
}

//码率
- (void)bomButtonViewDidClickBitrate
{
    [[AlivcPlayerManager manager] setControlToolHidden:YES];
    
    AUIPlayerLandScapeResolutionView *view = [[AUIPlayerLandScapeResolutionView alloc] initWithFrame:self.containerView.bounds];
    view.accessibilityIdentifier = AUIVideoFlowAccessibilityStr(@"landScapeBitrateView");
    [self.containerView addSubview:view];
    
    AVPMediaInfo *info =  [[AlivcPlayerManager manager] getMediaInfo];
   
    
    NSMutableArray *list = [NSMutableArray array];
    for (AVPTrackInfo *track in info.tracks) {
        if (track.trackType == AVPTRACK_TYPE_SAAS_VOD) {
            if (track.trackDefinition) {
                [list addObject:track];
            }
        }
    }
    view.dataList = list;
    
    
    AVPTrackInfo *currentTrack = [[AlivcPlayerManager manager] getCurrentTrack:AVPTRACK_TYPE_SAAS_VOD];
    
    [view updateCurrentSeleted:[AlivcPlayerManager manager].autoTrack ? nil :currentTrack];
    
    view.onTrackChanged = ^(AVPTrackInfo * track) {
        [[AlivcPlayerManager manager] selectTrack:track];
    };
}

//开发者
- (void)bomButtonViewDidClickDebug
{
    
}

//恢复半屏
- (void)bomButtonViewDidClickHalfScreen {
    if ([AlivcPlayerManager manager].pageEventFrom == AlivcPlayerPageEventFromFullScreenPlayPage) {
        [[AlivcPlayerManager manager] dispatchEvent:AlivcPlayerEventCenterTypeFullScreenPlayToDetailPage userInfo:nil];
    } else {
        if ([AlivcPlayerManager manager].currentOrientation != 0) {
            [[AlivcPlayerManager manager] setCurrentOrientation:0];
        } else {
            [[AlivcPlayerRouter currentViewController].navigationController popViewControllerAnimated:YES];
        }
    }
}

- (void)bomButtonViewDidClickInput
{
    [[AlivcPlayerManager manager] dispatchEvent:AlivcPlayerEventCenterTypeInputAction userInfo:nil];
}

@end
