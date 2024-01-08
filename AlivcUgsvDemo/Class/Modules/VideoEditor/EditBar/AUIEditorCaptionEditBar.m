//
//  AUIEditorCaptionEditBar.m
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/6/9.
//

#import "AUIEditorCaptionEditBar.h"
#import "AUICaptionControllPanel.h"

@interface AUIEditorCaptionEditBar()
@property (nonatomic, weak) AUICaptionControllPanel *panel;
@end

@implementation AUIEditorCaptionEditBar

+ (NSString *)title {
    return AUIUgsvGetString(@"文字");
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (NSString *)addBtnTitle {
    return AUIUgsvGetString(@"+ 文字");
}

- (void)barWillAppear {
    [super barWillAppear];
    
    AliyunEditorProject *project = [self.editor getEditorProject];
    [project.timeline.stickerTracks enumerateObjectsUsingBlock:^(AEPStickerTrack * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        AEPCaptionTrack *aep = (AEPCaptionTrack *)obj;
        if ([aep isKindOfClass:AEPCaptionTrack.class]) {
            AUITrackerClipData *clip = [self clipFromAep:aep];
            [self addSubTrackerClip:clip];
        }
    }];
    [self updateSubTimelineSelection];
    [self updateSelectionPreview:NO];
}

- (AUITrackerClipData *)findClip:(AEPCaptionTrack *)aep {
    NSArray<AUITrackerData *> *trackers = [self.subTimeline allTrackers];
    __block AUITrackerClipData *find = nil;
    [trackers enumerateObjectsUsingBlock:^(AUITrackerData * _Nonnull tracker, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray<AUITrackerClipData *> *clips = [self.subTimeline clipsAtTracker:tracker];
        [clips enumerateObjectsUsingBlock:^(AUITrackerClipData * _Nonnull clip, NSUInteger idx, BOOL * _Nonnull stop) {
            if (clip.aepCaptionTrackObj == aep) {
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
    if (!self.selectionManager.selectionObject || self.selectionManager.selectionObject.type != AUIEditorSelectionObjectTypeText) {
        return;
    }
    AUITrackerClipData *find = [self findClip:self.selectionManager.selectionObject.aepObject];
    if (find) {
        [self.subTimeline selectClip:find];
    }
}

- (AUITrackerClipData *)clipFromAep:(AEPCaptionTrack *)aep {
    NSTimeInterval timelineIn = aep.timelineIn;
    NSTimeInterval timelineOut = aep.timelineOut;
    AUITrackerClipData *clip = [self clipWithTimelineIn:timelineIn / self.player.speed
                                           clipDuration:timelineOut - timelineIn
                                                  speed:self.player.speed
                                              titleView:[AUIEditorTimelineTitleView textView:aep.text]];
    [clip setAepObject:aep];
    return clip;
}

- (void)updateClipTitle:(AEPCaptionTrack *)aep {
    AUITrackerClipData *find = [self findClip:self.selectionManager.selectionObject.aepObject];
    if (find) {
        [(AUIEditorTimelineTitleLoader *)find.titleViewLoader titleView].textView.text = aep.text;
    }
}

- (void)tryToAddClip:(NSTimeInterval)start {
    AUIEditorCaptionAddActionItem * addActionItem = [AUIEditorCaptionAddActionItem new];
    [self.actionManager doAction:addActionItem];
}

- (void)tryToRemoveClip:(AUITrackerClipData *)clip {
    AUIEditorCaptionRemoveActionItem *action = [AUIEditorCaptionRemoveActionItem new];
    action.input = clip.aepCaptionTrackObj;
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
    if ([item isKindOfClass:AUIEditorCaptionAddActionItem.class]) {
        __block AEPCaptionTrack *aep = nil;
        AliyunEditorProject *project = [self.editor getEditorProject];
        [project.timeline.stickerTracks enumerateObjectsUsingBlock:^(AEPStickerTrack * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            AEPCaptionTrack *cur = (AEPCaptionTrack *)obj;
            if ([cur isKindOfClass:AEPCaptionTrack.class]) {
                if (cur.captionStickerController == retObject) {
                    aep = cur;
                    *stop = YES;
                }
            }
        }];
        
        if (aep) {
            AUITrackerClipData *clip = [self clipFromAep:aep];
            [self addSubTrackerClip:clip];
            [self.selectionManager select:aep];
            [self showCaptionPanel:aep];
        }
    }
    else if ([item isKindOfClass:AUIEditorCaptionRemoveActionItem.class]) {
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
    if (self.panel) {
        [self.panel hide];
        self.panel = nil;
    }
    [self updateSubTimelineSelection];
}

- (void)selectionManager:(AUIEditorSelectionManager *)manger didShowPreview:(AUIEditorSelectionPreview *)preview {
    [self updateSelectionPreview:NO];
}

- (void)selectionManager:(AUIEditorSelectionManager *)manger willHidePreview:(AUIEditorSelectionPreview *)preview {
    [self updateSelectionPreview:YES];
}

- (void)updateSelectionPreview:(BOOL)clear {
    if (self.selectionManager.selectionObject.type == AUIEditorSelectionObjectTypeText) {
        if (clear) {
            self.selectionManager.currentSelectionPreview.enableEdit = NO;
            self.selectionManager.currentSelectionPreview.onEditBlock = nil;
        }
        else {
            self.selectionManager.currentSelectionPreview.enableEdit = !self.panel.isShowing;
            __weak typeof(self) weakSelf = self;
            self.selectionManager.currentSelectionPreview.onEditBlock = ^{
                if ([weakSelf.selectionManager.selectionObject.aepObject isKindOfClass:AEPCaptionTrack.class]) {
                    [weakSelf.player pause];
                    [weakSelf showCaptionPanel:weakSelf.selectionManager.selectionObject.aepObject];
                }
            };
        }
    }
}

- (void)showCaptionPanel:(AEPCaptionTrack *)aep {
    AUICaptionControllPanel *panel = [[AUICaptionControllPanel alloc] initWithFrame:self.actionManager.currentOperator.currentVC.view.bounds];
    panel.aep = aep;
    panel.actionManger = self.actionManager;
    
    __weak typeof(self) weakSelf = self;
    panel.onShowChanged = ^(AVBaseControllPanel * _Nonnull sender) {
        weakSelf.selectionManager.currentSelectionPreview.enableEdit = !sender.isShowing;
        if (!sender.isShowing) {
            [weakSelf updateClipTitle:((AUICaptionControllPanel *)sender).aep];
        }
    };
    [AUICaptionControllPanel present:panel onView:self.actionManager.currentOperator.currentVC.view backgroundType:AVControllPanelBackgroundTypeNone];
    panel.onKeyboardShowChanged = self.onKeyboardShowChanged;
    self.panel = panel;
}

- (void)timeline:(AUITimelineView *)timelineView didUpdatedClips:(NSArray<AUITrackerClipData *> *)clips atTracker:(AUITrackerData *)tracker byEvent:(AUITimelineViewClipUpdatedEvent)event {
    
    if (timelineView == self.subTimeline) {
        [clips enumerateObjectsUsingBlock:^(AUITrackerClipData * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            AUIEditorCaptionUpdateTimelineActionItem *action = [AUIEditorCaptionUpdateTimelineActionItem new];
            [action setInputObject:obj.aepCaptionTrackObj forKey:@"aep"];
            [action setInputObject:@(obj.start) forKey:@"startTime"];
            [action setInputObject:@(obj.clipEnd - obj.clipStart) forKey:@"duration"];
            [self.actionManager doAction:action];
        }];
    }
}

- (void)textViewResignFirstResponder
{
    [self.panel textViewResignFirstResponder];
}
@end
