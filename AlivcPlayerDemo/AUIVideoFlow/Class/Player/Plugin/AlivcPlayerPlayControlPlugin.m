//
//  AlivcPlayerPlayControlPlugin.m
//  ApsaraVideo
//
//  Created by mengyehao on 2021/7/14.
//

#import "AlivcPlayerPlayControlPlugin.h"
#import "AlivcPlayerManager.h"
#import "AlivcPlayerAsset.h"
#import "AUIPlayerCustomImageButton.h"
#import <Masonry/Masonry.h>
#import <SDWebImage/SDWebImage.h>
#import "UIView+AUIPlayerHelper.h"

#define kBgImageBlurRadius 36

@interface APPlayReplayView : UIView
//@property (nonatomic, strong) UILabel *replayLabel;
@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) UIView *maskView;

@property (nonatomic, strong) UIImageView *avatarView;
@property (nonatomic, strong) UILabel *userLabel;
@property (nonatomic, strong) UILabel *userDescLabel;
@property (nonatomic, strong) UIButton *replayButton;

- (void)updateBgImageView:(NSString *)url;
- (void)updateReplayTime:(NSString *)time;

@end

@implementation APPlayReplayView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
        imageView.accessibilityIdentifier = AUIVideoFlowAccessibilityStr(@"imageView");
        [self addSubview:imageView];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.bgImageView = imageView;
        self.bgImageView.clipsToBounds = YES;
        
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsZero);
        }];
        
        
        UIView *maskview = [[UIView alloc] initWithFrame:self.bgImageView.bounds];
        maskview.accessibilityIdentifier = AUIVideoFlowAccessibilityStr(@"maskview");
        [self.bgImageView addSubview:maskview];
        maskview.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.15];
        [maskview mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.bottom.equalTo(self.bgImageView);
        }];
//        
//        self.replayLabel  = [[UILabel alloc] init];
//        [self addSubview:self.replayLabel];
//        self.replayLabel.textColor = [UIColor whiteColor];
//        self.replayLabel.font = AVGetRegularFont(16);
//        self.replayLabel.textAlignment = NSTextAlignmentCenter;
//        NSMutableAttributedString *attrubuteString = [[NSMutableAttributedString alloc] init];
//        
//        NSTextAttachment *attchment = [[NSTextAttachment alloc] init];
//        attchment.image = AUIVideoFlowImage(@"player_refresh");
//        attchment.bounds = CGRectMake(0, -5, 20, 20);
//        NSAttributedString *attchmentString = [NSAttributedString attributedStringWithAttachment:attchment];
//        [attrubuteString appendAttributedString:attchmentString];
//        [attrubuteString appendAttributedString: [[NSAttributedString alloc] initWithString:@" 重播"]];
//        self.replayLabel.attributedText = attrubuteString;
//        
//        [self.replayLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.center.equalTo(self);
//            make.width.equalTo(self);
//            make.height.equalTo(@24);
//        }];
//        self.replayLabel.userInteractionEnabled = YES;
//        
//        UITapGestureRecognizer *gestrue = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSingleTap:)];
//        [self.replayLabel addGestureRecognizer:gestrue];
        [self addSubview:self.avatarView];
        [self addSubview:self.userLabel];
        [self addSubview:self.userDescLabel];
        [self addSubview:self.replayButton];
        
        CGFloat ladding = (self.av_width - 48 - 8 - 100 - 84 - 63) / 2.0;
        [self.avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ladding);
            make.centerY.equalTo(self);
            make.size.mas_equalTo(CGSizeMake(48, 48));
        }];
        
        [self.userLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.avatarView.mas_right).mas_equalTo(8);
            make.bottom.mas_equalTo(self.avatarView.mas_centerY).mas_equalTo(-4);
            make.size.mas_equalTo(CGSizeMake(170, 20));
        }];
        
        [self.userDescLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.avatarView.mas_right).mas_equalTo(8);
            make.top.mas_equalTo(self.avatarView.mas_centerY).mas_equalTo(4);
            make.size.mas_equalTo(CGSizeMake(170, 18));
        }];
        
        [self.replayButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-ladding);
            make.centerY.equalTo(self);
            make.size.mas_equalTo(CGSizeMake(84, 32));
        }];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat ladding = (self.av_width - 48 - 8 - 150 - 84 - 63) / 2.0;
    [self.avatarView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ladding);
    }];
    
    [self.replayButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-ladding);
    }];
}

- (UIImageView *)avatarView
{
    if (!_avatarView) {
        _avatarView = [UIImageView new];
        _avatarView.accessibilityIdentifier = AUIVideoFlowAccessibilityStr(@"avatarView");
        _avatarView.image = AUIVideoFlowImage(@"comment_avatar");
        _avatarView.clipsToBounds = YES;
        _avatarView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _avatarView;
}

- (UILabel *)userLabel
{
    if (!_userLabel) {
        _userLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 20)];
        _userLabel.accessibilityIdentifier = AUIVideoFlowAccessibilityStr(@"userLabel");
        _userLabel.font = AVGetMediumFont(14);
        _userLabel.textColor = AUIFoundationColor(@"text_strong");
        _userLabel.text = AUIVideoFlowString(@"阿里云视频");
    }
    return _userLabel;
}

- (UILabel *)userDescLabel
{
    if (!_userDescLabel) {
        _userDescLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 18)];
        _userDescLabel.accessibilityIdentifier = AUIVideoFlowAccessibilityStr(@"userDescLabel");
        _userDescLabel.font = AVGetRegularFont(10);
        _userDescLabel.textColor = UIColor.whiteColor;
        _userDescLabel.text = [NSString stringWithFormat:AUIVideoFlowString(@"%zd视频・%zd万点赞"), 148, 56];
    }
    return _userDescLabel;
}

- (UIButton *)replayButton
{
    if (!_replayButton) {
        _replayButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _replayButton.accessibilityIdentifier = AUIVideoFlowAccessibilityStr(@"replayButton");
        _replayButton.backgroundColor = AUIFoundationColor(@"tsp_fill_medium");
        _replayButton.titleLabel.font = AVGetRegularFont(12);
        [_replayButton setTitleColor:AUIFoundationColor(@"ic_strong") forState:UIControlStateNormal];
        [_replayButton addTarget:self action:@selector(onSingleTap:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _replayButton;
}

- (void)onSingleTap:(id)senser
{
    [[AlivcPlayerManager manager] seekToTimeProgress:0 seekMode:AVP_SEEKMODE_ACCURATE];
    [[AlivcPlayerManager manager] resume];
}


- (void)updateBgImageView:(NSString *)urlstring
{
    if (urlstring.length <= 0) {
        return;
    }
    NSURL *url = [NSURL URLWithString:urlstring];
    [[SDWebImageManager sharedManager] loadImageWithURL:url options:0 progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
        if (image && [imageURL isEqual:url]) {
            self.bgImageView.image = [image sd_blurredImageWithRadius:kBgImageBlurRadius];
        }
    }];
}

- (void)updateReplayTime:(NSString *)time {
    [self.replayButton setTitle:[NSString stringWithFormat:AUIVideoFlowString(@"重播・%@秒"), time] forState:UIControlStateNormal];

}

@end


@interface AlivcPlayerPlayControlPlugin()

@property (nonatomic, strong) AUIPlayerCustomImageButton *playButton;
@property (nonatomic, strong) APPlayReplayView *replayView;
@property (nonatomic, assign) NSInteger replayShowTime;

@end

@implementation AlivcPlayerPlayControlPlugin


- (AUIPlayerCustomImageButton *)playButton
{
    if (!_playButton) {
        _playButton = [[AUIPlayerCustomImageButton alloc] init];
        _playButton.accessibilityIdentifier = AUIVideoFlowAccessibilityStr(@"playButton");
        [_playButton addTarget:self action:@selector(onPlayButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [_playButton setImage:AUIVideoFlowImage(@"player_paused") forState:UIControlStateNormal];
        [_playButton setImage:AUIVideoFlowImage(@"player_play") forState:UIControlStateSelected];
        _playButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _playButton;
}

- (void)onPlayButtonClick:(UIButton *)button
{
    AVPStatus status = [AlivcPlayerManager manager].playerStatus;
    if (status == AVPStatusPaused || status == AVPStatusStopped) {
        [[AlivcPlayerManager manager] resume];
    } else if (status == AVPStatusCompletion) {
        [[AlivcPlayerManager manager] seekToTimeProgress:0 seekMode:AVP_SEEKMODE_ACCURATE];
        [[AlivcPlayerManager manager] resume];
    } else {
        [[AlivcPlayerManager manager] pause];
    }
    
}


- (NSInteger)level
{
    return 2;
}

- (void)onInstall
{
    [super onInstall];

    [self.containerView addSubview:self.playButton];
    
    [self.playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.containerView);
        make.size.mas_equalTo(CGSizeMake(48, 48));
    }];
    [self updateButtonSize];
    [self updateUIHidden];

}

- (void)onUnInstall
{
    [super onUnInstall];
    [_playButton removeFromSuperview];
    _playButton = nil;
}

- (NSArray<NSNumber *> *)eventList
{
    return  @[
        @(AlivcPlayerEventCenterTypeOrientationChanged),
        @(AlivcPlayerEventCenterTypePlayerEventAVPStatus),
        @(AlivcPlayerEventCenterTypeLockChanged),
        @(AlivcPlayerEventCenterTypeControlToolHiddenChanged),
        @(AlivcPlayerEventCenterTypePlayerDisableVideoChanged),
        @(AlivcPlayerEventCenterPlaySceneChanged),
        @(AlivcPlayerEventCenterTypeSliderDragAction),
        @(AlivcPlayerEventCenterTypeSliderTouchEndAction),
    ];
}

- (void)onReceivedEvent:(AlivcPlayerEventCenterType)eventType userInfo:(NSDictionary *)userInfo
{
    
    
    if (eventType == AlivcPlayerEventCenterTypePlayerEventAVPStatus) {
        AVPStatus status = [[userInfo objectForKey:@"status"] integerValue];
        [self showReplayViewIfNeed];
        switch (status) {
            case AVPStatusPaused:
            case AVPStatusStopped:
                self.playButton.selected = YES;
                break;
            case AVPStatusCompletion:
            {
                self.playButton.selected = YES;
                // [self playNextIfNeed];
            }
                break;
                
            default:
                self.playButton.selected = NO;
                break;
        }
    } else if (eventType == AlivcPlayerEventCenterTypeLockChanged) {
        [self updateUIHidden];
    } else if (eventType == AlivcPlayerEventCenterTypeControlToolHiddenChanged) {
        [self updateUIHidden];
    } else if (eventType == AlivcPlayerEventCenterTypeOrientationChanged) {
        [self updateButtonSize];
        [self updateUIHidden];
    } else if (eventType == AlivcPlayerEventCenterTypePlayerDisableVideoChanged) {
        [self updateUIHidden];
    } else if (eventType == AlivcPlayerEventCenterPlaySceneChanged) {
        [self showReplayViewIfNeed];
    } else if (eventType == AlivcPlayerEventCenterTypeSliderDragAction) {
        self.playButton.hidden = YES;
    } else if (eventType == AlivcPlayerEventCenterTypeSliderTouchEndAction) {
        if ([AlivcPlayerManager manager].currentOrientation == 0) {
            self.playButton.hidden = NO;
        }
    }
}

- (void)updateUIHidden
{
    // zzy 20220630 暂时注释功能
    if ([AlivcPlayerManager manager].currentOrientation != 0) {
        self.playButton.hidden = YES;
        // zzy 20220630 暂时注释功能
    } else {
        self.playButton.hidden = [AlivcPlayerManager manager].controlToolHidden || [AlivcPlayerManager manager].lock || [AlivcPlayerManager manager].disableVideo;
    }
    
    if (self.playButton.hidden == NO) {
        [self.containerView bringSubviewToFront:self.playButton];
    }
}

- (void)updateButtonSize
{
    CGSize size =  [AlivcPlayerManager manager].currentOrientation == 0 ? CGSizeMake(24, 24) : CGSizeMake(48, 48);
    self.playButton.customSize = size;
    [self.playButton setNeedsLayout];
}

- (void)playNextIfNeed
{
    if ([AlivcPlayerManager manager].playScene == ApPlayerSceneInFeed) {
        return;
    }
    
    if (![AlivcPlayerManager manager].autoPlayInList) {
        return;
    }
    
    [[AlivcPlayerManager manager] playNext];
    
    [AlivcPlayerManager manager].playContainView.hidden = NO;
    
}


- (void)showReplayViewIfNeed
{
    
    if (self.replayView == nil) {
        self.replayView = [[APPlayReplayView alloc] initWithFrame:self.containerView.bounds];
        self.replayView.accessibilityIdentifier = AUIVideoFlowAccessibilityStr(@"replayView");
        [self.containerView insertSubview:self.replayView aboveSubview:self.playButton];
        [self.containerView bringSubviewToFront:self.replayView];
        self.replayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    
    BOOL hidden = YES;
    
    if ([AlivcPlayerManager manager].playerStatus == AVPStatusCompletion &&
        [AlivcPlayerManager manager].playScene != ApPlayerSceneInFeed &&
        [AlivcPlayerManager manager].isListening == NO &&
        (![AlivcPlayerManager manager].canPlayNext || ![AlivcPlayerManager manager].autoPlayInList)) {
        hidden = NO;
        self.replayView.frame = self.containerView.bounds;
        [self.replayView updateBgImageView:[AlivcPlayerManager manager].getMediaInfo.coverURL];
        [AlivcPlayerManager manager].controlToolHidden = YES;
    }
    
    self.replayView.hidden = hidden;
    
    if (self.replayView.hidden == NO) {
        self.replayShowTime = 3;
        [self autoUpdateReplayShowTime];
    }
}

- (void)autoUpdateReplayShowTime {
    if (self.replayShowTime > 0) {
        [self.replayView updateReplayTime:[NSString stringWithFormat:@"%ld", (long)self.replayShowTime]];
        self.replayShowTime--;
        [self performSelector:@selector(autoUpdateReplayShowTime) withObject:nil afterDelay:1];
    } else {
        [self.replayView removeFromSuperview];
        self.replayView = nil;
        [[AlivcPlayerManager manager] seekToTimeProgress:0 seekMode:AVP_SEEKMODE_ACCURATE];
        [[AlivcPlayerManager manager] resume];
    }
}

@end
