//
//  AUIMusicPicker.h
//  AlivcUgsvDemo
//
//  Created by coder.pi on 2022/6/8.
//

#import "AVBaseControllPanel.h"
#import "AUIVideoPlayProtocol.h"
#import "AUIMusicModel.h"

NS_ASSUME_NONNULL_BEGIN

@class AUIMusicPicker;
typedef void(^OnMusicSelectedChanged)(AUIMusicSelectedModel * _Nullable model);
typedef void(^OnMusicPickerShowChanged)(BOOL isShow);
typedef void(^OnMusicPickerMenu)(AUIMusicPicker *picker);

@interface AUIMusicPicker : AVBaseControllPanel
@property (nonatomic, strong, nullable) id<AUIVideoPlayProtocol> player;
@property (nonatomic, readonly) NSTimeInterval limitDuration;
@property (nonatomic, readonly, nullable) AUIMusicSelectedModel *currentSelected;
@property (nonatomic, copy, nullable) OnMusicSelectedChanged onSelectedChanged;
@property (nonatomic, copy, nullable) OnMusicPickerMenu onMenuClicked;

+ (AUIMusicPicker *)present:(UIView *)present
              selectedModel:(AUIMusicSelectedModel * _Nullable)selectedModel
              limitDuration:(NSTimeInterval)limitDuration
               showCropView:(BOOL)showCropView
           onSelectedChange:(OnMusicSelectedChanged _Nullable)onSelectedChanged
              onShowChanged:(OnMusicPickerShowChanged _Nullable)onShowChanged;

@end

NS_ASSUME_NONNULL_END
