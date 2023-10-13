//
//  AUITransitionControllPanel.h
//  AlivcUgsvDemo
//
//  Created by mengyehao on 2022/6/23.
//

#import "AVBaseControllPanel.h"
#import "AUIEditorActionManager.h"
#import <AUIUgsvCom/AUIUgsvCom.h>

@class AEPVideoTrackClip;

NS_ASSUME_NONNULL_BEGIN

@interface AUITransitionControllPanel : AVBaseControllPanel

@property (nonatomic, weak) AUIEditorActionManager *actionManager;
@property (nonatomic, weak) AEPVideoTrackClip *currentTrackClip;

+ (AUITrackerClipTransitionData *)transDataNotApply;
+ (AUITrackerClipTransitionData *)transDataApplying:(nonnull AEPTransitionEffect *)effect speed:(CGFloat)speed;

@end

NS_ASSUME_NONNULL_END
