//
//  AUIEditorVideoActionItem.h
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/5/31.
//

#import "AUIEditorActionItem.h"


@interface AUIEditorVideoApplyTimeFilterActionItem : AUIEditorActionItem

@end



@interface AUIEditorVideoAugmentationActionItem : AUIEditorActionItem

@property (nonatomic, copy) NSDictionary<NSNumber */*type*/, NSNumber */*value*/> *values;
@property (nonatomic, copy) NSArray<NSNumber *> *streamIds;

@end



@interface AUIEditorVideoAugmentationResetActionItem : AUIEditorVideoAugmentationActionItem

@end



@interface AUIEditorTransitionAddActionItem : AUIEditorActionItem

@end



@interface AUIEditorTransitionRemoveActionItem : AUIEditorActionItem

@end



@interface AUIEditorTransitionApplyAllActionItem : AUIEditorActionItem

@end
