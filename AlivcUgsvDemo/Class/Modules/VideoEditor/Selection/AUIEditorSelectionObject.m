//
//  AUIEditorSelectionObject.m
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/5/30.
//

#import "AUIEditorSelectionObject.h"

@implementation AUIEditorSelectionObject

- (instancetype)init:(AUIEditorSelectionObjectType)type aep:(id)aepObject {
    self = [super init];
    if (self) {
        _type = type;
        _aepObject = aepObject;
    }
    return self;
}

- (AliyunRenderBaseController *)renderController {
    if ([self.aepObject isKindOfClass:AEPCaptionTrack.class]) {
        return [(AEPCaptionTrack *)self.aepObject captionStickerController];
    }
    
    if ([self.aepObject isKindOfClass:AEPGifStickerTrack.class]) {
        return [(AEPGifStickerTrack *)self.aepObject gifStickerController];
    }
    if ([self.aepObject isKindOfClass:AEPImageStickerTrack.class]) {
        return [(AEPImageStickerTrack *)self.aepObject imageStickerController];
    }
    return nil;
}

+ (AUIEditorSelectionObject *)selectionObject:(id)aepObject {
    AUIEditorSelectionObjectType type = AUIEditorSelectionObjectTypeNone;
    if ([aepObject isKindOfClass:AEPCaptionBaseTrack.class]) {
        type = AUIEditorSelectionObjectTypeText;
    }
    if ([aepObject isKindOfClass:AEPImageStickerTrack.class] || [aepObject isKindOfClass:AEPGifStickerTrack.class]) {
        type =  AUIEditorSelectionObjectTypeSticker;
    }
    
    AUIEditorSelectionObject *obj = nil;
    if (type != AUIEditorSelectionObjectTypeNone) {
        obj = [[AUIEditorSelectionObject alloc] init:type aep:aepObject];
    }
    return obj;
}

@end
