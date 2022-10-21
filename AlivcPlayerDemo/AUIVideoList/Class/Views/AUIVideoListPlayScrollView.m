//
//  AUIVideoListPlayScrollView.m
//  AliPlayerDemo
//
//  Created by zzy on 2022/3/22.
//  Copyright © 2022 com.alibaba. All rights reserved.
//

#import "AUIVideoListPlayScrollView.h"
#import "AUIVideoListProgressView.h"
#import <SDWebImage/SDWebImage.h>
#import "AUIVideoListManager.h"

#pragma mark -- AUIVideoListPlayHandView
@interface AUIVideoListPlayHandView : UIView

@property (nonatomic,strong) UIImageView *handUpImageView;
@property (nonatomic,strong) UILabel *tip;

@end

@implementation AUIVideoListPlayHandView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:_handUpImageView];
        UIImage *handUpImage = AUIVideoListImage(@"ic_hand");
        self.handUpImageView.frame = CGRectMake(0, 0, handUpImage.size.width, handUpImage.size.height);
        self.handUpImageView.image = handUpImage;
        [self addSubview:self.handUpImageView];
        self.tip.frame = CGRectMake(0, self.handUpImageView.av_bottom + 23, self.av_width, 24);
        self.tip.text = AUIVideoListString(@"上滑查看更多视频");
        [self addSubview:_tip];
        self.handUpImageView.av_centerX = self.tip.av_centerX;
    }
    return self;
}

- (UIImageView *)handUpImageView {
    if (!_handUpImageView) {
        UIImage *handUpImage = AUIVideoListImage(@"ic_hand");
        _handUpImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, handUpImage.size.width, handUpImage.size.height)];
        _handUpImageView.accessibilityIdentifier = AUIVideoListAccessibilityStr(@"handUpImageView");
        _handUpImageView.image = handUpImage;
    }
    return _handUpImageView;
}

- (UILabel *)tip {
    if (!_tip) {
        _tip = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.av_width, 24)];
        _tip.accessibilityIdentifier = AUIVideoListAccessibilityStr(@"tipLabel");
        _tip.textColor = AUIVideoListColor(@"vl_tiptext");
        _tip.font = AVGetMediumFont(16);
    }
    return _tip;
}


@end

#pragma mark -- AUIVideoListPlayScrollView
@interface AUIVideoListPlayScrollView()<UIScrollViewDelegate>

@property (nonatomic,strong)UIScrollView *scrollView;
@property (nonatomic,strong)UILabel *userLabel;
@property (nonatomic,strong)UILabel *titleLabel;
@property (nonatomic,strong)AUIVideoListProgressView *progressView;
@property (nonatomic,strong)AUIVideoListPlayHandView *handUpView;
@property (nonatomic,strong)UIImageView *playImageView;
@property (nonatomic,strong)NSMutableArray *imageViewArray;
@property (nonatomic,strong)NSMutableArray<AUIVideoListModel *> *dataArray;
@property (nonatomic,assign)BOOL playerIsStop;
@property (nonatomic,assign)BOOL hasLoad;
@property (nonatomic,strong)NSTimer *randomlyScrollTimer;

@end

@implementation AUIVideoListPlayScrollView

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame dataArray:(NSArray <AUIVideoListModel *>*)array {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.imageViewArray = [NSMutableArray array];
        self.dataArray = [NSMutableArray array];
        
        self.scrollView = [[UIScrollView alloc]initWithFrame:self.bounds];
        self.scrollView.accessibilityIdentifier = AUIVideoListAccessibilityStr(@"scrollView");
        self.scrollView.delegate = self;
        self.scrollView.pagingEnabled = YES;
        [self addSubview:self.scrollView];
        if (@available(iOS 11.0, *)) {
            self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        
        self.playView = [[UIView alloc]initWithFrame:self.scrollView.bounds];
        self.playView.accessibilityIdentifier = AUIVideoListAccessibilityStr(@"playView");
        [self.scrollView addSubview:self.playView];
        self.playView.hidden = YES;
        
        self.progressView = [[AUIVideoListProgressView alloc] initWithFrame:CGRectMake(0, self.av_height - 81, self.av_width, 3)];
        self.progressView.accessibilityIdentifier = AUIVideoListAccessibilityStr(@"progressView");
        [self addSubview:self.progressView];
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, self.progressView.av_top - 26 - 40, self.av_width - 20 - 75, 40)];
        self.titleLabel.accessibilityIdentifier = AUIVideoListAccessibilityStr(@"titleLabel");
        self.titleLabel.textColor = AUIVideoListColor(@"vl_subtext");
        self.titleLabel.font = AVGetRegularFont(14);
        self.titleLabel.numberOfLines = 2;
        [self addSubview:self.titleLabel];
        
        self.userLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, self.titleLabel.av_top - 2 - 22, self.av_width - 20 - 75, 22)];
        self.userLabel.accessibilityIdentifier = AUIVideoListAccessibilityStr(@"userLabel");
        self.userLabel.textColor = AUIVideoListColor(@"vl_slider_bg");
        self.userLabel.font = AVGetMediumFont(16);
        [self addSubview:self.userLabel];
        
        UIImage *handUpImage = AUIVideoListImage(@"ic_hand");
        self.handUpView = [[AUIVideoListPlayHandView alloc] initWithFrame:CGRectMake(0, 0, handUpImage.size.width + 80, handUpImage.size.height + 23 + 24)];
        self.handUpView.accessibilityIdentifier = AUIVideoListAccessibilityStr(@"handUpView");
        self.handUpView.center = self.center;
        if (![AUIVideoListManager manager].isHideHandUp) {
            [self addSubview:self.handUpView];
            __weak typeof(self) weakSelf = self;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                __strong typeof(self) strongSelf = weakSelf;
                [strongSelf hideHandTip];
            });
            [[AUIVideoListManager manager] hideHandUp];
        }
        
        UIImage *playImage = AUIVideoListImage(@"player_play");
        self.playImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, playImage.size.width, playImage.size.height)];
        self.playImageView.accessibilityIdentifier = AUIVideoListAccessibilityStr(@"playImageView");
        self.playImageView.image = playImage;
        self.playImageView.center = self.center;
        [self addSubview:self.playImageView];
        self.showPlayImage = NO;
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]init];
        tapGesture.numberOfTapsRequired = 1;
        [tapGesture addTarget:self action:@selector(tap)];
        [self addGestureRecognizer:tapGesture];
    
        [self addDataArray:array];
        
        self.lastIndex = -1;
        
        [self updateDesc];
        
        // 添加检测app进入前台的观察者
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive) name: UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}

- (void)applicationDidBecomeActive {
    [self scrollViewDidEndDecelerating:self.scrollView];
}

- (void)tap {
    [self hideHandTip];
    if ([self.delegate respondsToSelector:@selector(AUIVideoListPlayScrollViewTapGestureAction:)]) {
        [self.delegate AUIVideoListPlayScrollViewTapGestureAction:self];
    }
}

- (void)hideHandTip {
    if (self.handUpView) {
        [self.handUpView removeFromSuperview];
        _handUpView = nil;
    }
}

- (void)setShowPlayImage:(BOOL)showPlayImage {
    _showPlayImage = showPlayImage;
    self.playImageView.hidden = !showPlayImage;
}

- (void)setCurrentIndex:(NSInteger)currentIndex {
    _currentIndex = currentIndex;
    self.scrollView.contentOffset = CGPointMake(0, self.frame.size.height*currentIndex);
    [self resetPlayViewFrame];
}

- (void)resetPlayViewFrame {
    AUIVideoListModel *lastModel = self.dataArray.lastObject;
    CGFloat maxOffsetY = self.scrollView.frame.size.height * lastModel.index;
    CGRect playViewFrame = self.playView.frame;
    if (self.scrollView.contentOffset.y < 0) {
        playViewFrame.origin.y = CGRectGetMidY(self.scrollView.frame);
    }else if (self.scrollView.contentOffset.y > maxOffsetY ) {
        playViewFrame.origin.y = maxOffsetY;
    }else {
        playViewFrame.origin.y = self.scrollView.contentOffset.y;
    }
    
    self.playView.frame = playViewFrame;
}

- (void)showPlayView {
    self.playView.hidden = NO;
}

- (void)addDataArray:(NSArray <AUIVideoListModel *>*)array {
    AUIVideoListModel *lastModel = self.dataArray.lastObject;
    int lastIndex = -1;
    if (lastModel) { lastIndex = (int)lastModel.index; }
    AUIVideoListModel *firstMode = array.firstObject;
    if (firstMode.index > lastIndex) {
        [self.dataArray addObjectsFromArray:array];
        CGFloat selfWidth = self.frame.size.width;
        CGFloat selfHeight = self.frame.size.height;
        self.scrollView.contentSize = CGSizeMake(selfWidth, self.scrollView.contentSize.height+selfHeight *array.count);
        
        // 加载封面
        for (AUIVideoListModel *model in array) {
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, CGRectGetHeight(self.scrollView.bounds)*model.index, CGRectGetWidth(self.scrollView.bounds), CGRectGetHeight(self.scrollView.bounds))];
            NSString *imageAccessibilityId = [NSString stringWithFormat:@"coverImageView:%ld", model.index];
            imageView.accessibilityIdentifier = AUIVideoListAccessibilityStr(imageAccessibilityId);
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            [imageView sd_setImageWithURL:[NSURL URLWithString:model.coverURL]];
            imageView.tag = model.index + 100;
            [self.scrollView addSubview:imageView];
            [self.imageViewArray addObject:imageView];
            [self.scrollView sendSubviewToBack:imageView];
        }
        
    }
}

- (void)updateProgress:(int64_t)position duration:(int64_t)duration {
    [self.progressView updateSliderValue:position duration:duration];
    [self.progressView updateCacheProgressValue:position duration:duration];
}

- (void)updateDesc {
    self.userLabel.text = [@"@" stringByAppendingString:self.dataArray[_currentIndex].user];
    self.titleLabel.text = self.dataArray[_currentIndex].title;
}

#pragma mark UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat indexFloat = scrollView.contentOffset.y/self.frame.size.height;
    NSInteger index = (NSInteger)indexFloat;
    AUIVideoListModel *firstModel = self.dataArray.firstObject;
    AUIVideoListModel *lastModel = self.dataArray.lastObject;
    if (index < firstModel.index || index > lastModel.index) {
        return;
    }
    if (index != self.currentIndex || self.playerIsStop) {
        self.playView.hidden = YES;
        self.playerIsStop = NO;
        [self resetPlayViewFrame];
        if (index - self.currentIndex == 1) {
            if ([self.delegate respondsToSelector:@selector(AUIVideoListPlayScrollView:motoNextAtIndex:)]) {
                [self.delegate AUIVideoListPlayScrollView:self motoNextAtIndex:index];
            }
        }else if (self.currentIndex - index == 1){
            if ([self.delegate respondsToSelector:@selector(AUIVideoListPlayScrollView:motoPreAtIndex:)]) {
                [self.delegate AUIVideoListPlayScrollView:self motoPreAtIndex:index];
            }
        }else {
            BOOL isMotoNext = NO;
            if (index - self.currentIndex > 1) {
                isMotoNext = YES;
            }
            if ([self.delegate respondsToSelector:@selector(AUIVideoListPlayScrollView:scrollViewDidEndDeceleratingAtIndex:motoNext:)]) {
                [self.delegate AUIVideoListPlayScrollView:self scrollViewDidEndDeceleratingAtIndex:index motoNext:isMotoNext];
            }
        }
        
        _lastIndex = _currentIndex;
        _currentIndex = index;
        
        [self updateDesc];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self hideHandTip];
    
    AUIVideoListModel *lastModel = self.dataArray.lastObject;
    if ((scrollView.contentOffset.y/self.frame.size.height > lastModel.index) && ![AUIVideoListManager manager].isHideBottomMoreTip) {
        [AVToastView show:AUIVideoListString(@"敬请期待～") view:self position:AVToastViewPositionMid];
        [[AUIVideoListManager manager] hideBottomMoreTip];
    }
    
    self.showPlayImage = NO;
    if (!self.hasLoad) {
        self.hasLoad = YES;
        return;
    }
    
    if (ABS(scrollView.contentOffset.y - self.playView.frame.origin.y) > self.frame.size.height) {
        if (self.playerIsStop == NO) {
            self.playerIsStop = YES;
            if ([self.delegate respondsToSelector:@selector(AUIVideoListPlayScrollViewScrollOut:)]) {
                [self.delegate AUIVideoListPlayScrollViewScrollOut:self];
            }
        }
    }
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView {
    return NO;
}

@end
