//
//  AUITimelineView.h
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/5/30.
//

#import <UIKit/UIKit.h>
#import "AUITrackerClipSelectionView.h"
#import "AUITrackerThumbnailRequest.h"
#import "AUITrackerTitleViewLoader.h"
#import "AUITrackerHeaderViewLoader.h"

@interface AUITrackerData : NSObject

@property (nonatomic, assign, readonly) NSUInteger index;
@property (nonatomic, assign, readonly) CGSize thumbSize;

@property (nonatomic, strong) id<AUITrackerHeaderViewLoaderProtocol> headerViewLoader;

- (instancetype)initWithIndex:(NSUInteger)index withThumbSize:(CGSize)size;

@end

@interface AUITrackerClipTransitionData : NSObject

@property (nonatomic, assign, readonly) NSTimeInterval duration;
@property (nonatomic, assign, readonly) BOOL isApply;
@property (nonatomic, strong, readonly) UIImage *icon;

- (instancetype)initWithIsApply:(BOOL)isApply withDuration:(NSTimeInterval)duration withIcon:(UIImage *)icon;

@end



@interface AUITrackerClipData : NSObject

@property (nonatomic, assign, readonly) BOOL autoStart;
@property (nonatomic, assign, readonly) NSTimeInterval start;
@property (nonatomic, assign, readonly) NSTimeInterval duration; // 最短100毫秒（at least 100ms）
@property (nonatomic, assign, readonly) NSTimeInterval clipStart;
@property (nonatomic, assign, readonly) NSTimeInterval clipEnd;
@property (nonatomic, assign, readonly) CGFloat speed;

@property (nonatomic, weak, readonly) AUITrackerData *trackerData;

@property (nonatomic, assign) BOOL enableSelected;
@property (nonatomic, assign) BOOL enablePanLeftRight;

@property (nonatomic, copy) UIColor *thumbBgColor;
@property (nonatomic, assign) UIViewContentMode thumbDisplayMode;  // default: UIViewContentModeScaleAspectFill
@property (nonatomic, strong) UIImage *thumbImage;
@property (nonatomic, strong) id<AUITrackerThumbnailRequestProtocol> thumbRequest;

@property (nonatomic, strong) id<AUITrackerTitleViewLoaderProtocol> titleViewLoader;

@property (nonatomic, strong, readonly) AUITrackerClipTransitionData *transData;

- (instancetype)initWithAutoStart:(BOOL)autoStart withStart:(NSTimeInterval)start withDruation:(NSTimeInterval)duration withClipStart:(NSTimeInterval)clipStart withClipEnd:(NSTimeInterval)clipEnd withTrans:(AUITrackerClipTransitionData *)trans withSpeed:(CGFloat)speed;
- (instancetype)initWithAutoStart:(BOOL)autoStart withStart:(NSTimeInterval)start withDruation:(NSTimeInterval)duration withClipStart:(NSTimeInterval)clipStart withClipEnd:(NSTimeInterval)clipEnd;

@end

typedef NS_ENUM(NSUInteger, AUITimelineViewClipUpdatedEvent) {
    AUITimelineViewClipUpdatedEventPanLeft,
    AUITimelineViewClipUpdatedEventPanRight,
    AUITimelineViewClipUpdatedEventMove,
    AUITimelineViewClipUpdatedEventRemove,
};

@class AUITimelineView;
@protocol AUITimelineViewDelegate <NSObject>

@optional
- (void)timeline:(AUITimelineView *)timelineView durationChanged:(NSTimeInterval)duration;
- (void)timeline:(AUITimelineView *)timelineView currentTimeChanged:(NSTimeInterval)currentTime;
- (void)timeline:(AUITimelineView *)timelineView didSelectedClip:(AUITrackerClipData *)clip;
- (void)timeline:(AUITimelineView *)timelineView didClickedClip:(AUITrackerClipData *)clip;
- (void)timeline:(AUITimelineView *)timelineView onUpdatingClip:(AUITrackerClipData *)clip byEvent:(AUITimelineViewClipUpdatedEvent)event;
- (void)timeline:(AUITimelineView *)timelineView didUpdatedClips:(NSArray<AUITrackerClipData *> *)clips atTracker:(AUITrackerData *)tracker byEvent:(AUITimelineViewClipUpdatedEvent)event;

- (void)timeline:(AUITimelineView *)timelineView didClickedTransition:(AUITrackerClipData *)clip;


@end

@interface AUITimelineView : UIView

@property (nonatomic, weak) id<AUITimelineViewDelegate> delegate;

@property (nonatomic, strong, readonly) AUITrackerClipSelectionView *selectionView;

@property (nonatomic, assign, readonly) NSTimeInterval actualDuration;
@property (nonatomic, assign) NSTimeInterval minDuration;
@property (nonatomic, assign) NSTimeInterval maxDuration;
@property (nonatomic, assign) NSTimeInterval currentTime;

@property (nonatomic, assign) CGFloat trackerMarginTop;  // default: 32
@property (nonatomic, assign) CGFloat trackerMarginBottom; // default: 20
@property (nonatomic, assign) CGFloat trackerMarginSpace;  // default: 8

@property (nonatomic, assign) BOOL disbaleSelectClipByTap;
@property (nonatomic, assign) BOOL disbaleClipLongPress;


- (instancetype)initWithFrame:(CGRect)frame hiddentTimeIndicator:(BOOL)hiddenTimeIndicator hiddenCurrentTimeIndicator:(BOOL)hiddenCurrentTimeIndicator scrollInset:(UIEdgeInsets)scrollInset;

- (AUITrackerData *)trackerAtIndex:(NSUInteger)index;
- (NSArray<AUITrackerData *> *)allTrackers;
- (BOOL)addTracker:(AUITrackerData *)tracker;
- (BOOL)removeTracker:(AUITrackerData *)tracker;

- (NSArray<AUITrackerClipData *> *)clipsAtTracker:(AUITrackerData *)tracker;
- (BOOL)addClip:(AUITrackerClipData *)clip atTracker:(AUITrackerData *)tracker;
- (BOOL)removeClip:(AUITrackerClipData *)clip;
- (BOOL)removeAllClipsAtTracker:(AUITrackerData *)tracker;
- (BOOL)updateClip:(AUITrackerClipData *)clip withStart:(NSTimeInterval)start withClipStart:(NSTimeInterval)clipStart withClipEnd:(NSTimeInterval)clipEnd;

- (AUITrackerClipData *)currentSelectedClip;
- (BOOL)selectClip:(AUITrackerClipData *)clip;
- (BOOL)clearSelected;

@end
