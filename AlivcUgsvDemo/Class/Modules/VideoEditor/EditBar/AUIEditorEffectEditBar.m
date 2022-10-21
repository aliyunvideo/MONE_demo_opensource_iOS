//
//  AUIEditorEffectEditBar.m
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/6/9.
//

#import "AUIEditorEffectEditBar.h"
#import "AUIEditorSelectEffectPanel.h"
#import "AUIResourceManager.h"

@implementation AUIEditorEffectEditBar

+ (NSString *)title {
    return AUIUgsvGetString(@"特效");
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (NSString *)addBtnTitle {
    return @"+ 特效";
}

- (void)barWillAppear {
    [super barWillAppear];
    
    AliyunEditorProject *project = [self.editor getEditorProject];
    [project.timeline.effectTracks enumerateObjectsUsingBlock:^(AEPEffectTrack * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        AEPEffectAnimationFilterTrack *aep = (AEPEffectAnimationFilterTrack *)obj;
        if ([aep isKindOfClass:AEPEffectAnimationFilterTrack.class]) {
            AUITrackerClipData *clip = [self clipFromAep:aep];
            [self addSubTrackerClip:clip];
        }
    }];
}

- (AUITrackerClipData *)clipFromAep:(AEPEffectAnimationFilterTrack *)aep {
    __block AUIFilterModel *model = nil;
    NSString *resPath = aep.source.path;
    [[AUIResourceManager manager] findDataWithType:AUIResourceTypeAnimationEffects path:resPath callback:^(NSError * _Nullable error, AUIResourceModel * _Nullable data) {
        model = (AUIFilterModel *)data;
    }];
    NSTimeInterval timelineIn = aep.timelineIn;
    NSTimeInterval timelineOut = aep.timelineOut;
    AUITrackerClipData *clip = [self clipWithTimelineIn:timelineIn / self.player.speed
                                           clipDuration:timelineOut - timelineIn
                                                  speed:self.player.speed
                                              titleView:[AUIEditorTimelineTitleView textView:model.name]];
    [clip setAepObject:aep];
    return clip;
}

- (void)tryToAddClip:(NSTimeInterval)start {
    AUIEditorSelectEffectPanel *panel = [[AUIEditorSelectEffectPanel alloc] initWithFrame:self.actionManager.currentOperator.currentVC.view.bounds];
    panel.actionManager = self.actionManager;
    [AUIEditorSelectEffectPanel present:panel onView:self.actionManager.currentOperator.currentVC.view backgroundType:AVControllPanelBackgroundTypeClickToClose];
}

- (void)tryToRemoveClip:(AUITrackerClipData *)clip {
    AUIEditorEffectRemoveActionItem *action = [AUIEditorEffectRemoveActionItem new];
    action.input = clip.aepAnimationFilterTrackObj;
    BOOL result = [self.actionManager doAction:action];
    if (result) {
        [self removeSubTrackerClip:clip];
    }
}

- (void)actionItem:(AUIEditorActionItem *)item doActionResult:(NSError *)error retObject:(id)retObject {
    [super actionItem:item doActionResult:error retObject:retObject];
    
    if (error) {
        return;
    }
    if ([item isKindOfClass:AUIEditorEffectAddActionItem.class]) {
        __block AEPEffectAnimationFilterTrack *aep = nil;
        AliyunEditorProject *project = [self.editor getEditorProject];
        [project.timeline.effectTracks enumerateObjectsUsingBlock:^(AEPEffectTrack * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            AEPEffectAnimationFilterTrack *cur = (AEPEffectAnimationFilterTrack *)obj;
            if ([cur isKindOfClass:AEPEffectAnimationFilterTrack.class]) {
                if (cur.editorEffect == retObject) {
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
}

- (void)timeline:(AUITimelineView *)timelineView didUpdatedClips:(NSArray<AUITrackerClipData *> *)clips atTracker:(AUITrackerData *)tracker byEvent:(AUITimelineViewClipUpdatedEvent)event {
    
    if (timelineView == self.subTimeline) {
        [clips enumerateObjectsUsingBlock:^(AUITrackerClipData * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            AUIEditorEffectUpdateTimelineActionItem *action = [AUIEditorEffectUpdateTimelineActionItem new];
            [action setInputObject:obj.aepAnimationFilterTrackObj forKey:@"aep"];
            [action setInputObject:@(obj.start) forKey:@"startTime"];
            [action setInputObject:@(obj.clipEnd - obj.clipStart) forKey:@"duration"];
            [self.actionManager doAction:action];
        }];
    }
}

@end
