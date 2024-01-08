//
//  AUICaptionAnimationModel.m
//  AlivcUgsvDemo
//
//  Created by mengyehao on 2022/6/23.
//

#import "AUICaptionAnimationModel.h"
#import "AUIUgsvMacro.h"

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
            name = AUIUgsvGetString(@"无");
            break;
        case TextActionTypeMoveTop:
            name = AUIUgsvGetString(@"向上移动");
            break;
        case TextActionTypeMoveDown:
            name = AUIUgsvGetString(@"向下移动");
            break;
        case TextActionTypeMoveLeft:
            name = AUIUgsvGetString(@"向左移动");
            break;
        case TextActionTypeMoveRight:
            name = AUIUgsvGetString(@"向右移动");
            break;
        case TextActionTypeLinerWipe:
            name = AUIUgsvGetString(@"线性擦除");
            break;
        case TextActionTypeFade:
            name = AUIUgsvGetString(@"淡入淡出");
            break;
        case TextActionTypeScale:
            name = AUIUgsvGetString(@"缩放");
            break;
        case TextActionTypePrinter:
            name = AUIUgsvGetString(@"打字机");
            break;
        case TextActionTypeClock:
            name = AUIUgsvGetString(@"钟摆");
            break;
        case TextActionTypeBrush:
            name = AUIUgsvGetString(@"雨刷");
            break;
        case TextActionTypeSet_1:
            name = AUIUgsvGetString(@"组合动画1");
            break;
        case TextActionTypeSet_2:
            name = AUIUgsvGetString(@"组合动画2");
            break;
        case TextActionTypeWave:
            name = AUIUgsvGetString(@"波浪");
            break;
        case TextActionTypeScrewUp:
            name = AUIUgsvGetString(@"螺旋上升");
            break;
        case TextActionTypeHeart:
            name = AUIUgsvGetString(@"心跳");
            break;
        case TextActionTypeCircularScan:
            name = AUIUgsvGetString(@"圆形扫描");
            break;
        case TextActionTypeWaveIn:
            name = AUIUgsvGetString(@"波浪弹入");
            break;
        default:
            break;
    }
    return name;
}
@end
