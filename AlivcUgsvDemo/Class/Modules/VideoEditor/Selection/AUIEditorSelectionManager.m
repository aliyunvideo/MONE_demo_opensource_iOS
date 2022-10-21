//
//  AUIEditorSelectionManager.m
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/5/30.
//

#import "AUIEditorSelectionManager.h"

@interface AUIEditorSelectionManager () <AUIVideoPlayObserver>


@property (nonatomic, strong) NSHashTable<id<AUIEditorSelectionObserver>> *observerTable;
@property (nonatomic, weak) AUIEditorActionManager *actionManager;
@property (nonatomic, readonly) AliyunEditor *editor;
@property (nonatomic, readonly) AUIEditorPlay *player;

@property (nonatomic, strong) AUIEditorSelectionPreview *currentSelectionPreview;

@end

@implementation AUIEditorSelectionManager

- (instancetype)initWithActionManager:(AUIEditorActionManager *)actionManager {
    self = [super init];
    if (self) {
        _actionManager = actionManager;
        [self.player addObserver:self];
    }
    return self;
}

- (AliyunEditor *)editor {
    return self.actionManager.currentOperator.currentEditor;
}

- (AUIEditorPlay *)player {
    return self.actionManager.currentOperator.currentPlayer;
}

// MARK: observer

- (NSHashTable<id<AUIEditorSelectionObserver>> *)observerTable {
    if (!_observerTable) {
        _observerTable = [NSHashTable weakObjectsHashTable];
    }
    return _observerTable;
}

- (void)addObserver:(id<AUIEditorSelectionObserver>)observer {
    if ([self.observerTable containsObject:observer])
    {
        return;
    }
    [self.observerTable addObject:observer];
}

- (void)removeObserver:(id<AUIEditorSelectionObserver>)observer {
    [self.observerTable removeObject:observer];
}

- (void)raiseDidSelectedResult {
    
    NSEnumerator<id<AUIEditorSelectionObserver>>* enumerator = [self.observerTable.copy objectEnumerator];
    id observer = nil;
    while ((observer = [enumerator nextObject]))
    {
        if ([observer respondsToSelector:@selector(selectionManager:didSelected:)])
        {
            [observer selectionManager:self didSelected:_selectionObject];
        }
    }
}

- (void)raiseClearResult {
    NSEnumerator<id<AUIEditorSelectionObserver>>* enumerator = [self.observerTable objectEnumerator];
    id observer = nil;
    while ((observer = [enumerator nextObject]))
    {
        if ([observer respondsToSelector:@selector(selectionManagerDidUnselected:)])
        {
            [observer selectionManagerDidUnselected:self];
        }
    }
}

- (void)raiseDidShowPreviewEvent {
    NSEnumerator<id<AUIEditorSelectionObserver>>* enumerator = [self.observerTable objectEnumerator];
    id observer = nil;
    while ((observer = [enumerator nextObject]))
    {
        if ([observer respondsToSelector:@selector(selectionManager:didShowPreview:)])
        {
            [observer selectionManager:self didShowPreview:self.currentSelectionPreview];
        }
    }
}

- (void)raiseWillHidePreviewEvent {
    NSEnumerator<id<AUIEditorSelectionObserver>>* enumerator = [self.observerTable objectEnumerator];
    id observer = nil;
    while ((observer = [enumerator nextObject]))
    {
        if ([observer respondsToSelector:@selector(selectionManager:willHidePreview:)])
        {
            [observer selectionManager:self willHidePreview:self.currentSelectionPreview];
        }
    }
}

- (void)setEnableSelectionPreview:(BOOL)enableSelectionPreview {
    _enableSelectionPreview = enableSelectionPreview;
    if (_enableSelectionPreview) {
        [self showSelectionPreview];
    }
    else {
        [self hideSelectionPreview];
    }
}

- (void)showSelectionPreview {
    
    if (![self.selectionObject renderController]) {
        return;
    }
    
    AUIEditorSelectionPreview *preview = [[AUIEditorSelectionPreview alloc] initWithRenderBaseController:[self.selectionObject renderController]];
    preview.actionManager = self.actionManager;
    preview.selectionManager = self;
    preview.enableEdit = NO;
    
    self.currentSelectionPreview = preview;
    [self.selectionPreviewSuperView addSubview:self.currentSelectionPreview];

    [self updateCurrentStickerPreviewVisible:NO];
    if (!self.currentSelectionPreview.hidden) {
        [self raiseDidShowPreviewEvent];
    }
}

- (void)hideSelectionPreview {
    
    if (self.currentSelectionPreview && !self.currentSelectionPreview.hidden) {
        [self raiseWillHidePreviewEvent];
    }
    
    [self.currentSelectionPreview removeFromSuperview];
    self.currentSelectionPreview = nil;
}

- (void)updateCurrentStickerPreviewVisible:(BOOL)raiseEvent {
    AUIEditorSelectionObject *selectionObject = self.selectionObject;
    if (!selectionObject) {
        return;
    }
    AEPStickerBaseTrack *track = selectionObject.aepObject;
    NSTimeInterval startTime = track.timelineIn;
    NSTimeInterval duration = track.timelineOut - track.timelineIn;
    if (self.player.currentTime * self.player.speed > startTime + duration
        || self.player.currentTime  * self.player.speed <  startTime) {
        if (!self.currentSelectionPreview.hidden) {
            if (raiseEvent) {
                [self raiseWillHidePreviewEvent];
            }
            self.currentSelectionPreview.hidden = YES;
        }
    }
    else {
        if (self.currentSelectionPreview.hidden) {
            self.currentSelectionPreview.hidden = NO;
            if (raiseEvent) {
                [self raiseDidShowPreviewEvent];
            }
        }
    }
}

// 根据点击的位置，是否select一个aepObject
- (BOOL)selectFromDisplayViewPosition:(CGPoint)point {
    BOOL hasSeleted = self.selectionObject != nil;
    
    AliyunEditor *editor = self.actionManager.currentOperator.currentEditor;
    AliyunRenderBaseController *vc = [editor.getStickerManager findControllerAtPoint:point atTime:self.player.currentTime * self.player.speed];
    
    __block id aepobj = nil;
    if ([vc isKindOfClass:AliyunRenderBaseController.class] ) {
        [editor.getEditorProject.timeline.stickerTracks enumerateObjectsUsingBlock:^(AEPStickerTrack * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:AEPCaptionTrack.class]) {
                if (vc == [(AEPCaptionTrack *)obj captionStickerController]) {
                    aepobj = obj;
                    *stop = YES;
                }
            } else if ([obj isKindOfClass:AEPGifStickerTrack.class]) {
                if (vc == [(AEPGifStickerTrack *)obj gifStickerController]) {
                    aepobj = obj;
                    *stop = YES;
                }
            }
        }];
    }
    
    if (aepobj) {
        if (self.selectionObject.aepObject != aepobj) {
            [self unselect];
            [self select:aepobj];
        }
    }
    else {
        if ( hasSeleted) {
            [self unselect];
        }
    }
    
    return hasSeleted || self.selectionObject != nil;
}

- (BOOL)select:(id)aepObject {
    if (self.selectionObject.aepObject == aepObject) {
        return NO;
    }
    
    if (self.selectionObject.aepObject) {
        [self unselect];
    }
    
    [self.player pause];
    
    AUIEditorSelectionObject *obj = [AUIEditorSelectionObject selectionObject:aepObject];
    if (obj) {
        _selectionObject = obj;
        [self showSelectionPreview];
        [self raiseDidSelectedResult];
    }
    return obj != nil;
}

- (BOOL)unselect {
    if (!self.selectionObject) {
        return NO;
    }
    
    [self hideSelectionPreview];
    _selectionObject = nil;
    [self raiseClearResult];
    return YES;
}

- (void)playProgress:(double)progress {
    [self updateCurrentStickerPreviewVisible:YES];
}



@end
