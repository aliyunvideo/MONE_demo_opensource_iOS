//
//  AUILiveBgMusicPlaySettingCell.m
//  AlivcLiveDemo
//
//  Created by ISS013602000846 on 2022/7/6.
//

#import "AUILiveBgMusicPlaySettingCell.h"

@interface AUILiveBgMusicPlaySettingCell ()

@property (nonatomic, strong) UIView *container;
@property (nonatomic, strong) UILabel *name;
@property (nonatomic, strong) UIImageView *playImage;
@property (nonatomic, strong) UISlider *playSlider;
@property (nonatomic, strong) UILabel *progressTimeLabel;
@property (nonatomic, strong) UILabel *durationTimeLabel;
@property (nonatomic, strong) UIButton *muteButton;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UIButton *loopButton;
@property (nonatomic, strong) UILabel *accompanimentLabel;
@property (nonatomic, strong) UISlider *accompanimentSlider;
@property (nonatomic, strong) UILabel *humanVoiceLabel;
@property (nonatomic, strong) UISlider *humanVoiceSlider;

@property (nonatomic, strong) AlivcLiveMusicInfoModel *currentMusicModel;
@property (nonatomic, assign) AUILiveBgMusicPlayStatus currentPlayStatus;

@end

@implementation AUILiveBgMusicPlaySettingCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = AUIFoundationColor(@"bg_medium");
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.container = [[UIView alloc] init];
        self.container.backgroundColor = AUIFoundationColor(@"bg_weak");
        self.container.layer.masksToBounds = YES;
        self.container.layer.cornerRadius = 8;
        [self.contentView addSubview:self.container];
        
        [self.container addSubview:self.name];
        [self.container addSubview:self.playImage];
        [self.container addSubview:self.playSlider];
        [self.container addSubview:self.progressTimeLabel];
        [self.container addSubview:self.durationTimeLabel];
        [self.container addSubview:self.muteButton];
        [self.container addSubview:self.playButton];
        [self.container addSubview:self.loopButton];
        [self.container addSubview:self.accompanimentLabel];
        [self.container addSubview:self.accompanimentSlider];
        [self.container addSubview:self.humanVoiceLabel];
        [self.container addSubview:self.humanVoiceSlider];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.container.frame = CGRectMake(20, 16, self.contentView.av_width - 20 * 2, self.contentView.av_height - 16 * 2);
    self.name.frame = CGRectMake(20, 18, self.playImage.av_left - 20, 24);
    
    UIImage *playImg =  AUILiveCameraPushImage(@"ic_music_note");
    CGSize playImgSize = CGSizeMake(20, 20 * (playImg.size.height / playImg.size.width));
    self.playImage.frame = CGRectMake(self.container.av_width - 20 - playImgSize.width, 0, playImgSize.width, playImgSize.height);
    self.playImage.av_centerY = self.name.av_centerY;
    
    self.playSlider.frame = CGRectMake(self.name.av_left, self.name.av_bottom + 12, self.playImage.av_right - self.name.av_left, 24);
    self.progressTimeLabel.frame = CGRectMake(self.name.av_left, self.playSlider.av_bottom + 6, self.container.av_width / 2.0 - self.playSlider.av_left, 24);
    self.durationTimeLabel.frame = CGRectMake(self.container.av_width / 2.0, self.progressTimeLabel.av_top, self.progressTimeLabel.av_width, 24);
    self.muteButton.frame = CGRectMake(self.name.av_left, self.progressTimeLabel.av_bottom + 13, 24, 24);
    self.playButton.frame = CGRectMake(self.container.av_width / 2.0 - 24 / 2.0, self.muteButton.av_top, 24, 24);
    self.loopButton.frame = CGRectMake(self.playSlider.av_right - 24, self.muteButton.av_top, 24, 24);
    self.accompanimentLabel.frame = CGRectMake(self.name.av_left, self.muteButton.av_bottom + 33, self.playSlider.av_width, 24);
    self.accompanimentSlider.frame = CGRectMake(self.name.av_left, self.accompanimentLabel.av_bottom + 9, self.playSlider.av_width, 24);
    self.humanVoiceLabel.frame = CGRectMake(self.name.av_left, self.accompanimentSlider.av_bottom + 30, self.playSlider.av_width, 24);
    self.humanVoiceSlider.frame = CGRectMake(self.name.av_left, self.humanVoiceLabel.av_bottom + 9, self.playSlider.av_width, 24);
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)startPlayWithModel:(AlivcLiveMusicInfoModel *)model {
    self.currentMusicModel = model;
    self.currentPlayStatus = AUILiveBgMusicPlayStatusStart;
    
    self.name.text = model.name;
    [self updatePlayProgressTime:0 durationTime:(long)model.duration];
    
    self.muteButton.selected = NO;
    if (self.switchMuteAction) {
        self.switchMuteAction(NO);
    }
    
    // self.playButton.enabled = YES;
    // self.playButton.selected = YES;
    if (self.switchPlayAction) {
        self.switchPlayAction(YES, model.path);
    }
    
    self.loopButton.selected = YES;
    if (self.switchLoopAction) {
        self.switchLoopAction(YES);
    }
}

- (void)updatePlayProgressTime:(long)progressTime durationTime:(long)durationTime {
    if (progressTime > 0 && durationTime > 0) {
        self.muteButton.enabled = YES;
        
        self.playButton.enabled = YES;
        self.playButton.selected = YES;
        
        self.loopButton.enabled = YES;
        
        self.playSlider.value = (CGFloat)progressTime / (CGFloat)durationTime;
        self.progressTimeLabel.text = [self convertTimeStrAt:progressTime];
        self.durationTimeLabel.text = [self convertTimeStrAt:durationTime];
        
        self.accompanimentSlider.enabled = YES;
        self.humanVoiceSlider.enabled = YES;
    } else {
        self.muteButton.enabled = NO;
        
        self.playButton.enabled = NO;
        self.playButton.selected = NO;
        
        self.loopButton.enabled = NO;
        
        self.playSlider.value = 0;
        self.progressTimeLabel.text = [self convertTimeStrAt:progressTime];
        self.durationTimeLabel.text = [self convertTimeStrAt:durationTime];
    }
}

- (void)resetPlayStatusWithError {
    self.currentPlayStatus = AUILiveBgMusicPlayStatusNone;
    
    self.muteButton.selected = NO;
    self.muteButton.enabled = NO;
    
    self.playButton.selected = NO;
    self.playButton.enabled = NO;
    
    self.loopButton.selected = NO;
    self.loopButton.enabled = NO;
}

- (NSString *)convertTimeStrAt:(long)time {
    if (time == 0) {
        return @"00:00";
    }
    int timeSecond = (int)time/1000;
    int timeM = timeSecond/60;
    int timeS = timeSecond-timeM*60;
    return [NSString stringWithFormat:@"%02d:%02d", timeM, timeS];
}

- (void)onMuteButtonClick:(UIButton *)sender {
    self.muteButton.selected = !sender.selected;
    
    self.accompanimentSlider.enabled = !self.muteButton.selected;
    self.humanVoiceSlider.enabled = !self.muteButton.selected;
    
    if (self.switchMuteAction) {
        self.switchMuteAction(self.muteButton.selected);
    }
}

- (void)onPlayButtonClick:(UIButton *)sender {
    self.playButton.selected = !sender.selected;
    if (self.playButton.selected) {
        self.currentPlayStatus = AUILiveBgMusicPlayStatusResume;
    } else {
        self.currentPlayStatus = AUILiveBgMusicPlayStatusPause;
    }
    if (self.switchPlayAction) {
        self.switchPlayAction(self.currentPlayStatus, self.currentMusicModel.path);
    }
}

- (void)onLoopButtonClick:(UIButton *)sender {
    self.loopButton.selected = !sender.selected;
    if (self.switchLoopAction) {
        self.switchLoopAction(self.loopButton.selected);
    }
}

- (void)playSilderValueDidChanged:(UISlider *)sender {
    
}

- (void)accompanimentSliderValueDidChanged:(UISlider *)sender {
    if (self.accompanimentChangeAction) {
        self.accompanimentChangeAction(sender.value);
    }
}

- (void)humanVoiceSliderValueDidChanged:(UISlider *)sender {
    if (self.humanVoiceChangeAction) {
        self.humanVoiceChangeAction(sender.value);
    }
}

- (UILabel *)name {
    if (!_name) {
        _name = [[UILabel alloc] init];
        _name.textColor = AUIFoundationColor(@"text_strong");
        _name.font = AVGetMediumFont(16);
    }
    return _name;
}

- (UIImageView *)playImage {
    if (!_playImage) {
        _playImage = [[UIImageView alloc] init];
        _playImage.image = AUILiveCameraPushImage(@"ic_music_note");
    }
    return _playImage;
}

- (UISlider *)playSlider {
    if (!_playSlider) {
        _playSlider = [[UISlider alloc] init];
        _playSlider.tintColor = AUIFoundationColor(@"colourful_fill_strong");
        _playSlider.minimumValue = 0;
        _playSlider.maximumValue = 1;
        _playSlider.value = 0;
        [_playSlider addTarget:self action:@selector(playSilderValueDidChanged:) forControlEvents:UIControlEventValueChanged];
        _playSlider.userInteractionEnabled = NO;
    }
    return _playSlider;
}

- (UILabel *)progressTimeLabel {
    if (!_progressTimeLabel) {
        _progressTimeLabel = [[UILabel alloc] init];
        _progressTimeLabel.textColor = AUIFoundationColor(@"text_ultraweak");
        _progressTimeLabel.font = AVGetRegularFont(12);
        _progressTimeLabel.text = @"--:--";
    }
    return _progressTimeLabel;
}

- (UILabel *)durationTimeLabel {
    if (!_durationTimeLabel) {
        _durationTimeLabel = [[UILabel alloc] init];
        _durationTimeLabel.textColor = AUIFoundationColor(@"text_ultraweak");
        _durationTimeLabel.font = AVGetRegularFont(12);
        _durationTimeLabel.textAlignment = NSTextAlignmentRight;
        _durationTimeLabel.text = @"--:--";
    }
    return _durationTimeLabel;
}

- (UIButton *)muteButton {
    if (!_muteButton) {
        _muteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_muteButton setImage:AUILiveCameraPushImage(@"music_mute") forState:UIControlStateNormal];
        [_muteButton setImage:AUILiveCameraPushImage(@"music_mute_selected") forState:UIControlStateSelected];
        [_muteButton addTarget:self action:@selector(onMuteButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _muteButton;
}

- (UIButton *)playButton {
    if (!_playButton) {
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playButton setImage:AUILiveCameraPushImage(@"music_pause") forState:UIControlStateNormal];
        [_playButton setImage:AUILiveCameraPushImage(@"music_pause_selected") forState:UIControlStateSelected];
        [_playButton addTarget:self action:@selector(onPlayButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        _playButton.selected = YES;
    }
    return _playButton;
}

- (UIButton *)loopButton {
    if (!_loopButton) {
        _loopButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_loopButton setImage:AUILiveCameraPushImage(@"music_loop_simple_line") forState:UIControlStateNormal];
        [_loopButton setImage:AUILiveCameraPushImage(@"music_loop_simple_line_selected") forState:UIControlStateSelected];
        [_loopButton addTarget:self action:@selector(onLoopButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _loopButton;
}

- (UILabel *)accompanimentLabel {
    if (!_accompanimentLabel) {
        _accompanimentLabel = [[UILabel alloc] init];
        _accompanimentLabel.textColor = AUIFoundationColor(@"text_strong");
        _accompanimentLabel.font = AVGetRegularFont(15);
        _accompanimentLabel.text = AUILiveCameraPushString(@"伴奏音量");
    }
    return _accompanimentLabel;
}

- (UISlider *)accompanimentSlider {
    if (!_accompanimentSlider) {
        _accompanimentSlider = [[UISlider alloc] init];
        _accompanimentSlider.tintColor = AUIFoundationColor(@"colourful_fill_strong");
        _accompanimentSlider.minimumValue = 0;
        _accompanimentSlider.maximumValue = 100;
        _accompanimentSlider.value = 50;
        [_accompanimentSlider addTarget:self action:@selector(accompanimentSliderValueDidChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _accompanimentSlider;
}

- (UILabel *)humanVoiceLabel {
    if (!_humanVoiceLabel) {
        _humanVoiceLabel = [[UILabel alloc] init];
        _humanVoiceLabel.textColor = AUIFoundationColor(@"text_strong");
        _humanVoiceLabel.font = AVGetRegularFont(15);
        _humanVoiceLabel.text = AUILiveCameraPushString(@"人声音量");
    }
    return _humanVoiceLabel;
}

- (UISlider *)humanVoiceSlider {
    if (!_humanVoiceSlider) {
        _humanVoiceSlider = [[UISlider alloc] init];
        _humanVoiceSlider.tintColor = AUIFoundationColor(@"colourful_fill_strong");
        _humanVoiceSlider.minimumValue = 0;
        _humanVoiceSlider.maximumValue = 100;
        _humanVoiceSlider.value = 50;
        [_humanVoiceSlider addTarget:self action:@selector(humanVoiceSliderValueDidChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _humanVoiceSlider;
}


@end
