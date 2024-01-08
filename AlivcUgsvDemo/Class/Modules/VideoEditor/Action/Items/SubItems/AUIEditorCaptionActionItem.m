//
//  AUIEditorCaptionActionItem.m
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/5/31.
//

#import "AUIEditorCaptionActionItem.h"
#import "AUICaptionControllPanel.h"
#import "AUIUgsvMacro.h"

@implementation AUIEditorCaptionAddActionItem

AUI_ACTION_METHOD_DESC(@"Add the caption")

- (BOOL)doAction:(void (^)(AUIEditorActionItem *, NSError *, id))completed {

    CGFloat speed = self.currentPlayer.speed;
    NSTimeInterval start = self.currentPlayer.currentTime * speed;
    NSTimeInterval duration = self.currentPlayer.duration * speed;
    if (start + 0.1 > duration) {
        start = MAX(duration - 3.0 / speed, 0);
    }
    duration = MIN(duration - start , 3.0 / speed);
   
    AliyunCaptionStickerController *controller = [[self.currentOperator.currentEditor getStickerManager] addCaptionText:AUIUgsvGetString(@"点击输入文字") bubblePath:nil startTime:start duration:duration];

    NSError *error = nil;
    if (!controller) {
        error = [NSError errorWithDomain:@"caption.editor" code:ALIVC_COMMON_RETURN_FAILED userInfo:nil];
    }
    
    if (completed) {
        completed(self, error, controller);
    }
    return error == nil;
}

@end


@implementation AUIEditorCaptionRemoveActionItem : AUIEditorActionItem

AUI_ACTION_METHOD_DESC(@"remove the caption")

- (BOOL)doAction:(void (^)(AUIEditorActionItem *, NSError *, id))completed {

    [[self.currentOperator.currentEditor getStickerManager] remove:self.aepObject.captionStickerController];

    if (completed) {
        completed(self, nil, self.aepObject);
    }
    return YES;
}

AUI_ACTION_METHOD_APPLY_OBJECT(AEPCaptionTrack, aepObject)

@end

@implementation AUIEditorCaptionUpdateTimelineActionItem

AUI_ACTION_METHOD_DESC(@"Update caption's timeline")

- (BOOL)doAction:(void (^)(AUIEditorActionItem *, NSError *, id))completed {
    
    CGFloat speed = self.currentPlayer.speed;
    AEPCaptionTrack *aepObject = [self objectForKey:@"aep"];
    aepObject.captionStickerController.model.startTime = [[self objectForKey:@"startTime"] doubleValue] * speed;
    aepObject.captionStickerController.model.duration = [[self objectForKey:@"duration"] doubleValue];

    if (completed) {
        completed(self, nil, aepObject);
    }
    return YES;
}

@end
