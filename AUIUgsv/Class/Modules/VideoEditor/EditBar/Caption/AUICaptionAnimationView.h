//
//  AUICaptionAnimationView.h
//  AlivcUgsvDemo
//
//  Created by mengyehao on 2022/5/31.
//

#import <UIKit/UIKit.h>
#import "AUIFilterView.h"
#import "AUICaptionAnimationModel.h"


NS_ASSUME_NONNULL_BEGIN

@class AliyunCaptionStickerController;

@interface AUICaptionAnimationView : AUIFilterView

@property (nonatomic, weak) AliyunCaptionStickerController *stickerController;
- (void)didSeletedAnimateWithType:(TextActionType)type;

@end

NS_ASSUME_NONNULL_END
