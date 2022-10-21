//
//  AUIRecorderFaceStickerPanel.h
//  AlivcUgsvDemo
//
//  Created by coder.pi on 2022/6/6.
//

#import "AVBaseControllPanel.h"
#import "AUIStickerModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^OnFaceStickerSelectedChanged)(AUIStickerModel *);

@interface AUIRecorderFaceStickerPanel : AVBaseControllPanel
@property (nonatomic, copy) OnFaceStickerSelectedChanged onSelectedChanged;

+ (AUIRecorderFaceStickerPanel *) present:(UIView *)superView onSelectedChange:(OnFaceStickerSelectedChanged)selectedChanged;
@end

NS_ASSUME_NONNULL_END
