//
//  AUIEditorTimelineEditBar.m
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/6/17.
//

#import "AUIEditorTimelineEditBar.h"
#import "AUITransitionControllPanel.h"

@interface AUIEditorTimelineEditBar ()

@property (nonatomic, strong) AUITimelineView *mainTimeline;
@property (nonatomic, strong) AUIEditorTrackerHeaderView *mainHeader;

@end

@implementation AUIEditorTimelineEditBar

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupMainTimeline];
    }
    return self;
}

- (CGFloat)mainTrackerTopMargin {
    CGFloat timeIndicatorHight = [self hiddentTimeIndicator] ? 0 : 12.0;
    return (self.contentView.av_height - timeIndicatorHight - 44) / 2.0 + timeIndicatorHight;
}

- (BOOL)enableSelectClipData {
    return YES;
}

- (BOOL)hiddentTimeIndicator {
    return NO;
}

- (BOOL)hiddenCurrentTimeIndicator {
    return NO;
}

- (BOOL)hiddenMainTrakcerHeader {
    return YES;
}

- (void)setupMainTimeline {
    [AUITimelineViewAppearance defaultAppearcnce].selectionViewLeftImage = AUIUgsvTimelineImage(@"ic_left");
    [AUITimelineViewAppearance defaultAppearcnce].selectionViewRightImage = AUIUgsvTimelineImage(@"ic_right");
    
    AUITimelineView *mainTimeline = [[AUITimelineView alloc] initWithFrame:self.contentView.bounds hiddentTimeIndicator:[self hiddentTimeIndicator] hiddenCurrentTimeIndicator:[self hiddenCurrentTimeIndicator] scrollInset:UIEdgeInsetsZero];
    mainTimeline.trackerMarginTop = [self mainTrackerTopMargin];
    mainTimeline.delegate = self;
    mainTimeline.disbaleSelectClipByTap = YES;
    mainTimeline.disbaleClipLongPress = YES;
    [self.contentView addSubview:mainTimeline];
    self.mainTimeline = mainTimeline;
}

- (void)barWillAppear {
    [super barWillAppear];
    
    [self loadMainTimelineData];
    [self refreshPlayTime];
}

- (void)refreshPlayTime {
    [super refreshPlayTime];
    
    [self.mainTimeline setCurrentTime:[self.player playRangeTime]];
    [self tryToSelectClip:self.player.currentTime];
}

- (AUIEditorPlay *)player {
    return self.actionManager.currentOperator.currentPlayer;
}

- (AliyunEditor *)editor {
    return self.actionManager.currentOperator.currentEditor;
}

- (void)loadMainTimelineData {
    AUITrackerData *trackerData = [[AUITrackerData alloc] initWithIndex:AUIEditorMainTimelineIndex withThumbSize:CGSizeMake(44, 44)];
    
    if (![self hiddenMainTrakcerHeader]) {
        AUIEditorTrackerHeaderView *mainHeader = [AUIEditorTrackerHeaderView main];
        mainHeader.actionManager = self.actionManager;
        self.mainHeader = mainHeader;
        trackerData.headerViewLoader = [[AUIEditorTrackerHeaderViewLoader alloc] initWithHeaderView:self.mainHeader];
    }
    [self.mainTimeline addTracker:trackerData];
    
    AliyunEditorProject *project = [self.editor getEditorProject];
    CGFloat speed = [AUIAepHelper timeSpeed:self.editor];
    [project.timeline.mainVideoTrack.clipList enumerateObjectsUsingBlock:^(AEPVideoTrackClip * _Nonnull videoClip, NSUInteger idx, BOOL * _Nonnull stop) {
        
        AUITrackerClipTransitionData *transData = nil;
        if (idx > 0) {
            transData = [AUITransitionControllPanel transDataApplying:videoClip.transitionEffect speed:speed];
        }
        
        AUITrackerClipData *videoTrackerClipData = [[AUITrackerClipData alloc] initWithAutoStart:YES withStart:0 withDruation:videoClip.clipDuration withClipStart:videoClip.clipIn withClipEnd:videoClip.clipOut withTrans:transData withSpeed:speed];
        videoTrackerClipData.enablePanLeftRight = NO;
        videoTrackerClipData.enableSelected = [self enableSelectClipData];
        
        if (videoClip.type == AliyunClipImage) {
            videoTrackerClipData.thumbRequest = [self.thumbnailCache photoThumbnail:videoClip.source.path];
        }
        else {
            videoTrackerClipData.thumbRequest = [self.thumbnailCache videoThumbnail:videoClip.source.path];
        }
        
        videoTrackerClipData.titleViewLoader = [[AUIEditorTimelineTitleLoader alloc] initWithTitleView:[AUIEditorTimelineTitleView videoDurationView:videoClip.duration / speed]];
        [videoTrackerClipData setAepObject:videoClip];
        [self.mainTimeline addClip:videoTrackerClipData atTracker:trackerData];
    }];
}

- (void)reloadMainTimeline {
    [self.mainTimeline removeFromSuperview];
    [self setupMainTimeline];
    [self loadMainTimelineData];
    if (self.isAppear) {
        [self refreshPlayTime];
    }
}

- (void)tryToSelectClip:(NSTimeInterval)playTime {
    if (![self enableSelectClipData]) {
        return;
    }
    
    AEPVideoTrackClip *find = [AUIAepHelper aepVideo:self.editor playTime:playTime];
    if (!find) {
        [self.mainTimeline clearSelected];
    }
    NSArray<AUITrackerClipData *> *allClips = [self.mainTimeline clipsAtTracker:[self.mainTimeline trackerAtIndex:AUIEditorMainTimelineIndex]];
    [allClips enumerateObjectsUsingBlock:^(AUITrackerClipData * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (find && obj.aepVideoTrackClipObj == find) {
            if ([self.mainTimeline currentSelectedClip] != obj) {
                [self.mainTimeline selectClip:obj];
            }
            *stop = YES;
        }
    }];
}

- (void)actionItem:(AUIEditorActionItem *)item doActionResult:(NSError *)error retObject:(id)retObject {
    
    if ([item isKindOfClass:AUIEditorTransitionAddActionItem.class] || [item isKindOfClass:AUIEditorTransitionRemoveActionItem.class] || [item isKindOfClass:AUIEditorTransitionApplyAllActionItem.class]) {
        [self reloadMainTimeline];
        return;
    }
    
    [super actionItem:item doActionResult:error retObject:retObject];
    
    if (error) {
        return;
    }
    if ([item isKindOfClass:AUIEditorAudioUpdateVolumeActionItem.class]) {
        [self.mainHeader refreshVolumeState];
    }
}

- (void)timeline:(AUITimelineView *)timelineView currentTimeChanged:(NSTimeInterval)currentTime {
    
    NSTimeInterval playTime = currentTime;
    if (currentTime < 0) {
        playTime = 0;
    }
    else if (currentTime > [self.player duration]) {
        playTime = [self.player duration];
    }
    
    if (playTime != [self.player currentTime]) {
        [self.player seek:playTime];
    }
}

- (void)timeline:(AUITimelineView *)timelineView didClickedTransition:(AUITrackerClipData *)clip {
    [self.player pause];
    [self showTransitionPanel:clip.aepVideoTrackClipObj];
}

- (void)showTransitionPanel:(AEPVideoTrackClip *)currentTrackClip
{
    AUITransitionControllPanel *panel = [[AUITransitionControllPanel alloc] initWithFrame:self.bounds];
    panel.currentTrackClip = currentTrackClip;
    panel.actionManager = self.actionManager;
    [AUITransitionControllPanel present:panel onView:self backgroundType:AVControllPanelBackgroundTypeNone];
}

- (void)playProgress:(double)progress {
    if (self.player.isPlaying) {
        [self.mainTimeline setCurrentTime:[self.player playRangeTime]];
    }

    [self tryToSelectClip:self.player.currentTime];
}

@end
