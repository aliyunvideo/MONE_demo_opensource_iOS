//
//  AUIVideoFlowCardCell.m
//  ApsaraVideo
//
//  Created by Bingo on 2021/7/4.
//

#import "AUIVideoFlowCardCell.h"
#import "AlivcPlayerFoundation.h"
#import "AlivcPlayerManager.h"
#import "AUIPlayerFeedListVideoContainer.h"

@interface AUIVideoFlowCardCell ()

@property (nonatomic, strong) UIView *videoContainer;
@property (nonatomic, strong) UIImageView *coverImage;
@property (nonatomic, strong) UIView *videoView;
@property (nonatomic, strong) UILabel *durationLabel;
@property (nonatomic, strong) UIButton *playBtn;

@property (nonatomic, strong) UIView *infoContainer;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *userBtn;
@property (nonatomic, strong) UIButton *commentBtn;


@end

@implementation AUIVideoFlowCardCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    
    self.backgroundColor = AUIFoundationColor(@"fg_strong");
    self.layer.cornerRadius = 4;
    [self.contentView av_setLayerBorderColor:AUIFoundationColor(@"border_weak")];
    self.clipsToBounds = YES;
    self.layer.masksToBounds = YES;
    
    self.videoContainer = [AUIPlayerFeedListVideoContainer new];
    self.videoContainer.accessibilityIdentifier = AUIVideoFlowAccessibilityStr(@"videoFlowPage_videoContainer");
    self.videoContainer.backgroundColor = AUIVideoFlowColor(@"vf_video_bg");
    [self.contentView addSubview:self.videoContainer];
    
    self.coverImage = [UIImageView new];
    self.coverImage.accessibilityIdentifier = AUIVideoFlowAccessibilityStr(@"videoFlowPage_coverImage");
    [self.videoContainer addSubview:self.coverImage];
    
    self.durationLabel = [UILabel new];
    self.durationLabel.accessibilityIdentifier = AUIVideoFlowAccessibilityStr(@"videoFlowPage_durationLabel");
    self.durationLabel.textColor = AUIFoundationColor(@"ic_strong");
    self.durationLabel.font = AVGetRegularFont(12);
    self.durationLabel.text = @"01:00";
    [self.videoContainer addSubview:self.durationLabel];
    
    self.playBtn = [UIButton new];
    self.playBtn.accessibilityIdentifier = AUIVideoFlowAccessibilityStr(@"videoFlowPage_playBtn");
    [self.playBtn setImage:AUIVideoFlowImage(@"common_play") forState:UIControlStateNormal];
    [self.playBtn addTarget:self action:@selector(onPlayBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.videoContainer addSubview:self.playBtn];
    
    self.videoView = [UIView new];
    self.videoView.accessibilityIdentifier = AUIVideoFlowAccessibilityStr(@"videoFlowPage_videoView");
    self.videoView.hidden = YES;
    [self.videoContainer addSubview:self.videoView];
    
    self.infoContainer = [UIView new];
    self.infoContainer.accessibilityIdentifier = AUIVideoFlowAccessibilityStr(@"videoFlowPage_infoContainer");
    self.infoContainer.userInteractionEnabled = YES;
    [self.infoContainer addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onInfoContainerClicked:)]];
    [self.contentView addSubview:self.infoContainer];
    
    self.titleLabel = [UILabel new];
    self.titleLabel.accessibilityIdentifier = AUIVideoFlowAccessibilityStr(@"videoFlowPage_titleLabel");
    self.titleLabel.textColor = AUIFoundationColor(@"text_strong");
    self.titleLabel.font = AVGetRegularFont(14);
    self.titleLabel.text = @"";
    [self.infoContainer addSubview:self.titleLabel];
    
    self.userBtn = [UIButton new];
    self.userBtn.accessibilityIdentifier = AUIVideoFlowAccessibilityStr(@"videoFlowPage_userBtn");
    self.userBtn.imageView.layer.cornerRadius = 10.0f;
    self.userBtn.imageView.layer.masksToBounds = YES;
    self.userBtn.titleLabel.font = AVGetRegularFont(12);
    self.userBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 4, 0, -4);
    self.userBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    [self.userBtn setTitleColor:AUIFoundationColor(@"text_medium") forState:UIControlStateNormal];
    [self.userBtn setTitle:@"" forState:UIControlStateNormal];
    [self.userBtn setImage:AUIVideoFlowImage(@"comment_avatar") forState:UIControlStateNormal];
    [self.userBtn addTarget:self action:@selector(onUserBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.infoContainer addSubview:self.userBtn];
    
    self.commentBtn = [UIButton new];
    self.commentBtn.accessibilityIdentifier = AUIVideoFlowAccessibilityStr(@"videoFlowPage_commentBtn");
    self.commentBtn.titleLabel.font = AVGetRegularFont(12);
    self.commentBtn.imageEdgeInsets = UIEdgeInsetsMake(3, 0, 3, 0);
    self.commentBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
//    [self.commentBtn setTitleColor:AUIFoundationColor(@"text_medium") forState:UIControlStateNormal];
//    [self.commentBtn setImage:AUIVideoFlowImage(@"common_comment") forState:UIControlStateNormal];
    [self.commentBtn setTitle:AUIVideoFlowString(@"Card_Detail") forState:UIControlStateNormal];
    [self.commentBtn addTarget:self action:@selector(onCommentBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.infoContainer addSubview:self.commentBtn];
    
    [self.videoContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.equalTo(self.contentView);
        make.height.equalTo(self.videoContainer.mas_width).multipliedBy(9.0f/16.0f);
    }];
    [self.coverImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.equalTo(self.videoContainer);
    }];
    [self.videoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.equalTo(self.videoContainer);
    }];
    [self.durationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.videoContainer).offset(-12);
        make.leading.greaterThanOrEqualTo(self.videoContainer);
        make.bottom.equalTo(self.videoContainer).offset(-8);
        make.top.greaterThanOrEqualTo(self.videoContainer);
    }];
    [self.playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.equalTo(self.videoContainer);
    }];
    
    [self.infoContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.videoContainer);
        make.bottom.equalTo(self.contentView);
        make.top.equalTo(self.videoContainer.mas_bottom);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.infoContainer).offset(12);
        make.trailing.equalTo(self.infoContainer).offset(-12);
        make.top.equalTo(self.infoContainer).offset(7);
        make.height.mas_equalTo(self.titleLabel.font.lineHeight);
    }];
    [self.commentBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.titleLabel);
        make.leading.greaterThanOrEqualTo(self.titleLabel);
        make.height.mas_equalTo(20);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(8);
    }];
    [self.userBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.titleLabel);
        make.trailing.lessThanOrEqualTo(self.commentBtn);
        make.height.equalTo(self.commentBtn);
        make.top.equalTo(self.commentBtn);
    }];
}

- (void)setItem:(AlivcPlayerVideo *)item {
    _item = item;
    self.titleLabel.text = item.title;
    if (item.coverUrl.length > 0) {
        [self.coverImage sd_setImageWithURL:[NSURL URLWithString:item.coverUrl]];
    }
    else {
        self.coverImage.image = nil;
    }
    self.durationLabel.text = [AVStringFormat formatWithDuration:item.duration];
    [self.userBtn setTitle:item.user.userName forState:UIControlStateNormal];
    if (item.user.avatarUrl.length > 0) {
        [self.userBtn sd_setImageWithURL:[NSURL URLWithString:item.user.avatarUrl] forState:UIControlStateNormal placeholderImage:AUIVideoFlowImage(@"comment_avatar")];
    }
    else {
        [self.userBtn setImage:AUIVideoFlowImage(@"comment_avatar") forState:UIControlStateNormal];
    }
    //[self.commentBtn setTitle:[NSString stringWithFormat:@"%d", item.commentCount] forState:UIControlStateNormal];
}

- (void)onPlayBtnClicked:(UIButton *)sender {
    NSLog(@"Play video...");
    
    if ([self.delegate respondsToSelector:@selector(homeCardCellPlayButtonClick:)]) {
        [self.delegate homeCardCellPlayButtonClick:self];
    }
}

- (void)onUserBtnClicked:(UIButton *)sender {
    NSLog(@"Open user page...");
    [self.delegate homeCardCellDetailClick:self];

}

- (void)onCommentBtnClicked:(UIButton *)sender {
    NSLog(@"Open comment detail...");
    [self.delegate homeCardCellDidClickCommentButton:self];
}

- (void)onInfoContainerClicked:(UITapGestureRecognizer *)recognizer {
    [self.delegate homeCardCellDetailClick:self];
}
@end
