//
//  AUIMusicCropView.h
//  AlivcUgsvDemo
//
//  Created by coder.pi on 2022/6/9.
//

#import <UIKit/UIKit.h>
#import "AUIVideoPlayProtocol.h"
#import "AUIMusicModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^OnMusicCropConfirm)(AUIMusicSelectedModel *model);

@interface AUIMusicCropView : UIView
@property (nonatomic, weak) id<AUIVideoPlayProtocol> player;
@property (nonatomic, readonly) NSTimeInterval limitDuration;
@property (nonatomic, readonly) AUIMusicSelectedModel *model;
@property (nonatomic, copy, nullable) OnMusicCropConfirm onCropConfirm;
- (instancetype)initWithLimitDuration:(NSTimeInterval)limitDuration
                        selectedModel:(AUIMusicSelectedModel *)selectedModel
                               player:(id<AUIVideoPlayProtocol>)player;
@end

NS_ASSUME_NONNULL_END
