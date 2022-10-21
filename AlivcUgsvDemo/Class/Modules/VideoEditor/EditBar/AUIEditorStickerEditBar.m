//
//  AUIEditorStickerEditBar.m
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/6/9.
//

#import "AUIEditorStickerEditBar.h"
#import "AUIEditorSelectStickerPanel.h"
#import "AUIResourceManager.h"
#import "AUIStickerModel.h"

@interface AUIEditorStickerEditBar()

@end

@implementation AUIEditorStickerEditBar

+ (NSString *)title {
    return AUIUgsvGetString(@"贴纸");
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (NSString *)addBtnTitle {
    return @"+ 贴纸";
}

- (void)barWillAppear {
    [super barWillAppear];
    
    AliyunEditorProject *project = [self.editor getEditorProject];
    [project.timeline.stickerTracks enumerateObjectsUsingBlock:^(AEPStickerTrack * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        AEPGifStickerTrack *aep = (AEPGifStickerTrack *)obj;
        if ([aep isKindOfClass:AEPGifStickerTrack.class]) {
            AUITrackerClipData *clip = [self clipFromAep:aep];
            [self addSubTrackerClip:clip];
        }
    }];
    [self updateSubTimelineSelection];
}

- (AUITrackerClipData *)findClip:(AEPGifStickerTrack *)aep {
    NSArray<AUITrackerData *> *trackers = [self.subTimeline allTrackers];
    __block AUITrackerClipData *find = nil;
    [trackers enumerateObjectsUsingBlock:^(AUITrackerData * _Nonnull tracker, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray<AUITrackerClipData *> *clips = [self.subTimeline clipsAtTracker:tracker];
        [clips enumerateObjectsUsingBlock:^(AUITrackerClipData * _Nonnull clip, NSUInteger idx, BOOL * _Nonnull stop) {
            if (clip.aepStickerTrackObj == aep) {
                find = clip;
                *stop = YES;
            }
        }];
        if (find) {
            *stop = YES;
        }
    }];
    return find;
}

- (void)updateSubTimelineSelection {
    [self.subTimeline clearSelected];
    if (!self.selectionManager.selectionObject || self.selectionManager.selectionObject.type != AUIEditorSelectionObjectTypeSticker) {
        return;
    }
    
    AUITrackerClipData *find = [self findClip:self.selectionManager.selectionObject.aepObject];
    if (find) {
        [self.subTimeline selectClip:find];
    }
}

- (AUITrackerClipData *)clipFromAep:(AEPGifStickerTrack *)aep {
    __block AUIStickerModel *model = nil;
    NSString *resPath = aep.source.path;
    [[AUIResourceManager manager] findDataWithType:AUIResourceTypeSticker path:resPath callback:^(NSError * _Nullable error, AUIResourceModel * _Nullable data) {
        model = (AUIStickerModel *)data;
    }];
    NSTimeInterval timelineIn = aep.timelineIn;
    NSTimeInterval timelineOut = aep.timelineOut;
    AUITrackerClipData *clip = [self clipWithTimelineIn:timelineIn / self.player.speed
                                           clipDuration:timelineOut - timelineIn
                                                  speed:self.player.speed
                                              titleView:[AUIEditorTimelineTitleView imageView:model.iconPath]];
    [clip setAepObject:aep];
    return clip;
}

- (void)tryToAddClip:(NSTimeInterval)start {
    AUIEditorSelectStickerPanel *panel = [[AUIEditorSelectStickerPanel alloc] initWithFrame:self.actionManager.currentOperator.currentVC.view.bounds];
    panel.actionManager = self.actionManager;
    [AUIEditorSelectStickerPanel present:panel onView:self.actionManager.currentOperator.currentVC.view backgroundType:AVControllPanelBackgroundTypeCloseAndPassEvent];
}

- (void)tryToRemoveClip:(AUITrackerClipData *)clip {
    AUIEditorStickerRemoveActionItem *action = [AUIEditorStickerRemoveActionItem new];
    action.input = clip.aepStickerTrackObj;
    BOOL result = [self.actionManager doAction:action];
    if (result) {
        //
    }
}

- (void)actionItem:(AUIEditorActionItem *)item doActionResult:(NSError *)error retObject:(id)retObject {
    [super actionItem:item doActionResult:error retObject:retObject];
    
    if (error) {
        return;
    }
    if ([item isKindOfClass:AUIEditorStickerAddActionItem.class]) {
        __block AEPGifStickerTrack *aep = nil;
        AliyunEditorProject *project = [self.editor getEditorProject];
        [project.timeline.stickerTracks enumerateObjectsUsingBlock:^(AEPStickerTrack * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            AEPGifStickerTrack *cur = (AEPGifStickerTrack *)obj;
            if ([cur isKindOfClass:AEPGifStickerTrack.class]) {
                if (cur.gifStickerController == retObject) {
                    aep = cur;
                    *stop = YES;
                }
            }
        }];
        
        if (aep) {
            AUITrackerClipData *clip = [self clipFromAep:aep];
            [self addSubTrackerClip:clip];
            [self.selectionManager select:aep];
        }
    }
    else if ([item isKindOfClass:AUIEditorStickerRemoveActionItem.class]) {
        [self.selectionManager unselect];
        AUITrackerClipData *clip = [self findClip:retObject];
        if (clip) {
            [self removeSubTrackerClip:clip];
        }
    }
}

- (void)selectionManager:(AUIEditorSelectionManager *)manger didSelected:(AUIEditorSelectionObject *)selectionObject {
    [self updateSubTimelineSelection];
}

- (void)selectionManagerDidUnselected:(AUIEditorSelectionManager *)manger {
    [self updateSubTimelineSelection];
}

- (void)timeline:(AUITimelineView *)timelineView didUpdatedClips:(NSArray<AUITrackerClipData *> *)clips atTracker:(AUITrackerData *)tracker byEvent:(AUITimelineViewClipUpdatedEvent)event {
    
    if (timelineView == self.subTimeline) {
        [clips enumerateObjectsUsingBlock:^(AUITrackerClipData * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            AUIEditorStickerUpdateTimelineActionItem *action = [AUIEditorStickerUpdateTimelineActionItem new];
            [action setInputObject:obj.aepStickerTrackObj forKey:@"aep"];
            [action setInputObject:@(obj.start) forKey:@"startTime"];
            [action setInputObject:@(obj.clipEnd - obj.clipStart) forKey:@"duration"];
            [self.actionManager doAction:action];
        }];
    }
}

@end
