//
//  AUIVideoPlayTimeView.m
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/6/3.
//

#import "AUIVideoPlayTimeView.h"
#import "AUIUgsvMacro.h"

@interface AUIVideoPlayTimeView () <AUIVideoPlayObserver>

@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIButton *fullScreenBtn;

@end

@implementation AUIVideoPlayTimeView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = AUIFoundationColor(@"bg_medium");
        
        UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        timeLabel.text = @"00:00/00:00";
        timeLabel.textColor = AUIFoundationColor(@"text_strong");
        timeLabel.font = AVGetRegularFont(12);
        [self addSubview:timeLabel];
        self.timeLabel = timeLabel;
        
        
        UIButton *play = [[UIButton alloc] initWithFrame:CGRectZero];
        play.titleEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
        [play setImage:AUIUgsvEditorImage(@"ic_preview_play") forState:UIControlStateNormal];
        [play setImage:AUIUgsvEditorImage(@"ic_preview_pause") forState:UIControlStateSelected];
        [play addTarget:self action:@selector(onPlayClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:play];
        self.playButton = play;
        
        UIButton *fullScreen = [[UIButton alloc] initWithFrame:CGRectZero];
        fullScreen.titleEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
        [fullScreen setImage:AUIUgsvEditorImage(@"ic_preview_fullscreen") forState:UIControlStateNormal];
        [fullScreen addTarget:self action:@selector(onFullScreenClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:fullScreen];
        self.fullScreenBtn = fullScreen;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.timeLabel.frame = CGRectMake(20, (self.av_height - 18) / 2.0, self.av_width, 18);
    self.playButton.frame = CGRectMake((self.av_width - self.av_height) / 2.0, 0, self.av_height, self.av_height);
    self.fullScreenBtn.frame = CGRectMake(self.av_width - 10 - self.av_height, 0, self.av_height, self.av_height);
}

- (void)onPlayClicked:(UIButton *)sender {
    if (self.player.isPlaying) {
        [self.player pause];
    }
    else {
        [self.player play];
    }
}

- (void)onFullScreenClicked:(UIButton *)sender {
    if (self.onEnterFullScreenClicked) {
        self.onEnterFullScreenClicked();
    }
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
        [self refreshPlayButton];
    }
}

- (void)refreshTimeLabel {
    NSTimeInterval current =  [self.player playRangeTime];
    NSTimeInterval duration =  [self.player playRangeDuration];
    self.timeLabel.text = [NSString stringWithFormat:@"%@/%@", [AVStringFormat formatWithDuration:current], [AVStringFormat formatWithDuration:duration]];
}

- (void)refreshPlayButton {
    self.playButton.selected = self.player.isPlaying;
}

#pragma AlivcPlayManagerObserver

- (void)playerDidLoaded {
    [self refreshTimeLabel];
}

- (void)playStatus:(BOOL)isPlaying {
    [self refreshPlayButton];
}

- (void)playError:(NSInteger)errorCode {
    NSLog(@"playError:%zd", errorCode);
}

- (void)playProgress:(double)progress {
    [self refreshTimeLabel];
}

@end
