//
//  AUIEditorVideoActionItem.m
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/5/31.
//

#import "AUIEditorVideoActionItem.h"
#import "AUITransitionModel.h"
#import "AUIAepHelper.h"
#import "AUITransitionModel.h"

@implementation AUIEditorVideoApplyTimeFilterActionItem

AUI_ACTION_METHOD_DESC(@"Apply time filter to editor")

- (BOOL)doAction:(void (^)(AUIEditorActionItem *, NSError *, id))completed {
    
    [self.currentPlayer seek:self.currentPlayer.playRangeStart];
    [self.currentOperator markEditorNeedUpdatePlayTime];
    
    NSError *error = nil;

    AEPEffectTimeTrack *effectTimeTrack = [AUIAepHelper aepTimeEffect:self.currentEditor];
    if (effectTimeTrack && effectTimeTrack.editorEffect) {
        int ret = [self.currentEditor removeTimeFilter:effectTimeTrack.editorEffect];
        if (ret != ALIVC_COMMON_RETURN_SUCCESS) {
            error = [NSError errorWithDomain:@"time_filter.editor" code:ret userInfo:nil];
        }
        
        if (error) {
            if (completed) {
                completed(self, error, effectTimeTrack.editorEffect);
            }
            return YES;
        }
    }

    AliyunEffectTimeFilter *timeFilter = [[AliyunEffectTimeFilter alloc] init];
    timeFilter.startTime = 0;
    timeFilter.endTime = 10000.0;
    timeFilter.type = TimeFilterTypeSpeed;
    timeFilter.param = self.param.doubleValue;
    int ret = [self.currentEditor applyTimeFilter:timeFilter];
    if (ret != ALIVC_COMMON_RETURN_SUCCESS) {
        error = [NSError errorWithDomain:@"time_filter.editor" code:ret userInfo:nil];
    }
    else {
        self.currentPlayer.speed = timeFilter.param;
    }
    
    if (completed) {
        completed(self, error, timeFilter);
    }
    return error == nil;
}

AUI_ACTION_METHOD_APPLY_OBJECT(NSNumber, param)

@end

@implementation AUIEditorVideoAugmentationActionItem

AUI_ACTION_METHOD_NAME(@"Augmentation")
AUI_ACTION_METHOD_DESC(@"Update Augmentations for streamIds")

- (void)setStreamIds:(NSArray<NSNumber *> *)streamIds {
    [self setInputObject:streamIds.copy forKey:@"streamIds"];
}
- (NSArray<NSNumber *> *)streamIds {
    return [self objectForKey:@"streamIds"];
}

- (void)setValues:(NSDictionary<NSNumber *, NSNumber *> *)values {
    [self setInputObject:values.copy forKey:@"values"];
}
- (NSDictionary<NSNumber *, NSNumber *> *)values {
    return [self objectForKey:@"values"];
}

- (int)doEditActionWithType:(AliyunVideoAugmentationType)type value:(float)value streamId:(int)streamId {
    return [self.currentEditor setVideoAugmentation:type
                                              value:value
                                           streamId:streamId];
}

- (BOOL)doAction:(void (^)(AUIEditorActionItem *, NSError *, id))completed {
    NSArray<NSNumber *> *streamIds = self.streamIds;
    NSDictionary<NSNumber *, NSNumber *> *values = self.values;

    BOOL isSuccess = YES;
    NSString *errMsg = @"";
    for (NSNumber *streamId in streamIds) {
        for (NSNumber *type in values) {
            int ret = [self doEditActionWithType:(AliyunVideoAugmentationType)type.intValue
                                           value:values[type].floatValue
                                        streamId:streamId.intValue];
            if (ret != ALIVC_COMMON_RETURN_SUCCESS) {
                NSString *tmpErrMsg = [NSString stringWithFormat:@"setVideoAugmentation: %@ value: %@ for stream: %@ fail\n",
                                       type, values[type], streamId];
                errMsg = [errMsg stringByAppendingString:tmpErrMsg];
                isSuccess = NO;
            }
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

@implementation AUIEditorVideoAugmentationResetActionItem

AUI_ACTION_METHOD_NAME(@"ResetAugmentation")
AUI_ACTION_METHOD_DESC(@"Reset Augmentations for streamIds")

- (int)doEditActionWithType:(AliyunVideoAugmentationType)type value:(float)value streamId:(int)streamId {
    return [self.currentEditor resetVideoAugmentation:type streamId:streamId];
}

@end



@implementation AUIEditorTransitionAddActionItem

- (BOOL)doAction:(void (^)(AUIEditorActionItem *, NSError *, id))completed {
    AliyunEditor *editor = self.currentOperator.currentEditor ;
    [editor stopEdit];
    
    NSError *error = nil;
    __block int applyIndex = -1;
    AEPVideoTrackClip *aep = [self objectForKey:@"aep"];
    [editor.getEditorProject.timeline.mainVideoTrack.clipList enumerateObjectsUsingBlock:^(AEPVideoTrackClip * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
         if (obj == aep) {
             applyIndex = (int)idx - 1;
         }
    }];
    if (applyIndex < 0) {
        error = [NSError errorWithDomain:@"transition.editor" code:-1 userInfo:nil];
        if (completed) {
            completed(self, error, nil);
        }
        return NO;
    }
    
    AliyunTransitionEffect *trans = [self objectForKey:@"transition"];
    int ret = [editor applyTransition:trans atIndex:applyIndex];
    if (ret != ALIVC_COMMON_RETURN_SUCCESS) {
        error = [NSError errorWithDomain:@"transition.editor" code:ret userInfo:nil];
    }
    
    [editor startEdit];
    [self.currentOperator.currentPlayer play];
    if (completed) {
        completed(self, error, trans);
    }
    return YES;
}

@end


@implementation AUIEditorTransitionRemoveActionItem

- (BOOL)doAction:(void (^)(AUIEditorActionItem *, NSError *, id))completed {
    AliyunEditor *editor = self.currentOperator.currentEditor ;
    [editor stopEdit];
    
    NSError *error = nil;
    __block int applyIndex = -1;
    AEPVideoTrackClip *aep = [self objectForKey:@"aep"];
    [editor.getEditorProject.timeline.mainVideoTrack.clipList enumerateObjectsUsingBlock:^(AEPVideoTrackClip * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
         if (obj == aep) {
             applyIndex = (int)idx - 1;
         }
    }];
    if (applyIndex < 0) {
        error = [NSError errorWithDomain:@"transition.editor" code:-1 userInfo:nil];
        if (completed) {
            completed(self, error, nil);
        }
        return NO;
    }
    
    int ret = [editor removeTransitionAtIndex:applyIndex];
    if (ret != ALIVC_COMMON_RETURN_SUCCESS) {
        error = [NSError errorWithDomain:@"transition.editor" code:ret userInfo:nil];
    }
    
    [editor startEdit];
    [self.currentOperator.currentPlayer play];
    
    if (completed) {
        completed(self, error, nil);
    }
    
    return YES;
}

@end


@implementation AUIEditorTransitionApplyAllActionItem

- (BOOL)doAction:(void (^)(AUIEditorActionItem *, NSError *, id))completed {
    AliyunEditor *editor = self.currentOperator.currentEditor ;
    [editor stopEdit];
    
    
    NSArray<AEPVideoTrackClip *> *tempList = editor.getEditorProject.timeline.mainVideoTrack.clipList;
    NSInteger count = tempList.count;
    
    TransitionType transitionType = [[self objectForKey:@"transitionType"] intValue];
    for (int i = 0; i < count - 1; i++) {
        if (transitionType == TransitionTypeNull) {
            [editor removeTransitionAtIndex:i];
        }
        else {
            [editor applyTransition:[AUITransitionHelper transitionEffectWithType:transitionType] atIndex:i];
        }
    }

    [editor startEdit];
    [self.currentOperator.currentPlayer play];
    
    if (completed) {
        completed(self, nil, nil);
    }
    
    return YES;
}

@end
