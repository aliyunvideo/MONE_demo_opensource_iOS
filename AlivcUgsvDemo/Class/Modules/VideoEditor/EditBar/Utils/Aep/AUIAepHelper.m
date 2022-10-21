//
//  AUIAepHelper.m
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/6/23.
//

#import "AUIAepHelper.h"

@implementation AUIAepHelper

+ (CGFloat)timeSpeed:(AliyunEditor *)editor {
    CGFloat speed = 1.0;
    AEPEffectTimeTrack *aep = [self aepTimeEffect:editor];
    if (aep) {
        speed = aep.timeParam;
    }

    return speed;
}

+ (AEPEffectTimeTrack *)aepTimeEffect:(AliyunEditor *)editor {
    AliyunEditorProject *project = [editor getEditorProject];
    __block AEPEffectTimeTrack *curr = nil;
    [project.timeline.effectTracks enumerateObjectsUsingBlock:^(AEPEffectTrack * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        AEPEffectTimeTrack *track = (AEPEffectTimeTrack *)obj;
        if ([track isKindOfClass:AEPEffectTimeTrack.class]) {
            curr = track;
        }
    }];
    return curr;
}

+ (AEPVideoTrackClip *)aepVideo:(AliyunEditor *)editor playTime:(NSTimeInterval)playTime {
    playTime = [self timeSpeed:editor] * playTime;
    AliyunEditorProject *project = [editor getEditorProject];
    __block AEPVideoTrackClip *find = nil;
    AEPVideoTrack *track = project.timeline.mainVideoTrack;
    [track.clipList enumerateObjectsUsingBlock:^(AEPVideoTrackClip * _Nonnull videoClip, NSUInteger idx, BOOL * _Nonnull stop) {
        if (playTime >= videoClip.timelineIn && playTime <= videoClip.timelineOut) {
            find = videoClip;
            *stop = YES;
        }
    }];
    
    if (!find) {
        if (playTime < track.clipList.firstObject.timelineIn) {
            find = track.clipList.firstObject;
        }
        else if (playTime > track.clipList.lastObject.timelineOut) {
            find = track.clipList.lastObject;
        }
    }
    
    return find;
}

@end
