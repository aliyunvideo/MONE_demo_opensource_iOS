//
//  AUIEditorMultiTimelineEditBar.h
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/6/17.
//

#import "AUIEditorTimelineEditBar.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUIEditorMultiTimelineEditBar : AUIEditorTimelineEditBar

@property (nonatomic, strong, readonly) AUITimelineView *subTimeline;

- (void)addSubTrackerClip:(AUITrackerClipData *)clip;
- (void)removeSubTrackerClip:(AUITrackerClipData *)clip;

- (AUITrackerClipData *)clipWithTimelineIn:(NSTimeInterval)timelineIn
                               timelineOut:(NSTimeInterval)timelineOut
                                    clipIn:(NSTimeInterval)clipIn
                                   clipOut:(NSTimeInterval)clipOut
                                     speed:(CGFloat)speed
                                 titleView:(AUIEditorTimelineTitleView *)titleView;
- (AUITrackerClipData *)clipWithTimelineIn:(NSTimeInterval)timelineIn
                              clipDuration:(NSTimeInterval)clipDuration
                                     speed:(CGFloat)speed
                                 titleView:(AUIEditorTimelineTitleView *)titleView;

- (void)tryToAddClip:(NSTimeInterval)start;
- (void)tryToRemoveClip:(AUITrackerClipData *)clip;

@end

NS_ASSUME_NONNULL_END
