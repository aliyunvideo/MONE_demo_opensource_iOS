//
//  AUIEditorMultiTimelineEditBar.m
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/6/17.
//

#import "AUIEditorMultiTimelineEditBar.h"

@interface AUIEditorMultiTimelineEditBar ()

@property (nonatomic, strong) AUITimelineView *subTimeline;
@property (nonatomic, strong) UIView *currentTimeIndicator;

@property (nonatomic, assign) NSUInteger subTimelineTrackerIndex;

@property (nonatomic, strong) UIButton *removeBtn;



@end

@implementation AUIEditorMultiTimelineEditBar

- (CGFloat)mainTrackerTopMargin {
    if (self.subTimeline != nil) {
        return 10.0;
    }
    return [super mainTrackerTopMargin];
}

- (BOOL)enableSelectClipData {
    return NO;
}

- (BOOL)hiddentTimeIndicator {
    return YES;
}

- (BOOL)hiddenCurrentTimeIndicator {
    return YES;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupMenuItem];
        self.subTimelineTrackerIndex = 0;
        
        UIView *currentTimeIndicator = [[UIView alloc] initWithFrame:CGRectMake((self.contentView.av_width - 1) / 2.0, 6, 1, self.contentView.av_height - 6 - 6)];
        currentTimeIndicator.backgroundColor = AUIFoundationColor(@"fill_infrared");
        [self.contentView addSubview:currentTimeIndicator];
        self.currentTimeIndicator = currentTimeIndicator;
    }
    return self;
}

- (void)refreshPlayTime {
    [super refreshPlayTime];
    self.subTimeline.currentTime = self.mainTimeline.currentTime;
}

- (void)reloadMainTimeline {
    [super reloadMainTimeline];
    [self.contentView bringSubviewToFront:self.currentTimeIndicator];
}

#pragma mark - subTimeline

- (void)setupSubTimeline {
    [AUITimelineViewAppearance defaultAppearcnce].selectionViewLeftImage = AUIUgsvTimelineImage(@"ic_left");
    [AUITimelineViewAppearance defaultAppearcnce].selectionViewRightImage = AUIUgsvTimelineImage(@"ic_right");
    
    AUITimelineView *subTimeline = [[AUITimelineView alloc] initWithFrame:CGRectMake(0, 54, self.contentView.av_width, self.contentView.av_height - 54 - 6) hiddentTimeIndicator:YES hiddenCurrentTimeIndicator:YES scrollInset:UIEdgeInsetsZero];
    self.subTimeline = subTimeline;

    [self reloadMainTimeline];
    [self.mainTimeline addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTimelineViewTap:)]];

    self.subTimeline.trackerMarginTop = 6;
    self.subTimeline.trackerMarginSpace = 4;
    self.subTimeline.trackerMarginBottom = 6;
    self.subTimeline.delegate = self;
    [self.contentView insertSubview:self.subTimeline aboveSubview:self.mainTimeline];
    [self.subTimeline addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTimelineViewTap:)]];
    self.subTimeline.minDuration = self.mainTimeline.actualDuration;
    self.subTimeline.maxDuration = self.mainTimeline.actualDuration;
    self.subTimeline.currentTime = self.mainTimeline.currentTime;
}

- (void)releaseSubTimeline {
    if (self.subTimeline) {
        [self.subTimeline removeFromSuperview];
        self.subTimeline = nil;
    }
    [self reloadMainTimeline];
}

- (void)addSubTrackerClip:(AUITrackerClipData *)clip {
    if (!self.subTimeline) {
        [self setupSubTimeline];
    }
    AUITrackerData *tracker = [[AUITrackerData alloc] initWithIndex:[self newSubTimelineTrackerIndex] withThumbSize:CGSizeMake(24, 24)];
    [self.subTimeline addTracker:tracker];
    if (clip) {
        [self.subTimeline addClip:clip atTracker:tracker];
    }
}

- (void)removeSubTrackerClip:(AUITrackerClipData *)clip {
    BOOL ret = [self.subTimeline removeTracker:clip.trackerData];
    if (ret && self.subTimeline.allTrackers.count == 0) {
        [self releaseSubTimeline];
    }
}

- (AUITrackerClipData *)clipWithTimelineIn:(NSTimeInterval)timelineIn timelineOut:(NSTimeInterval)timelineOut clipIn:(NSTimeInterval)clipIn clipOut:(NSTimeInterval)clipOut speed:(CGFloat)speed titleView:(AUIEditorTimelineTitleView *)titleView {
    AUITrackerClipData *clip = [[AUITrackerClipData alloc] initWithAutoStart:NO withStart:timelineIn withDruation:timelineOut - timelineIn withClipStart:clipIn withClipEnd:clipOut withTrans:nil withSpeed:speed];
    clip.thumbBgColor = AUIFoundationColor(@"colourful_fill_strong");
    clip.titleViewLoader = [[AUIEditorTimelineTitleLoader alloc] initWithTitleView:titleView];
    return clip;
}

- (AUITrackerClipData *)clipWithTimelineIn:(NSTimeInterval)timelineIn clipDuration:(NSTimeInterval)clipDuration speed:(CGFloat)speed titleView:(AUIEditorTimelineTitleView *)titleView {
    NSTimeInterval max = 2 * 60 * 60; // 最长2小时（For 2 hours）
    NSTimeInterval clipIn = (max * 2 - clipDuration) / 2.0;
    NSTimeInterval clipOut = clipIn + clipDuration;
    AUITrackerClipData *clip = [[AUITrackerClipData alloc] initWithAutoStart:NO withStart:timelineIn withDruation:max * 2 withClipStart:clipIn withClipEnd:clipOut withTrans:nil withSpeed:speed];
    clip.thumbBgColor = AUIFoundationColor(@"colourful_fill_strong");
    clip.titleViewLoader = [[AUIEditorTimelineTitleLoader alloc] initWithTitleView:titleView];
    return clip;
}

- (NSUInteger)newSubTimelineTrackerIndex {
    NSUInteger index = self.subTimelineTrackerIndex;
    self.subTimelineTrackerIndex++;
    return index;
}

#pragma mark - subtimeline events

- (void)onTimelineViewTap:(UIGestureRecognizer *)gesture {
    if (self.subTimeline.currentSelectedClip) {
        [self.subTimeline clearSelected];
        self.removeBtn.enabled = NO;
        [self.selectionManager unselect];
    }
    
}

- (void)timeline:(AUITimelineView *)timelineView currentTimeChanged:(NSTimeInterval)currentTime {
    if (timelineView == self.mainTimeline) {
        [self.subTimeline setCurrentTime:currentTime];
        [super timeline:timelineView currentTimeChanged:currentTime];
        return;
    }
    
    if (timelineView == self.subTimeline) {
        [self.mainTimeline setCurrentTime:currentTime];
        [self timeline:self.mainTimeline currentTimeChanged:currentTime];
    }
}

-  (void)timeline:(AUITimelineView *)timelineView didSelectedClip:(AUITrackerClipData *)clip {
    if (timelineView == self.subTimeline) {
        if (clip.aepCaptionTrackObj || clip.aepStickerTrackObj) {
            [self.selectionManager select:clip.getAepObject];
        }
        self.removeBtn.enabled = YES;
    }
}

- (void)playProgress:(double)progress {
    [super playProgress:progress];

    if (self.player.isPlaying) {
        [self.subTimeline setCurrentTime:[self.player playRangeTime]];
    }
}


#pragma mark - menu

- (void)setupMenuItem {
    UIButton *addBtn = [self.class createAddButton:[self addBtnTitle]];
    addBtn.center = CGPointMake(20 + addBtn.av_width / 2.0, self.menuView.av_height / 2.0);
    [addBtn addTarget:self action:@selector(onAddClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.menuView addSubview:addBtn];
    
    UIButton *removeBtn = [self.class createRemoveButton];
    removeBtn.av_left = self.menuView.av_width - removeBtn.av_width - 27;
    removeBtn.av_top = (self.menuView.av_height - removeBtn.av_height) / 2.0;
    [removeBtn addTarget:self action:@selector(onRemoveClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.menuView addSubview:removeBtn];
    self.removeBtn = removeBtn;
    self.removeBtn.enabled = NO;
}

- (NSString *)addBtnTitle {
    return @"";
}

- (void)tryToAddClip:(NSTimeInterval)start {
    
}

- (void)tryToRemoveClip:(AUITrackerClipData *)clip {

}

- (void)onAddClicked:(UIButton *)sender {
    [self.player pause];
    
    NSTimeInterval start = self.mainTimeline.currentTime;
    [self tryToAddClip:start];
}

- (void)onRemoveClicked:(UIButton *)sender {
    if (!self.subTimeline.currentSelectedClip) {
        return;
    }
    [self.player pause];
    [AVAlertController showWithTitle:AUIUgsvGetString(@"提示") message:AUIUgsvGetString(@"确认删除？") needCancel:YES onCompleted:^(BOOL isCanced) {
            if (!isCanced) {
                AUITrackerClipData *clip = self.subTimeline.currentSelectedClip;
                [self tryToRemoveClip:clip];
            }
    }];
}

@end
