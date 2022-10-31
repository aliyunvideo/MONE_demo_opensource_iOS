//
//  AUIEditorStickerActionItem.m
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/6/8.
//

#import "AUIEditorStickerActionItem.h"
#import "AUIStickerModel.h"


@implementation AUIEditorStickerAddActionItem

AUI_ACTION_METHOD_DESC(@"Add a sticker to editor")

- (BOOL)doAction:(void (^)(AUIEditorActionItem *, NSError *, id))completed {
    
    NSString *path = self.model.resourcePath;
    CGFloat speed = self.currentPlayer.speed;
    NSTimeInterval start = self.currentPlayer.currentTime * speed;
    NSTimeInterval duration = self.currentPlayer.duration * speed;
    if (start + 0.1 > duration) {
        start = MAX(duration - 3.0 / speed, 0);
    }
    duration = MIN(duration - start , 3.0 / speed);
    AliyunGifStickerController *controller = [[self.currentEditor getStickerManager] addGif:path startTime:start duration:duration];

    NSError *error = nil;
    if (!controller) {
        error = [NSError errorWithDomain:@"sticker.editor" code:ALIVC_COMMON_RETURN_FAILED userInfo:nil];
    }
    else {
        CGSize previewSize = self.currentEditor.preview.bounds.size;
        controller.gif.center = CGPointMake(previewSize.width / 2, controller.gif.originSize.height / 2);
    }
    
    if (completed) {
        completed(self, error, controller);
    }
    return error == nil;
}

AUI_ACTION_METHOD_APPLY_OBJECT(AUIStickerModel, model)


@end

@implementation AUIEditorStickerRemoveActionItem

AUI_ACTION_METHOD_DESC(@"Add a sticker to editor")

- (BOOL)doAction:(void (^)(AUIEditorActionItem *, NSError *, id))completed {
    
    [[self.currentEditor getStickerManager] remove:self.aepObject.gifStickerController];
    
    if (completed) {
        completed(self, nil, self.aepObject);
    }
    return YES;
}

AUI_ACTION_METHOD_APPLY_OBJECT(AEPGifStickerTrack, aepObject)


@end


@implementation AUIEditorStickerUpdateTimelineActionItem

AUI_ACTION_METHOD_DESC(@"Update sticker's timeline")

- (BOOL)doAction:(void (^)(AUIEditorActionItem *, NSError *, id))completed {
    
    CGFloat speed = self.currentPlayer.speed;
    AEPGifStickerTrack *aepObject = [self objectForKey:@"aep"];
    aepObject.gifStickerController.gif.startTime = [[self objectForKey:@"startTime"] doubleValue] * speed;
    aepObject.gifStickerController.gif.duration = [[self objectForKey:@"duration"] doubleValue];

    if (completed) {
        completed(self, nil, aepObject);
    }
    return YES;
}

@end
