//
//  AUITransitionModel.m
//  AlivcUgsvDemo
//
//  Created by mengyehao on 2022/6/23.
//

#import "AUITransitionModel.h"

@implementation AUITransitionModel

- (instancetype)initWithType:(TransitionType)type
{
    self = [super init];
    if (self) {
        _type = type;
        _name = [self nameWithType:type];
    }
    return self;
}

- (BOOL)isEmpty
{
    return self.type == TransitionTypeNull;
}

- (NSString *)nameWithType:(TransitionType)type
{
    NSString *name = @"";
    switch (type) {
        case TransitionTypeNull:
        {
            name = @"无";
        }
            break;
        case TransitionTypeMoveUp:
        {
            name = @"向上移动";
            self.iconName =@"ic_transition_up";
        }
            break;
        case TransitionTypeMoveDown:
        {
            name = @"向下移动";
            self.iconName =@"ic_transition_down";
        }
            break;
        case TransitionTypeMoveLeft:
        {
            name = @"向左移动";
            self.iconName =@"ic_transition_left";
        }
            break;
        case TransitionTypeMoveRight:
        {
            name = @"向右移动";
            self.iconName =@"ic_transition_right";
        }
            break;
        case TransitionTypeShuffer:
        {
            name = @"百叶窗";
            self.iconName =@"ic_transition_shuffer";
        }
            break;
        case TransitionTypeFade:
        {
            name = @"淡入淡出";
            self.iconName =@"ic_transition_fade";
        }
            break;
        case TransitionTypeCircle:
        {
            name = @"圆形";
            self.iconName =@"ic_transition_circle";
        }
            break;
        case TransitionTypeStar:
        {
            name = @"五角星";
            self.iconName =@"ic_transition_star";
        }
            break;
        default:
            break;
    }
    return name;
}
@end

@implementation AUITransitionHelper

+ (NSArray<AUITransitionModel *> *)dataList {
    NSMutableArray *dataList = [[NSMutableArray alloc] init];
    for (int i = TransitionTypeNull; i<= TransitionTypeStar; i++) {
        AUITransitionModel *model = [[AUITransitionModel alloc] initWithType:i];
        [dataList addObject:model];
    }
    return [dataList copy];
}

+ (TransitionType)typeWithAepObject:(AEPTransitionEffect *)aep {
    if ([aep isKindOfClass:AEPTransitionShufferEffect.class]) {
        return TransitionTypeShuffer;
    }
    if ([aep isKindOfClass:AEPTransitionStarEffect.class]) {
        return TransitionTypeStar;
    }
    if ([aep isKindOfClass:AEPTransitionCircleEffect.class]) {
        return TransitionTypeCircle;
    }
    if ([aep isKindOfClass:AEPTransitionFadeEffect.class]) {
        return TransitionTypeFade;
    }
    if (![aep isKindOfClass:AEPTransitionTranslateEffect.class]) {
        return TransitionTypeNull;
    }
    
    AEPTransitionTranslateEffect *translate = (AEPTransitionTranslateEffect *)aep;
    if ([translate isKindOfClass:AEPTransitionTranslateEffect.class]) {
        switch (translate.direction) {
            case DIRECTION_LEFT: return TransitionTypeMoveLeft;
            case DIRECTION_RIGHT: return TransitionTypeMoveRight;
            case DIRECTION_TOP: return TransitionTypeMoveUp;
            case DIRECTION_BOTTOM: return TransitionTypeMoveDown;
        }
    }
    
    return TransitionTypeNull;
}

+ (AliyunTransitionEffect *)transitionEffectWithType:(TransitionType)type {
    switch (type) {
        case TransitionTypeFade: {
            AliyunTransitionEffectFade *fade = [[AliyunTransitionEffectFade alloc] init];
            fade.overlapDuration = 1;
            return fade;
        } break;
        case TransitionTypeStar: {
            AliyunTransitionEffectPolygon *polygon = [[AliyunTransitionEffectPolygon alloc] init];
            polygon.overlapDuration = 1;
            return polygon;
        } break;
        case TransitionTypeCircle: {
            AliyunTransitionEffectCircle *circle = [[AliyunTransitionEffectCircle alloc] init];
            circle.overlapDuration = 1;
            return circle;
        } break;
        case TransitionTypeMoveUp: {
            AliyunTransitionEffectTranslate *moveUp = [[AliyunTransitionEffectTranslate alloc] init];
            moveUp.overlapDuration = 1;
            moveUp.direction = DIRECTION_TOP;
            return moveUp;
        } break;
        case TransitionTypeMoveDown: {
            AliyunTransitionEffectTranslate *moveDown = [[AliyunTransitionEffectTranslate alloc] init];
            moveDown.overlapDuration = 1;
            moveDown.direction = DIRECTION_BOTTOM;
            return moveDown;
        } break;
        case TransitionTypeMoveLeft: {
            AliyunTransitionEffectTranslate *moveLeft = [[AliyunTransitionEffectTranslate alloc] init];
            moveLeft.overlapDuration = 1;
            moveLeft.direction = DIRECTION_LEFT;
            return moveLeft;
        } break;
        case TransitionTypeMoveRight: {
            AliyunTransitionEffectTranslate *moveRight = [[AliyunTransitionEffectTranslate alloc] init];
            moveRight.overlapDuration = 1;
            moveRight.direction = DIRECTION_RIGHT;
            return moveRight;
        } break;
        case TransitionTypeShuffer: {
            AliyunTransitionEffectShuffer *shuffer = [[AliyunTransitionEffectShuffer alloc] init];
            shuffer.overlapDuration = 1;
            shuffer.lineWidth = 0.1;
            shuffer.orientation = ORIENTATION_VERTICAL;
            return shuffer;
        } break;
            
        default:
            break;
    }
    return nil;
}


@end
