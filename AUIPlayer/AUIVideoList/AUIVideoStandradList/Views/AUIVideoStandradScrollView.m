//
//  AUIVideoStandradScrollView.m
//  AUIVideoList
//
//  Created by zzy on 2023/3/7.
//  Copyright © 2023年 com.alibaba. All rights reserved.
//

#import "AUIVideoStandradScrollView.h"
#import "UIImageView+WebCache.h"

#define kImageBaseTag 100

@interface AUIVideoStandradScrollView()<UIScrollViewDelegate>

@property (nonatomic,strong)UIScrollView *scrollView;
@property (nonatomic,strong)NSMutableArray *imageViewArray;
@property (nonatomic,strong)NSMutableArray *sources;
@property (nonatomic,assign)BOOL playerIsStop;
@property (nonatomic,assign)BOOL hasLoad;
@property (nonatomic,strong)NSTimer *randomlyScrollTimer;

@end

@implementation AUIVideoStandradScrollView

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        self.imageViewArray = [NSMutableArray array];
        self.sources = [NSMutableArray array];
        
        self.scrollView = [[UIScrollView alloc]initWithFrame:self.bounds];
        self.scrollView.delegate = self;
        self.scrollView.pagingEnabled = YES;
        [self addSubview:self.scrollView];
        if (@available(iOS 11.0, *)) {
            self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        if (@available(iOS 13.0, *)) {
            self.scrollView.automaticallyAdjustsScrollIndicatorInsets = NO;
        }
        
        self.playView = [[UIView alloc]initWithFrame:self.scrollView.bounds];
        [self.scrollView addSubview:self.playView];
        self.playView.hidden = YES;
        
        [self addTapGesture];
        
        // 添加检测app进入前台的观察者
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive) name: UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}

- (void)applicationDidBecomeActive {
    [self scrollViewDidEndDecelerating:self.scrollView];
}

- (void)addTapGesture {
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]init];
    tapGesture.numberOfTapsRequired = 1;
    [tapGesture addTarget:self action:@selector(tap)];
    [self addGestureRecognizer:tapGesture];
}

- (void)tap {
    if ([self.delegate respondsToSelector:@selector(tapGestureAction:)]) {
        [self.delegate tapGestureAction:self];
    }
}

- (void)setCurrentIndex:(NSInteger)currentIndex {
    _currentIndex = currentIndex;
    self.scrollView.contentOffset = CGPointMake(0, self.frame.size.height*currentIndex);
    [self resetPlayViewFrame];
}

- (void)resetPlayViewFrame {
    CGFloat maxOffsetY = self.scrollView.frame.size.height * (self.sources.count - 1);
    if (self.scrollView.contentOffset.y < 0) {
        self.playView.frame = CGRectMake(0, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
    }else if (self.scrollView.contentOffset.y > maxOffsetY ) {
        self.playView.frame = CGRectMake(0, maxOffsetY, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
    }else {
        self.playView.frame = CGRectMake(0, self.scrollView.contentOffset.y, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
    }
}

- (void)showPlayView {
    self.playView.hidden = NO;
}

- (UIScrollView *)getScrollView {
    return self.scrollView;
}

- (void)updateSources:(NSArray<AUIVideoInfo *> *)sources add:(BOOL)add {
    CGFloat selfWidth = self.frame.size.width;
    CGFloat selfHeight = self.frame.size.height;
    if (add) {
        [sources enumerateObjectsUsingBlock:^(AUIVideoInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSInteger index = self.sources.count + idx;
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, selfHeight*index, selfWidth, selfHeight)];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            [imageView sd_setImageWithURL:[NSURL URLWithString:obj.coverURL]];
            imageView.tag = index + kImageBaseTag;
            [self.scrollView addSubview:imageView];
            [self.imageViewArray addObject:imageView];
            [self.scrollView sendSubviewToBack:imageView];
        }];
        [self.sources addObjectsFromArray:sources];
    } else {
        if (sources.count > self.sources.count) {
            [sources enumerateObjectsUsingBlock:^(AUIVideoInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (idx < self.sources.count) {
                    UIImageView *imageView = [self.scrollView viewWithTag:idx + kImageBaseTag];
                    [imageView sd_setImageWithURL:[NSURL URLWithString:obj.coverURL]];
                } else {
                    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, selfHeight*idx, selfWidth, selfHeight)];
                    imageView.contentMode = UIViewContentModeScaleAspectFit;
                    [imageView sd_setImageWithURL:[NSURL URLWithString:obj.coverURL]];
                    imageView.tag = idx + kImageBaseTag;
                    [self.scrollView addSubview:imageView];
                    [self.imageViewArray addObject:imageView];
                    [self.scrollView sendSubviewToBack:imageView];
                }
            }];
        } else {
            [sources enumerateObjectsUsingBlock:^(AUIVideoInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                UIImageView *imageView = [self.scrollView viewWithTag:idx + kImageBaseTag];
                [imageView sd_setImageWithURL:[NSURL URLWithString:obj.coverURL]];
            }];
            [[self.sources subarrayWithRange:NSMakeRange(sources.count, self.sources.count - sources.count)] enumerateObjectsUsingBlock:^(AUIVideoInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                UIImageView *imageView = [self.scrollView viewWithTag:idx + kImageBaseTag];
                [imageView removeFromSuperview];
                [self.imageViewArray removeObject:imageView];
            }];
        }
        self.sources = sources.mutableCopy;
    }
    
    self.scrollView.contentSize = CGSizeMake(selfWidth, self.sources.count * selfHeight);
}

- (UIImageView *)findImageViewFromIndex:(NSInteger)index {
    for (UIImageView *imageView in self.imageViewArray) {
        if (imageView.tag == index) {
            return imageView;
        }
    }
    return nil;
}

- (void)moveScrollAtIndex:(NSInteger)index duration:(float)duration {
    if (self.sources.count <= index) {
        return;
    }
    
    if (duration == 0.00) {
        [self.scrollView setContentOffset:CGPointMake(0, self.frame.size.height*index) animated:YES];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.scrollView setContentOffset:CGPointMake(0, self.frame.size.height*index) animated:YES];
        });
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self scrollViewDidEndDecelerating:self.scrollView];
    });
}

#pragma mark -- UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if ([self.delegate respondsToSelector:@selector(scrollViewWillBeginDragging:)]) {
        [self.delegate scrollViewWillBeginDragging:self];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat indexFloat = scrollView.contentOffset.y/self.frame.size.height;
    NSInteger index = (NSInteger)indexFloat;
    if (index < 0 || index > self.sources.count - 1) {
        return;
    }
    if (index != self.currentIndex || self.playerIsStop) {
        self.playView.hidden = YES;
        self.playerIsStop = NO;
        [self resetPlayViewFrame];
        if (index - self.currentIndex == 1) {
            if ([self.delegate respondsToSelector:@selector(scrollView:motoNextAtIndex:)]) {
                [self.delegate scrollView:self motoNextAtIndex:index];
            }
        }else if (self.currentIndex - index == 1){
            if ([self.delegate respondsToSelector:@selector(scrollView:motoPreAtIndex:)]) {
                [self.delegate scrollView:self motoPreAtIndex:index];
            }
        }else {
            if ([self.delegate respondsToSelector:@selector(scrollView:didEndDeceleratingAtIndex:)]) {
                [self.delegate scrollView:self didEndDeceleratingAtIndex:index];
            }
        }
        
        _currentIndex = index;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (!self.hasLoad) {
        self.hasLoad = YES;
        return;
    }
    if (ABS(scrollView.contentOffset.y - self.playView.frame.origin.y)>self.frame.size.height) {
        if (self.playerIsStop == NO) {
            self.playerIsStop = YES;
            if ([self.delegate respondsToSelector:@selector(scrollViewScrollOut:)]) {
                [self.delegate scrollViewScrollOut:self];
            }
        }
    }
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView; {
    return NO;
}

@end








