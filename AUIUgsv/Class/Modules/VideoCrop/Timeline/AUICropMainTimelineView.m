//
//  AUICropMainTimelineView.m
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/6/4.
//

#import "AUICropMainTimelineView.h"
#import "AUIUgsvMacro.h"
#import <AUIUgsvCom/AUIUgsvCom.h>

@interface AUICropMainTimelineView () <AUITimelineViewDelegate, AUIVideoPlayObserver>

@property (nonatomic, strong) AUIAssetPlay *player;
@property (nonatomic, strong) AUITimelineView *mainTimeline;

@property (nonatomic, strong) AUITrackerClipData *clipData;

@property (nonatomic, assign) BOOL curTimeChangedByPlaying;
@property (nonatomic, assign) BOOL seekTimeChangedByScroll;
@property (nonatomic, assign) BOOL isPan;

@end

@implementation AUICropMainTimelineView

- (instancetype)initWithFrame:(CGRect)frame withAssetPlayer:(AUIAssetPlay *)player {
    self = [super initWithFrame:frame];
    if (self) {
        _player = player;
        [_player addObserver:self];
        
        self.backgroundColor = AUIFoundationColor(@"bg_weak");
        [self setupUI];
        [self setupMainTimelineData];
    }
    return self;
}

- (NSTimeInterval)clipStart {
    return self.clipData.clipStart;
}

- (NSTimeInterval)clipEnd {
    return self.clipData.clipEnd;
}

- (void)requestThumbnail:(NSTimeInterval)time completed:(void (^)(UIImage * _Nonnull))completed {
    [self.clipData.thumbRequest requestTimes:@[@(time)] duration:0 completed:^(NSTimeInterval time, UIImage * _Nonnull thumb) {
        if (completed) {
            completed(thumb);
        }
    }];
}

- (void)setupUI {
    [AUITimelineViewAppearance defaultAppearcnce].selectionViewLeftImage = AUIUgsvTimelineImage(@"ic_left");
    [AUITimelineViewAppearance defaultAppearcnce].selectionViewRightImage = AUIUgsvTimelineImage(@"ic_right");

    AUITimelineView *mainTimeline = [[AUITimelineView alloc] initWithFrame:self.bounds hiddentTimeIndicator:NO hiddenCurrentTimeIndicator:NO scrollInset:UIEdgeInsetsMake(0, 0, AVSafeBottom, 0)];
    mainTimeline.trackerMarginTop = (self.av_height - AVSafeBottom - 44) / 2.0 - 12.0;
    mainTimeline.delegate = self;
    [self addSubview:mainTimeline];
    self.mainTimeline = mainTimeline;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTimelineViewTap:)];
    [self.mainTimeline addGestureRecognizer:tapGesture];
}

- (void)setupMainTimelineData {
    AUITrackerData *trackerData = [[AUITrackerData alloc] initWithIndex:0 withThumbSize:CGSizeMake(44, 44)];
    [self.mainTimeline addTracker:trackerData];
    
    NSTimeInterval duration = [self.player duration];
    [self.player enablePlayInRange:0 rangeDuration:duration];
    
    AUITrackerClipData *videoTrackerClipData = [[AUITrackerClipData alloc] initWithAutoStart:YES withStart:0 withDruation:duration withClipStart:0 withClipEnd:duration];
    videoTrackerClipData.thumbRequest = [[AUITrackerThumbnailRequest alloc] initWithGenerator:[[AUIAsyncImageGeneratorVideo alloc] initWithAsset:self.player.playAsset]];
    [self.mainTimeline addClip:videoTrackerClipData atTracker:trackerData];
    self.clipData = videoTrackerClipData;
}

- (void)onTimelineViewTap:(UIGestureRecognizer *)gesture {
    [self.mainTimeline clearSelected];
}

- (void)timeline:(AUITimelineView *)timelineView currentTimeChanged:(NSTimeInterval)currentTime {
    if (self.isPan)
    {
        self.isPan = NO;
        return;
    }

    self.seekTimeChangedByScroll = YES;
    NSTimeInterval seekTime = currentTime + self.clipData.clipStart;
    if (seekTime > self.clipData.clipStart && seekTime < self.clipData.clipEnd) {
        [self.player seek:seekTime];
    }
}

- (void)timeline:(AUITimelineView *)timelineView onUpdatingClip:(AUITrackerClipData *)clip byEvent:(AUITimelineViewClipUpdatedEvent)event {
    self.isPan = YES;
    [self.player enablePlayInRange:self.clipData.clipStart rangeDuration:self.clipData.clipEnd - self.clipData.clipStart];

    self.seekTimeChangedByScroll = YES;
    if (event == AUITimelineViewClipUpdatedEventPanLeft) {
        [self.player seek:self.clipData.clipStart];
    }
    else if (event == AUITimelineViewClipUpdatedEventPanRight) {
        [self.player seek:self.clipData.clipEnd];
    }
}

- (void)timeline:(AUITimelineView *)timelineView didUpdatedClips:(NSArray<AUITrackerClipData *> *)clips atTracker:(AUITrackerData *)tracker byEvent:(AUITimelineViewClipUpdatedEvent)event {
    [self.player seek:self.mainTimeline.currentTime + self.clipData.clipStart];
}

- (void)playProgress:(double)progress {
    if (!self.seekTimeChangedByScroll) {
        [self.mainTimeline setCurrentTime:[self.player playRangeTime]];
    }
    self.seekTimeChangedByScroll = NO;
}

@end
