//
//  AUIVideoPlayProgressView.m
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/6/7.
//

#import "AUIVideoPlayProgressView.h"
#import "AUIUgsvMacro.h"

@interface AUIVideoPlayProgressView () <AUIVideoPlayObserver>

@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) AVSliderView *progressView;
@property (nonatomic, strong) UILabel *durationLabel;
@property (nonatomic, strong) UIButton *fullScreenBtn;

@property (nonatomic, assign) BOOL seekTimeChangedByMoving;

@end

@implementation AUIVideoPlayProgressView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = AUIFoundationColor(@"bg_medium");
        
        UIButton *play = [[UIButton alloc] initWithFrame:CGRectZero];
        play.titleEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
        [play setImage:AUIUgsvEditorImage(@"ic_preview_play") forState:UIControlStateNormal];
        [play setImage:AUIUgsvEditorImage(@"ic_preview_pause") forState:UIControlStateSelected];
        [play addTarget:self action:@selector(onPlayClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:play];
        self.playButton = play;
        
        UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        timeLabel.text = @"00:00";
        timeLabel.textColor = AUIFoundationColor(@"text_strong");
        timeLabel.font = AVGetRegularFont(12);
        [self addSubview:timeLabel];
        self.timeLabel = timeLabel;

        __weak typeof(self) weakSelf = self;
        AVSliderView *progressView = [[AVSliderView alloc] initWithFrame:CGRectZero];
        progressView.onValueChangedByGesture = ^(float progress, UIGestureRecognizer * _Nonnull gesture) {
            [weakSelf onValueChanged:progress gesture:gesture];
        };
        [self addSubview:progressView];
        self.progressView = progressView;
        
        
        UILabel *durationLabel = [UILabel new];
        durationLabel.text = @"00:00";
        durationLabel.textColor = AUIFoundationColor(@"text_strong");
        durationLabel.font = AVGetRegularFont(12);
        durationLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:durationLabel];
        self.durationLabel = durationLabel;
        
        UIButton *fullScreen = [[UIButton alloc] initWithFrame:CGRectZero];
        fullScreen.titleEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
        [fullScreen setImage:AUIUgsvEditorImage(@"ic_preview_unfullscreen") forState:UIControlStateNormal];
        [fullScreen addTarget:self action:@selector(onFullScreenBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:fullScreen];
        self.fullScreenBtn = fullScreen;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.timeLabel.frame = CGRectMake(20, (self.av_height - 18) / 2.0, self.av_width, 18);
    self.fullScreenBtn.frame = CGRectMake(self.av_width - 10 - self.av_height, 0, self.av_height, self.av_height);
    
    
    self.playButton.frame = CGRectMake(20, 0, self.av_height, self.av_height);
    self.fullScreenBtn.frame = CGRectMake(self.av_width - 20 - self.av_height, 0, self.av_height, self.av_height);

    [self.durationLabel sizeToFit];
    CGFloat timeLabelWidth = self.durationLabel.av_width + 10 + 10;
    self.timeLabel.frame = CGRectMake(self.playButton.av_right, 0, timeLabelWidth, self.av_height);
    self.durationLabel.frame = CGRectMake(self.fullScreenBtn.av_left - timeLabelWidth, 0, timeLabelWidth, self.av_height);
    self.progressView.frame = CGRectMake(self.timeLabel.av_right, 0, self.durationLabel.av_left - self.timeLabel.av_right, self.av_height);
}

- (void)setPlayer:(id<AUIVideoPlayProtocol>)player {
    if (player != _player) {
        [_player removeObserver:self];
        _player = nil;
    }
    if (player) {
        _player = player;
        [_player addObserver:self];
        [self refreshTimeLabel];
        [self refreshSlideView];
        [self refreshPlayButton];
    }
}

- (void)onPlayClicked:(UIButton *)sender {
    if (self.player.isPlaying) {
        [self.player pause];
    }
    else {
        [self.player play];
    }
}

- (void)onValueChanged:(float)value gesture:(UIGestureRecognizer *)gesture {
    switch(gesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            [self.player pause];
            self.seekTimeChangedByMoving = YES;
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            NSTimeInterval time = [self.player playRangeDuration] * self.progressView.value + self.player.playRangeStart;
            [self.player seek:time];
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        {
            NSTimeInterval time = [self.player playRangeDuration] * self.progressView.value + self.player.playRangeStart;
            [self.player seek:time];
            self.seekTimeChangedByMoving = NO;
        }
            break;
        default:
            break;
    }
}

- (void)onFullScreenBtnClicked:(UIButton *)sender {
    if (self.onFullScreenBtnClicked) {
        self.onFullScreenBtnClicked();
    }
}

- (void)refreshTimeLabel {
    NSTimeInterval current = [self.player playRangeTime];
    NSTimeInterval duration = [self.player playRangeDuration];
    self.timeLabel.text = [AVStringFormat formatWithDuration:current];
    self.durationLabel.text = [AVStringFormat formatWithDuration:duration];
}

- (void)refreshSlideView {
    NSTimeInterval current = [self.player playRangeTime];
    NSTimeInterval duration = [self.player playRangeDuration];
    self.progressView.value = duration > 0 ? current / duration : 0;
}

- (void)refreshPlayButton {
    self.playButton.selected = self.player.isPlaying;
}

#pragma AlivcPlayManagerObserver

- (void)playerDidLoaded {
    [self refreshTimeLabel];
    [self refreshSlideView];
}

- (void)playStatus:(BOOL)isPlaying {
    [self refreshPlayButton];
}

- (void)playError:(NSInteger)errorCode {
    NSLog(@"playError:%zd", errorCode);
}

- (void)playProgress:(double)progress {
    if (!self.seekTimeChangedByMoving) {
        [self refreshSlideView];
    }
    [self refreshTimeLabel];
}

@end
