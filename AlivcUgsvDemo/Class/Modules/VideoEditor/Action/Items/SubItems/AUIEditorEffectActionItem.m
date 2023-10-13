//
//  AUIEditorEffectActionItem.m
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/5/31.
//

#import "AUIEditorEffectActionItem.h"
#import "AUIFilterModel.h"


@implementation AUIEditorEffectAddActionItem

AUI_ACTION_METHOD_DESC(@"Add effect to editor")

- (BOOL)doAction:(void (^)(AUIEditorActionItem *, NSError *, id))completed {
    
    NSString *path = self.model.resourcePath;
    CGFloat speed = self.currentPlayer.speed;
    NSTimeInterval start = self.currentPlayer.currentTime * speed;
    NSTimeInterval duration = self.currentPlayer.duration * speed;
    if (start + 0.1 > duration) {
        start = MAX(duration - 3.0 / speed, 0);
    }
    duration = MIN(duration - start , 3.0 / speed);
    
    NSError *error = nil;
    AliyunEffectFilter *aniFilter = [[AliyunEffectFilter alloc] initWithFile:path];
    aniFilter.streamStartTime = start;
    aniFilter.streamEndTime = start + duration;
    
    int ret = [self.currentEditor applyAnimationFilter:aniFilter];
    if (ret != ALIVC_COMMON_RETURN_SUCCESS) {
        error = [NSError errorWithDomain:@"animation_filter.editor" code:ret userInfo:nil];
    }
    
    if (completed) {
        completed(self, error, aniFilter);
    }
    return error == nil;
}

AUI_ACTION_METHOD_APPLY_OBJECT(AUIFilterModel, model)

@end

@implementation AUIEditorEffectRemoveActionItem

AUI_ACTION_METHOD_DESC(@"Remove effect from editor")

- (BOOL)doAction:(void (^)(AUIEditorActionItem *, NSError *, id))completed {
    
    NSError *error = nil;
    int ret = [self.currentEditor removeAnimationFilter:self.aepObject.editorEffect];
    if (ret != ALIVC_COMMON_RETURN_SUCCESS) {
        error = [NSError errorWithDomain:@"animation_filter.editor" code:ret userInfo:nil];
    }
    
    if (completed) {
        completed(self, error, self.aepObject);
    }
    return error == nil;;
}

AUI_ACTION_METHOD_APPLY_OBJECT(AEPEffectAnimationFilterTrack, aepObject)


@end


@implementation AUIEditorEffectUpdateTimelineActionItem

AUI_ACTION_METHOD_DESC(@"Update effect's timeline")

- (BOOL)doAction:(void (^)(AUIEditorActionItem *, NSError *, id))completed {
    
    CGFloat speed = self.currentPlayer.speed;
    AEPEffectAnimationFilterTrack *aepObject = [self objectForKey:@"aep"];
    NSTimeInterval start = [[self objectForKey:@"startTime"] doubleValue] * speed;
    NSTimeInterval duration = [[self objectForKey:@"duration"] doubleValue];
    
    aepObject.editorEffect.streamStartTime = start;
    aepObject.editorEffect.streamEndTime = start + duration;
    
    NSError *error = nil;
    int ret = [self.currentEditor updateAnimationFilter:aepObject.editorEffect];
    if (ret != ALIVC_COMMON_RETURN_SUCCESS) {
        error = [NSError errorWithDomain:@"animation_filter.editor" code:ret userInfo:nil];
    }
    
    if (completed) {
        completed(self, nil, aepObject);
    }
    return YES;
}

@end
