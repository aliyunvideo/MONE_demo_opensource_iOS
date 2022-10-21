//
//  AUIMusicCropView.m
//  AlivcUgsvDemo
//
//  Created by coder.pi on 2022/6/9.
//

#import "AUIMusicCropView.h"
#import "AUIUgsvMacro.h"
#import "Masonry.h"
#import "AUIMusicPCMLineView.h"
#import <AVFoundation/AVFoundation.h>

@interface AUIMusicCropView() <UIScrollViewDelegate, AUIVideoPlayObserver>

@property (nonatomic, strong) UILabel *beginTimeLabel;
@property (nonatomic, strong) UILabel *endTimeLabel;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *selectedFrameView;
@property (nonatomic, strong) AUIMusicPCMLineView *pcmView;
@property (nonatomic, strong) AUIMusicPCMLineView *playingPCMView;
@property (nonatomic, assign) BOOL isPlaying;
@property (nonatomic, assign) NSTimeInterval duration;

@end

@implementation AUIMusicCropView

- (void) dealloc {
    [self.player removeObserver:self];
}

- (instancetype)initWithLimitDuration:(NSTimeInterval)limitDuration
                        selectedModel:(AUIMusicSelectedModel *)selectedModel
                               player:(id<AUIVideoPlayProtocol>)player {
    self = [super init];
    if (self) {
        _limitDuration = limitDuration;
        _model = selectedModel;
        self.player = player;
        [self setup];
        [self updateUI];
    }
    return self;
}

- (NSTimeInterval)duration {
    if (_duration == 0) {
        AVAsset *asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:self.model.localPath]];
        _duration = CMTimeGetSeconds(asset.duration);
    }
    return _duration;
}

static NSString * s_formatTime(NSTimeInterval duration) {
    int dur = duration;
    int sec = dur % 60;
    int min = dur / 60;
    return [NSString stringWithFormat:@"%02d:%02d", min, sec];
}

- (void)setPlayer:(id<AUIVideoPlayProtocol>)player {
    if (_player == player) {
        return;
    }
    [_player removeObserver:self];
    _player = player;
    [_player addObserver:self];
    [self onConfirmChange:NO];
}

- (void)updateUI {
    _beginTimeLabel.text = s_formatTime(_model.beginTime);
    _endTimeLabel.text = s_formatTime(_model.beginTime + _limitDuration);
}

static const CGFloat kSelectedFrameOffset = 2.0; // 选中框的修正偏移（图片偏差）

- (void)setup {
    if (_scrollView) {
        return;
    }
    
    _scrollView = [UIScrollView new];
    _scrollView.delegate = self;
    _scrollView.backgroundColor = UIColor.clearColor;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.bounces = NO;
    [self addSubview:_scrollView];
    [_scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self).inset(20.0);
        make.height.mas_equalTo(30.0);
        make.top.equalTo(self).inset(33.0);
    }];
    _pcmView = [[AUIMusicPCMLineView alloc] initWithFile:_model.localPath];
    [_scrollView addSubview:_pcmView];

    UIImageView *centerMask = [[UIImageView alloc] initWithImage:AUIUgsvGetImage(@"ic_music_crop")];
    [self addSubview:centerMask];
    [centerMask mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(_scrollView);
    }];
    _selectedFrameView = centerMask;

    UIView *leftMask = [UIView new];
    leftMask.userInteractionEnabled = NO;
    leftMask.backgroundColor = AUIFoundationColor(@"tsp_fill_weak");
    [self addSubview:leftMask];
    [leftMask mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_scrollView);
        make.right.equalTo(centerMask.mas_left).offset(kSelectedFrameOffset);
        make.height.equalTo(centerMask);
        make.centerY.equalTo(centerMask);
    }];
    UIView *rightMask = [UIView new];
    rightMask.userInteractionEnabled = NO;
    rightMask.backgroundColor = AUIFoundationColor(@"tsp_fill_weak");
    [self addSubview:rightMask];
    [rightMask mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_scrollView);
        make.left.equalTo(centerMask.mas_right);
        make.height.equalTo(centerMask);
        make.centerY.equalTo(centerMask);
    }];

    UILabel *tip = [UILabel new];
    tip.textColor = AUIFoundationColor(@"text_ultraweak");
    tip.font = AVGetRegularFont(10.0);
    tip.text = AUIUgsvGetString(@"拖动选择音乐片段");
    [self addSubview:tip];
    [tip mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).inset(20.0);
        make.top.equalTo(self).inset(10.0);
    }];
    
    _beginTimeLabel = [UILabel new];
    _beginTimeLabel.textColor = AUIFoundationColor(@"text_ultraweak");
    _beginTimeLabel.font = AVGetRegularFont(10.0);
    _beginTimeLabel.text = @"00:00";
    [self addSubview:_beginTimeLabel];
    [_beginTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(tip);
        make.left.equalTo(centerMask.mas_left);
    }];
    
    _endTimeLabel = [UILabel new];
    _endTimeLabel.textColor = AUIFoundationColor(@"text_ultraweak");
    _endTimeLabel.font = AVGetRegularFont(10.0);
    _endTimeLabel.text = @"00:00";
    [self addSubview:_endTimeLabel];
    [_endTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(tip);
        make.right.equalTo(centerMask.mas_right);
    }];
}

const CGFloat kCropWidth = 124.0;
- (CGFloat)pixelPreSecond {
    return kCropWidth / _limitDuration;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    NSTimeInterval duration = self.duration;
    if (duration == 0) {
        return;
    }
    
    CGFloat offset = (_scrollView.frame.size.width - kCropWidth) * 0.5;
    _pcmView.realShowPercentage = duration / _limitDuration;
    _playingPCMView.realShowPercentage = _pcmView.realShowPercentage;
    duration = MAX(duration, _limitDuration);
    CGRect pcmViewFrame = CGRectMake(offset + kSelectedFrameOffset * 0.5, 0, 0, 0);
    
    CGSize size = _scrollView.frame.size;
    size.width = self.pixelPreSecond * duration;
    pcmViewFrame.size = size;
    size.width += 2 * offset;

    _scrollView.contentSize = size;
    _pcmView.frame = pcmViewFrame;
    [_pcmView refresh];
    [self updateScrollOffset];
}

- (void)updateScrollOffset {
    CGFloat beginTime = _model.beginTime;
    CGFloat offset = beginTime * self.pixelPreSecond;
    _scrollView.contentOffset = CGPointMake(offset, 0);
}

- (void)updateTime {
    _model.beginTime = MAX(0.0, _scrollView.contentOffset.x / self.pixelPreSecond);
    _model.endTime = MIN(self.duration, _model.beginTime + _limitDuration);
    [self updateUI];
}

- (void)onConfirmChange:(BOOL)needNotify {
    if (!self.superview) {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!weakSelf.scrollView.isDragging && !weakSelf.scrollView.isDecelerating) {
            if (needNotify && weakSelf.onCropConfirm) {
                weakSelf.onCropConfirm(weakSelf.model);
            }
            
            [weakSelf.player enablePlayInRange:weakSelf.model.beginTime
                                 rangeDuration:weakSelf.model.duration];
            [weakSelf.player seek:weakSelf.model.beginTime];
            [weakSelf.player play];
        }
    });
}

- (void)didMoveToSuperview {
    if (self.superview) {
        [self onConfirmChange:NO];
    }
}

// MARK: - AUIVideoPlayObserver
- (void)playProgress:(double)progress {
    [UIView animateWithDuration:0.1 animations:^{
        [self updatePlayProgress];
    }];
}

- (void)playStatus:(BOOL)isPlaying {
    self.isPlaying = isPlaying;
}

- (void)updatePlayProgress {
    CGFloat percent = self.player.playRangeTime / self.player.playRangeDuration;
    percent = MAX(0.001, MIN(1.0, percent));
    self.playingPCMView.superview.av_width = self.playingPCMView.av_width * percent;
}

- (void)setIsPlaying:(BOOL)isPlaying {
    if (_isPlaying == isPlaying) {
        return;
    }
    _isPlaying = isPlaying;
    if (_isPlaying) {
        UIView *playingPCMContainter = [UIView new];
        playingPCMContainter.clipsToBounds = YES;
        playingPCMContainter.backgroundColor = UIColor.clearColor;
        [_pcmView addSubview:playingPCMContainter];
        
        if (_pcmView.pcmData.count > 0) {
            _playingPCMView = [[AUIMusicPCMLineView alloc] initWithPCMData:_pcmView.pcmData];
        }
        else {
            _playingPCMView = [[AUIMusicPCMLineView alloc] initWithFile:_model.localPath];
        }
        _playingPCMView.realShowPercentage = _pcmView.realShowPercentage;
        _playingPCMView.color = AUIFoundationColor(@"colourful_fill_strong");
        [playingPCMContainter addSubview:_playingPCMView];
        CGRect frame = [_selectedFrameView convertRect:_selectedFrameView.bounds toView:_pcmView];
        frame.size.width -= kSelectedFrameOffset;
        frame.origin.x += kSelectedFrameOffset;
        CGFloat width = _pcmView.bounds.size.width;
        _playingPCMView.normalizedBegin = CGRectGetMinX(frame) / width;
        _playingPCMView.normalizedEnd = CGRectGetMaxX(frame) / width;
        frame.size.height = _pcmView.av_height;
        frame.origin.y = 0;
        playingPCMContainter.frame = frame;
        frame.origin.x = 0;
        _playingPCMView.frame = frame;

        [self updatePlayProgress];
    }
    else {
        [_playingPCMView.superview removeFromSuperview];
        _playingPCMView = nil;
    }
}

// MARK: - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.player pause];
    [self updateTime];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self onConfirmChange:YES];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self onConfirmChange:YES];
}

@end
