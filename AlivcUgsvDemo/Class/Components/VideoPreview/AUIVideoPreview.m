//
//  AUIVideoPreview.m
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/6/2.
//

#import "AUIVideoPreview.h"
#import "AUIUgsvMacro.h"
#import "AUIVideoPlayProgressView.h"

@interface AUIVideoPreview () <AUIVideoPlayObserver>

@property (nonatomic, assign) BOOL isFullScreenMode;

@property (nonatomic, weak) UIView *backupSuperView;;
@property (nonatomic, assign) NSUInteger backupIndexInSuperView;
@property (nonatomic, assign) CGRect backupFrame;

@property (nonatomic, strong) UIView *displayView;

@property (nonatomic, strong) UIView *fullScreenView;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) AUIVideoPlayProgressView *bottomView;

@end

@implementation AUIVideoPreview

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame withDisplayResolution:CGSizeZero];
}

- (instancetype)initWithFrame:(CGRect)frame withDisplayResolution:(CGSize)displayResolution {
    self = [super initWithFrame:frame];
    if (self) {
        _isFullScreenMode = NO;
        _displayResolution = displayResolution;

        _displayView = [[UIView alloc] initWithFrame:CGRectZero];
        _displayView.backgroundColor = UIColor.blackColor;
        _displayView.clipsToBounds = YES;
        [self addSubview:_displayView];
        
        self.backgroundColor = AUIFoundationColor(@"bg_medium");
        [self updateDisplayViewLayout];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self updateDisplayViewLayout];
    [self.player updateLayoutForDisplayView];
}

- (void)setDisplayResolution:(CGSize)displayResolution {
    if (!CGSizeEqualToSize(_displayResolution, displayResolution)) {
        _displayResolution = displayResolution;
        [self setNeedsLayout];
    }
}

- (void)updateDisplayViewLayout {
    CGFloat top = 0;
    CGFloat bot = 0;
    CGFloat w = self.av_width;
    CGFloat h = self.av_height;
    if (self.isFullScreenMode) {
        top = AVSafeTop;
        bot = AVSafeBottom;
        h = self.av_height - AVSafeTop - AVSafeBottom;
    }
    CGRect rect = CGRectMake(0, top, w, h);
    if (!CGSizeEqualToSize(self.displayResolution, CGSizeZero)) {
        CGSize aspectSize = [UIView av_aspectSizeWithOriginalSize:CGSizeMake(w, h) withResolution:self.displayResolution];
        w = aspectSize.width;
        h = aspectSize.height;
    }
    self.displayView.frame = CGRectMake(CGRectGetMidX(rect) - w / 2.0, CGRectGetMidY(rect) - h / 2.0, w, h);
    if (self.onDisplayViewLayoutChanged) {
        self.onDisplayViewLayoutChanged();
    }
}

- (void)enterFullScreen:(UIView *)fullScreenView {
    self.backupSuperView = self.superview;
    __block NSUInteger index = 0;
    [[self.backupSuperView subviews] enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj == self) {
            index = idx;
            *stop = YES;
        }
    }];
    self.backupIndexInSuperView = index;
    self.backupFrame = self.frame;
    
    self.isFullScreenMode = YES;
    [self removeFromSuperview];
    self.frame = fullScreenView.bounds;
    [fullScreenView addSubview:self];
    [self onFullScreen];
}

- (void)onFullScreen {
    self.fullScreenView = [[UIView alloc] initWithFrame:self.bounds];
    [self.fullScreenView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onFullScreenViewTap:)]];
    [self addSubview:self.fullScreenView];
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(20, (44 - 26) / 2.0 + AVSafeTop, 26, 26)];
    backButton.titleLabel.font = AVGetRegularFont(12.0);
    [backButton setTitleColor:AUIFoundationColor(@"text_strong") forState:UIControlStateNormal];
    [backButton setImage:AUIFoundationImage(@"ic_back") forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(onBackBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.fullScreenView addSubview:backButton];
    self.backButton = backButton;
    
    __weak typeof(self) weakSelf = self;
    self.bottomView = [[AUIVideoPlayProgressView alloc] initWithFrame:CGRectMake(0, self.fullScreenView.av_height - AVSafeBottom - 42 - 2, self.fullScreenView.av_width, 42)];
    self.bottomView.fullScreenBtn.selected = YES;
    self.bottomView.backgroundColor = UIColor.clearColor;
    self.bottomView.onFullScreenBtnClicked = ^(BOOL fullScreen){
        [weakSelf exsitFullScreen];
    };
    self.bottomView.player = self.player;
    [self.fullScreenView addSubview:self.bottomView];
}

- (void)exsitFullScreen {
    if (self.backupSuperView) {
        self.isFullScreenMode = NO;
        [self removeFromSuperview];
        self.frame = self.backupFrame;
        [self.backupSuperView insertSubview:self atIndex:self.backupIndexInSuperView];
        
        self.backupSuperView = nil;
        self.backupIndexInSuperView = 0;
        self.backupFrame = CGRectZero;
        
        [self onUnFullScreen];
    }
}

- (void)onUnFullScreen {
    [self.backButton removeFromSuperview];
    self.backButton = nil;
    self.bottomView.player = nil;
    [self.bottomView removeFromSuperview];
    self.bottomView = nil;
    [self.fullScreenView removeFromSuperview];
    self.fullScreenView = nil;
}

- (void)onFullScreenViewTap:(UITapGestureRecognizer *)recognizer {
    self.backButton.hidden = !self.backButton.hidden;
    self.bottomView.hidden = !self.bottomView.hidden;
}

- (void)onBackBtnClicked:(UIButton *)sender {
    [self exsitFullScreen];
}

- (void)setIsFullScreenMode:(BOOL)isFullScreenMode
{
    if (_isFullScreenMode != isFullScreenMode) {
        _isFullScreenMode = isFullScreenMode;
        if (self.onFullScreenModeChanged) {
            self.onFullScreenModeChanged(isFullScreenMode);
        }
    }
}


- (void)setPlayer:(id<AUIVideoPlayProtocol>)player {
    if (player != _player) {
        [_player setDisplayView:nil];
        [_player removeObserver:self];
        _player = nil;
    }
    if (player) {
        _player = player;
        [_player setDisplayView:self.displayView];
        [_player addObserver:self];
    }
}

#pragma AlivcPlayManagerObserver

- (void)playError:(NSInteger)errorCode {
    NSLog(@"playError:%zd", errorCode);
}

@end
