//
//  AUIShortEpisodePlayCell.m
//  AlivcPlayerDemo
//
//  Created by Bingo on 2023/9/14.
//

#import "AUIShortEpisodePlayCell.h"
#import "AUIShortEpisodeEntranceView.h"
#import "AUIShortEpisodeMacro.h"
#import <SDWebImage/SDWebImage.h>

@interface AUIShortEpisodePlayCell ()

@property (nonatomic, strong) CAGradientLayer *topViewLayer;
@property (nonatomic, strong) CAGradientLayer *bottomViewLayer;
@property (nonatomic, strong) AVBlockButton *backButton;
@property (nonatomic, strong) AUIShortEpisodeEntranceView *entranceView;

@property (nonatomic, strong) AVVideoPlayProgressView *progressView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *infoLabel;

@property (nonatomic, strong) AVBaseButton *likeBtn;
@property (nonatomic, strong) AVBaseButton *commentBtn;
@property (nonatomic, strong) AVBaseButton *shareBtn;

@property (nonatomic, strong) UIView *playerView;
@property (nonatomic, strong) AVBlockButton *playBtn;

@end

@implementation AUIShortEpisodePlayCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        __weak typeof(self) weakSelf = self;
        
        _playerView = [UIView new];
        _playerView.backgroundColor = UIColor.blackColor;
        [self.contentView addSubview:_playerView];
        
        _playBtn = [AVBlockButton new];
        [_playBtn setImage:SECommonImage(@"ic_play") forState:UIControlStateSelected];
        _playBtn.clickBlock = ^(AVBlockButton * _Nonnull sender) {
            if (weakSelf.onPlayBtnClickBlock) {
                weakSelf.onPlayBtnClickBlock(weakSelf);
            }
        };
        [self.contentView addSubview:_playBtn];
        
        _topViewLayer = [CAGradientLayer layer];
        _topViewLayer.colors = @[(id)[UIColor av_colorWithHexString:@"#727272" alpha:0].CGColor,(id)[UIColor av_colorWithHexString:@"#000000" alpha:0.6].CGColor];
        _topViewLayer.startPoint = CGPointMake(0.5, 1);
        _topViewLayer.endPoint = CGPointMake(0.5, 0);
        [self.contentView.layer addSublayer:_topViewLayer];
        
        _bottomViewLayer = [CAGradientLayer layer];
        _bottomViewLayer.colors = @[(id)[UIColor av_colorWithHexString:@"#727272" alpha:0].CGColor,(id)[UIColor av_colorWithHexString:@"#000000" alpha:0.6].CGColor];
        _bottomViewLayer.startPoint = CGPointMake(0.5, 0);
        _bottomViewLayer.endPoint = CGPointMake(0.5, 1);
        [self.contentView.layer addSublayer:_bottomViewLayer];

        _backButton = [AVBlockButton new];
        [_backButton setImage:AUIFoundationImage(@"ic_back") forState:UIControlStateNormal];
        _backButton.clickBlock = ^(AVBlockButton * _Nonnull sender) {
            if (weakSelf.onBackBtnClickBlock) {
                weakSelf.onBackBtnClickBlock(weakSelf);
            }
        };
        [self.contentView addSubview:_backButton];
                
        
        _entranceView = [AUIShortEpisodeEntranceView new];
        [_entranceView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onEntranceClicked)]];
        [self.contentView addSubview:_entranceView];
        
        _progressView = [AVVideoPlayProgressView new];
        _progressView.onProgressChangedByGesture = ^(float value) {
            if (weakSelf.onProgressViewDragingBlock) {
                weakSelf.onProgressViewDragingBlock(weakSelf, value);
            }
        };
        [self.contentView addSubview:_progressView];
        
        _infoLabel = [UILabel new];
        _infoLabel.textColor = [UIColor av_colorWithHexString:@"#FCFCFD"];
        _infoLabel.font = AVGetRegularFont(14);
        _infoLabel.numberOfLines = 2;
        _infoLabel.text = @"";
        [self.contentView addSubview:_infoLabel];
        
        _titleLabel = [UILabel new];
        _titleLabel.textColor = [UIColor av_colorWithHexString:@"#FFFFFF"];
        _titleLabel.font = AVGetMediumFont(16);
        _titleLabel.numberOfLines = 1;
        _titleLabel.text = @"";
        [self.contentView addSubview:_titleLabel];
        
        _likeBtn = [[AVBaseButton alloc] initWithType:AVBaseButtonTypeImageText titlePos:AVBaseButtonTitlePosBottom];
        _likeBtn.image = SECommonImage(@"ic_like");
        _likeBtn.selectedImage = SECommonImage(@"ic_like_selected");
        _likeBtn.title = @"0";
        _likeBtn.font = AVGetRegularFont(11);
        _likeBtn.action = ^(AVBaseButton * _Nonnull btn) {
            if (weakSelf.onLikeBtnClickBlock) {
                weakSelf.onLikeBtnClickBlock(weakSelf, weakSelf.likeBtn);
            }
        };
        [self.contentView addSubview:_likeBtn];
        
        _commentBtn = [[AVBaseButton alloc] initWithType:AVBaseButtonTypeImageText titlePos:AVBaseButtonTitlePosBottom];
        _commentBtn.image = SECommonImage(@"ic_comment");
        _commentBtn.title = @"0";
        _commentBtn.font = AVGetRegularFont(11);
        _commentBtn.action = ^(AVBaseButton * _Nonnull btn) {
            if (weakSelf.onCommentBtnClickBlock) {
                weakSelf.onCommentBtnClickBlock(weakSelf, weakSelf.commentBtn);
            }
        };
        [self.contentView addSubview:_commentBtn];
        
        _shareBtn = [[AVBaseButton alloc] initWithType:AVBaseButtonTypeImageText titlePos:AVBaseButtonTitlePosBottom];
        _shareBtn.image = SECommonImage(@"ic_share");
        _shareBtn.title = @"0";
        _shareBtn.font = AVGetRegularFont(11);
        _shareBtn.action = ^(AVBaseButton * _Nonnull btn) {
            if (weakSelf.onShareBtnClickBlock) {
                weakSelf.onShareBtnClickBlock(weakSelf, weakSelf.shareBtn);
            }
        };
        [self.contentView addSubview:_shareBtn];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.playerView.frame = self.contentView.bounds;
    self.playBtn.frame = self.contentView.bounds;
    
    self.topViewLayer.frame = CGRectMake(0, 0, self.contentView.av_width, AVSafeTop + 44);
    self.bottomViewLayer.frame = CGRectMake(0, self.contentView.av_height - 290, self.contentView.av_width, 290);
    self.backButton.frame = CGRectMake(20, AVSafeTop + 9, 26, 26);
    
    CGFloat y = self.contentView.av_height - (UIView.av_isIphoneX ? AVSafeBottom : 12);
    self.entranceView.frame = CGRectMake(20, y - 40, self.contentView.av_width - 20 - 20, 40);
    y = self.entranceView.av_top;
    
    self.progressView.frame = CGRectMake(20, y - 26, self.contentView.av_width - 20 - 20, 26);
    y = self.progressView.av_top;
    
    CGSize infoLabelSize = [self.infoLabel sizeThatFits:CGSizeMake(self.contentView.av_width - 20 - 80, 0)];
    self.infoLabel.frame = CGRectMake(20, y - infoLabelSize.height, infoLabelSize.width, infoLabelSize.height);
    y = self.infoLabel.av_top - 8;
    
    self.titleLabel.frame = CGRectMake(20, y - 24, self.contentView.av_width - 20 - 80, 24);
    
    y = self.contentView.av_height - 186;
    self.shareBtn.frame = CGRectMake(self.contentView.av_width - 48 - 4, y - 48, 48, 48);
    self.commentBtn.frame = CGRectMake(self.shareBtn.av_left, self.shareBtn.av_top - 12 - 48, 48, 48);
    self.likeBtn.frame = CGRectMake(self.shareBtn.av_left, self.commentBtn.av_top - 12 - 48, 48, 48);
}

- (void)onEntranceClicked {
    if (self.onEntranceViewClickBlock) {
        self.onEntranceViewClickBlock(self);
    }
}

- (void)setEpisodeTitle:(NSString *)episodeTitle {
    _episodeTitle = episodeTitle;
    self.entranceView.titleLabel.text = _episodeTitle;
}

- (void)setVideoInfo:(AUIVideoInfo *)videoInfo {
    _videoInfo = videoInfo;
        
    [self.playerView removeFromSuperview];
    self.playerView = [[UIView alloc] initWithFrame:self.playerView.frame];
    [self.contentView insertSubview:self.playerView belowSubview:self.playBtn];

    self.isLoading = YES;
    self.isPause = NO;
    self.progress = 0.0;
    
    [self refreshUI];
}

- (void)setIsLoading:(BOOL)isLoading {
    _isLoading = isLoading;
}

- (void)setIsPause:(BOOL)isPause {
    _isPause = isPause;
    self.playBtn.selected = _isPause;
    self.progressView.viewStyle = _isPause ? AVVideoPlayProgressViewStyleHighlight : AVVideoPlayProgressViewStyleNormal;
}

- (void)setProgress:(CGFloat)progress {
    if (progress < 0) {
        progress = 0.0;
    }
    else if (progress > 1.0) {
        progress = 1.0;
    }
    _progress = progress;
    self.progressView.progress = _progress;
}

- (void)refreshUI {
    self.titleLabel.text = [NSString stringWithFormat:@"@%@", _videoInfo.author];
    self.infoLabel.text = _videoInfo.title;
    self.likeBtn.title = [AVStringFormat formatWithCount:_videoInfo.likeCount];
    self.likeBtn.selected = _videoInfo.isLiked;
    self.commentBtn.title = [AVStringFormat formatWithCount:_videoInfo.commentCount];
    self.shareBtn.title = [AVStringFormat formatWithCount:_videoInfo.shareCount];
}

@end
