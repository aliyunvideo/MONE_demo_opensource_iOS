//
//  AUIEditorAudioActionItem.m
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/5/31.
//

#import "AUIEditorAudioActionItem.h"

// MARK: - AUIEditorAudioUpdateVolumeActionItem
@implementation AUIEditorAudioUpdateVolumeActionItem

AUI_ACTION_METHOD_NAME(@"Update Volume")
AUI_ACTION_METHOD_DESC(@"Update Volume for streamIds")

- (void)setVolume:(float)volume {
    [self setInputObject:@(volume) forKey:@"volume"];
}
- (float)volume {
    return ((NSNumber *)[self objectForKey:@"volume"]).floatValue;
}

- (void)setForStreamIds:(NSArray<NSNumber *> *)forStreamIds {
    [self setInputObject:forStreamIds forKey:@"forStreamIds"];
}
- (NSArray<NSNumber *> *)forStreamIds {
    return (NSArray<NSNumber *> *)[self objectForKey:@"forStreamIds"];
}

- (BOOL)doAction:(void(^)(AUIEditorActionItem *sender, NSError *error, id retObject))completed {
    AliyunEditor *editor = self.currentEditor;
    NSArray<NSNumber *> *streamIds = self.forStreamIds;
    int volumeWeight = self.volume * 100;
    BOOL isSuccess = YES;
    NSString *errMsg = @"";
    for (NSNumber *streamId in streamIds) {
        int ret = [editor setAudioWeight:volumeWeight streamId:streamId.intValue];
        if (ret != ALIVC_COMMON_RETURN_SUCCESS) {
            NSString *tmpErrMsg = [NSString stringWithFormat:@"setAudioWeight: %d for stream: %@ fail\n", volumeWeight, streamId];
            errMsg = [errMsg stringByAppendingString:tmpErrMsg];
            isSuccess = NO;
        }
    }
    
    NSError *error = nil;
    if (!isSuccess) {
        error = [NSError errorWithDomain:@"com.alivc.ugsv.demo" code:-1 userInfo:@{
            NSLocalizedDescriptionKey: errMsg
        }];
    }
    
    if (completed) {
        completed(self, error, @(isSuccess));
    }
    return isSuccess;
}

@end

@implementation AUIEditorAudioClearEffectActionItem

- (void)setForStreamIds:(NSArray<NSNumber *> *)forStreamIds {
    [self setInputObject:forStreamIds forKey:@"forStreamIds"];
}
- (NSArray<NSNumber *> *)forStreamIds {
    return [self objectForKey:@"forStreamIds"];
}

- (AEPAudioEffect *)findAudioEffectWithStreamId:(int)streamId {
    AEPTimeline *timeline = self.currentEditor.getEditorProject.timeline;
    
    // main track
    NSArray<AEPVideoTrackClip *> *clips = timeline.mainVideoTrack.clipList;
    for (AEPVideoTrackClip *clip in clips) {
        if (clip.mediaId == streamId) {
            return clip.audioEffect;
        }
    }
    
    // pip track
    NSArray<AEPPipVideoTrack *> *pipTracks = timeline.pipVideoTracks;
    for (AEPPipVideoTrack *track in pipTracks) {
        for (AEPPipVideoTrackClip *clip in track.clipList) {
            if (clip.mediaId == streamId) {
                return clip.audioEffect;
            }
        }
    }

    // audio track
    NSArray<AEPAudioTrack *> *audioTracks = timeline.audioTracks;
    for (AEPAudioTrack *track in audioTracks) {
        for (AEPAudioTrackClip *clip in track.clipList) {
            if (clip.mediaId == streamId) {
                return clip.audioEffect;
            }
        }
    }
    return nil;
}

- (BOOL)doAction:(void (^)(AUIEditorActionItem *, NSError *, id))completed {
    AliyunEditor *editor = self.currentEditor;
    NSArray<NSNumber *> *streamIds = self.forStreamIds;
    
    BOOL isSuccess = YES;
    NSString *errMsg = @"";
    
    for (NSNumber *tmpId in streamIds) {
        int streamId = tmpId.intValue;
        AEPAudioEffect *audioEffect = [self findAudioEffectWithStreamId:streamId];
        if (!audioEffect) {
            continue;
        }
        int ret = [editor removeAudioEffect:audioEffect.effectType streamId:streamId];
        if (ret != ALIVC_COMMON_RETURN_SUCCESS) {
            NSString *tmpErrMsg = [NSString stringWithFormat:@"removeAudioEffect: %d for stream: %d fail\n",
                                   (int)audioEffect.effectType, streamId];
            errMsg = [errMsg stringByAppendingString:tmpErrMsg];
            isSuccess = NO;
        }
    }
    
    NSError *error = nil;
    if (!isSuccess) {
        error = [NSError errorWithDomain:@"com.alivc.ugsv.demo" code:-1 userInfo:@{
            NSLocalizedDescriptionKey: errMsg
        }];
    }
    
    if (completed) {
        completed(self, error, @(isSuccess));
    }
    return isSuccess;
}

@end

@implementation AUIEditorAudioUpdateEffectActionItem

- (void)setAudioEffect:(AliyunAudioEffect *)audioEffect {
    [self setInputObject:audioEffect forKey:@"audioEffect"];
}
- (AliyunAudioEffect *)audioEffect {
    return [self objectForKey:@"audioEffect"];
}

- (BOOL)doAction:(void (^)(AUIEditorActionItem *, NSError *, id))completed {
    AliyunEditor *editor = self.currentEditor;
    NSArray<NSNumber *> *streamIds = self.forStreamIds;
    AliyunAudioEffect *targetEffect = self.audioEffect;
    
    BOOL isSuccess = YES;
    NSString *errMsg = @"";
    
    for (NSNumber *tmpId in streamIds) {
        int streamId = tmpId.intValue;
        AEPAudioEffect *audioEffect = [self findAudioEffectWithStreamId:streamId];
        if (audioEffect) {
            [editor removeAudioEffect:audioEffect.effectType streamId:streamId];
        }
        int ret = [editor setAudioEffect:targetEffect.type weight:targetEffect.weight streamId:streamId];
        if (ret != ALIVC_COMMON_RETURN_SUCCESS) {
            NSString *tmpErrMsg = [NSString stringWithFormat:@"setAudioEffect: %d with weight: %d for stream: %d fail\n",
                                   (int)targetEffect.type, targetEffect.weight, streamId];
            errMsg = [errMsg stringByAppendingString:tmpErrMsg];
            isSuccess = NO;
        }
    }

    NSError *error = nil;
    if (!isSuccess) {
        error = [NSError errorWithDomain:@"com.alivc.ugsv.demo" code:-1 userInfo:@{
            NSLocalizedDescriptionKey: errMsg
        }];
    }
    
    if (completed) {
        completed(self, error, @(isSuccess));
    }
    return isSuccess;
}

@end
