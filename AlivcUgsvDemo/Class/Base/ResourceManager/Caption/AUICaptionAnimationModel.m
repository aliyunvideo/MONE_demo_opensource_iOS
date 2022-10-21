//
//  AUICaptionAnimationModel.m
//  AlivcUgsvDemo
//
//  Created by mengyehao on 2022/6/23.
//

#import "AUICaptionAnimationModel.h"

@implementation AUICaptionAnimationModel

- (instancetype)initWithActionType:(TextActionType)type
{
    self = [super init];
    if (self) {
        _actionType = type;
        self.name = [self nameWithType:type];
    }
    return self;
}

- (BOOL)isEmpty
{
    return self.actionType <= TextActionTypeClear;
}

- (NSString *)iconPath {
    NSString *iconPath = [NSString stringWithFormat:@"Editor/ic_caption_animation_%02zd", self.actionType];
    return iconPath;
}

- (NSString *)nameWithType:(TextActionType)type
{
    NSString *name = @"";
    switch (type) {
        case TextActionTypeNull:
            break;
        case TextActionTypeClear:
            name = @"无";
            break;
        case TextActionTypeMoveTop:
            name = @"向上移动";
            break;
        case TextActionTypeMoveDown:
            name = @"向下移动";
            break;
        case TextActionTypeMoveLeft:
            name = @"向左移动";
            break;
        case TextActionTypeMoveRight:
            name = @"向右移动";
            break;
        case TextActionTypeLinerWipe:
            name = @"线性擦除";
            break;
        case TextActionTypeFade:
            name = @"淡入淡出";
            break;
        case TextActionTypeScale:
            name = @"缩放";
            break;
        case TextActionTypePrinter:
            name = @"打字机";
            break;
        case TextActionTypeClock:
            name = @"钟摆";
            break;
        case TextActionTypeBrush:
            name = @"雨刷";
            break;
        case TextActionTypeSet_1:
            name = @"组合动画1";
            break;
        case TextActionTypeSet_2:
            name = @"组合动画2";
            break;
        case TextActionTypeWave:
            name = @"波浪";
            break;
        case TextActionTypeScrewUp:
            name = @"螺旋上升";
            break;
        case TextActionTypeHeart:
            name = @"心跳";
            break;
        case TextActionTypeCircularScan:
            name = @"圆形扫描";
            break;
        case TextActionTypeWaveIn:
            name = @"波浪弹入";
            break;
        default:
            break;
    }
    return name;
}
@end
