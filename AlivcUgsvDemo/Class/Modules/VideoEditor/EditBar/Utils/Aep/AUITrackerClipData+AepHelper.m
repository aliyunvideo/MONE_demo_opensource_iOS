//
//  AUITrackerClipData+AepHelper.m
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/6/23.
//

#import "AUITrackerClipData+AepHelper.h"
#import <objc/runtime.h>

@implementation AUITrackerClipData (AepHelper)


static const char ObjectKey = '\0';
- (void)setAepObject:(id)aepObject {
    objc_setAssociatedObject(self, &ObjectKey, aepObject, OBJC_ASSOCIATION_RETAIN);
}

- (id)getAepObject {
    return objc_getAssociatedObject(self, &ObjectKey);
}

- (AEPVideoTrackClip *)aepVideoTrackClipObj {
    AEPVideoTrackClip *obj = [self getAepObject];
    if ([obj isKindOfClass:AEPVideoTrackClip.class]) {
        return obj;
    }
    return nil;
}

- (AEPCaptionTrack *)aepCaptionTrackObj {
    AEPCaptionTrack *obj = [self getAepObject];
    if ([obj isKindOfClass:AEPCaptionTrack.class]) {
        return obj;
    }
    return nil;
}

- (AEPGifStickerTrack *)aepStickerTrackObj {
    AEPGifStickerTrack *obj = [self getAepObject];
    if ([obj isKindOfClass:AEPGifStickerTrack.class]) {
        return obj;
    }
    return nil;
}

- (AEPEffectAnimationFilterTrack *)aepAnimationFilterTrackObj {
    AEPEffectAnimationFilterTrack *obj = [self getAepObject];
    if ([obj isKindOfClass:AEPEffectAnimationFilterTrack.class]) {
        return obj;
    }
    return nil;
}

@end
