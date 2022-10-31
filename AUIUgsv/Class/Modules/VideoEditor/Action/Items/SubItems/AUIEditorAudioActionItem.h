//
//  AUIEditorAudioActionItem.h
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/5/31.
//

#import "AUIEditorActionItem.h"

@interface AUIEditorAudioUpdateVolumeActionItem : AUIEditorActionItem

@property (nonatomic) float volume;
@property (nonatomic) NSArray<NSNumber *> *forStreamIds;

@end

@interface AUIEditorAudioClearEffectActionItem : AUIEditorActionItem
@property (nonatomic) NSArray<NSNumber *> *forStreamIds;
@end

@interface AUIEditorAudioUpdateEffectActionItem : AUIEditorAudioClearEffectActionItem
@property (nonatomic) AliyunAudioEffect *audioEffect;
@end
