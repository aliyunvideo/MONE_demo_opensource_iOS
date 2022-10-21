//
//  AUIEditorTimelineEditBar.h
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/6/17.
//

#import "AUIEditorEditBar.h"
#import "AUIEditorTimelineTitleLoader.h"
#import "AUIEditorTrackerHeaderView.h"
#import "AUITrackerClipData+AepHelper.h"
#import "AUIAepHelper.h"

NS_ASSUME_NONNULL_BEGIN

#define AUIEditorMainTimelineIndex 0

@interface AUIEditorTimelineEditBar : AUIEditorEditBar <AUITimelineViewDelegate>

@property (nonatomic, strong, readonly) AUITimelineView *mainTimeline;
@property (nonatomic, strong, readonly) AUIEditorPlay *player;
@property (nonatomic, strong, readonly) AliyunEditor *editor;


- (void)reloadMainTimeline;

// override by subclass
- (CGFloat)mainTrackerTopMargin;
- (BOOL)enableSelectClipData;
- (BOOL)hiddentTimeIndicator;
- (BOOL)hiddenCurrentTimeIndicator;
- (BOOL)hiddenMainTrakcerHeader;

@end

NS_ASSUME_NONNULL_END
