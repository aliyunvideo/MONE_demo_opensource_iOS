//
//  AUICaptionAnimationModel.h
//  AlivcUgsvDemo
//
//  Created by mengyehao on 2022/6/23.
//

#import "AUIFilterModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger,TextActionType){
    TextActionTypeNull = -1,
    TextActionTypeClear,
    TextActionTypeMoveTop,
    TextActionTypeMoveDown,
    TextActionTypeMoveLeft,
    TextActionTypeMoveRight,
    TextActionTypeLinerWipe,
    TextActionTypeFade,
    TextActionTypeScale,
    TextActionTypePrinter,       //打字机
    TextActionTypeClock,        //钟摆
    TextActionTypeBrush,        //雨刷
    TextActionTypeWave,        //波浪
    TextActionTypeScrewUp,     //螺旋上升
    TextActionTypeHeart,       //心跳
    TextActionTypeCircularScan,//圆形扫描
    TextActionTypeWaveIn,      //波浪弹入
    TextActionTypeSet_1,       //组合动画1
    TextActionTypeSet_2,       //组合动画2
};


@interface AUICaptionAnimationModel : AUIFilterModel

@property (nonatomic, assign) TextActionType actionType;

- (instancetype)initWithActionType:(TextActionType)type;

@end

NS_ASSUME_NONNULL_END
