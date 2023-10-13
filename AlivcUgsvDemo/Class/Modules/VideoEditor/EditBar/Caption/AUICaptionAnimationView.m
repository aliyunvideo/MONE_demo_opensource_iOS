//
//  AUICaptionAnimationView.m
//  AlivcUgsvDemo
//
//  Created by mengyehao on 2022/5/31.
//

#import "AUICaptionAnimationView.h"
#import "UIView+AVHelper.h"
#import "AUIFoundation.h"
#import "AUIUgsvMacro.h"
#import "AlivcUgsvSDKHeader.h"
#import "AUICaptionAnimationModel.h"

@interface AUICaptionAnimationView()<UICollectionViewDelegate>

@end

@implementation AUICaptionAnimationView

- (void)fetchData
{
    NSMutableArray *tempList = [NSMutableArray array];
    for (int i = TextActionTypeClear; i<= TextActionTypeWaveIn; i++) {
        AUICaptionAnimationModel *model = [[AUICaptionAnimationModel alloc] initWithActionType:i];
        [tempList addObject:model];
    }
    [self updateDataSource:tempList];
}


- (void)setStickerController:(AliyunCaptionStickerController *)stickerController
{
    _stickerController = stickerController;
    
    AliyunCaptionSticker *model = stickerController.model;
    
    int lastAnimationType = 0;
    
    if (model.getAllActionList.count) {
        NSArray<AliyunAction *> *actions = model.getAllActionList;
        lastAnimationType = [actions.lastObject sourceId].intValue;
    }
    
    if (model.getPartActionList.count) {
        lastAnimationType = [model.getPartActionList.lastObject.action sourceId].intValue;
    }
    
    [self selectWithIndex:lastAnimationType];
}

- (void)didSeletedAnimateWithType:(TextActionType)type
{
    
    AliyunRenderModel *model = self.stickerController.model;
    id<AliyunFrameAnimationProtocol> vc = self.stickerController;
    
    //1.移除普通动画
    if ([model isKindOfClass:[AliyunSticker class]]) {
        AliyunSticker *sticker = model;
        NSArray *tempList = [sticker getAllActionList];
        for (AliyunAction *action in tempList) {
            [vc removeFrameAnimation:action];
        }
    }
    
    //2.移除逐字动画
    if ([model isKindOfClass:[AliyunCaptionSticker class]]) {
        
        [[(AliyunCaptionSticker *)model getPartActionList] enumerateObjectsUsingBlock:^(AliyunPartAction * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            id<AliyunPartFrameAnimationProtocol> animaVC = vc;
            [animaVC removePartFrameAnimation:obj];
        }];
    }
    

    NSString *sourceId = [NSString stringWithFormat:@"%ld",type];
    
    switch (type) {
        case TextActionTypeClear: {
        } break;
        case TextActionTypeMoveLeft: {
            AliyunMoveAction *moveAction = [[AliyunMoveAction alloc] init];
            moveAction.startTime = [model startTime];
            moveAction.duration = 1;
            moveAction.fromePoint = CGPointMake(model.center.x + 200,
                                                model.center.y);
            moveAction.toPoint = model.center;
            moveAction.sourceId = sourceId;
            [vc addFrameAnimation:moveAction];
        } break;
        case TextActionTypeMoveRight: {
            AliyunMoveAction *moveAction = [[AliyunMoveAction alloc] init];
            moveAction.startTime = [model startTime];
            moveAction.duration = 1;
            moveAction.fromePoint = CGPointMake(model.size.width * -1,
                                                model.center.y);
            moveAction.toPoint = model.center;
            moveAction.sourceId = sourceId;
            [vc addFrameAnimation:moveAction];
        } break;
        case TextActionTypeMoveTop: {
            AliyunMoveAction *moveAction = [[AliyunMoveAction alloc] init];
            moveAction.startTime = [model startTime];
            moveAction.duration = 1;
            moveAction.fromePoint = CGPointMake(model.center.x,
                                                model.center.y + 300);
            moveAction.toPoint = model.center;
            moveAction.sourceId = sourceId;

            [vc addFrameAnimation:moveAction];
        } break;
        case TextActionTypeMoveDown: {
            AliyunMoveAction *moveAction = [[AliyunMoveAction alloc] init];
            moveAction.startTime = [model startTime];
            moveAction.duration = 1;
            moveAction.fromePoint = CGPointMake(model.center.x,
                                                model.size.height * -1);
            moveAction.toPoint = model.center;
            moveAction.sourceId = sourceId;
            [vc addFrameAnimation:moveAction];
        } break;
        case TextActionTypeLinerWipe: {
            AliyunWipeAction *wipe = [[AliyunWipeAction alloc] init];
            wipe.startTime = [model startTime];
            wipe.duration = 1;
            wipe.direction = AliWipeActionDirection_LeftToRight;
            wipe.wipeMode = AliWipeActionMode_Appear;
            wipe.sourceId = sourceId;

            [vc addFrameAnimation:wipe];
        } break;
        case TextActionTypeFade: {
            AliyunAlphaAction *alphaAction_in = [[AliyunAlphaAction alloc] init]; //淡入
            alphaAction_in.startTime = [model startTime];
            alphaAction_in.duration = 0.5;
            alphaAction_in.fromAlpha = 0.2f;
            alphaAction_in.toAlpha = 1.0f;
            
            AliyunAlphaAction *alphaAction_out = [[AliyunAlphaAction alloc] init]; //淡出
            alphaAction_out.startTime = model.startTime +1;
            alphaAction_out.duration = 0.5;
            alphaAction_out.fromAlpha = 1.0f;
            alphaAction_out.toAlpha = 0.2f;
            //            [effectPaster runAction:alphaAction_in];
            //            [effectPaster runAction:alphaAction_out];
            
            alphaAction_in.sourceId = sourceId;
            alphaAction_out.sourceId = sourceId;
            [vc addFrameAnimation:alphaAction_in];
            [vc addFrameAnimation:alphaAction_out];


            
        } break;
        case TextActionTypeScale: {
            AliyunScaleAction *scaleAction = [[AliyunScaleAction alloc] init];
            scaleAction.startTime =model.startTime;
            scaleAction.duration = 1;
            scaleAction.fromScale = 1.0;
            scaleAction.toScale = 0.25;
            scaleAction.sourceId = sourceId;
            [vc addFrameAnimation:scaleAction];
        } break;
            
        case TextActionTypePrinter:
        {
            float startTime = model.startTime;
            float duration = 2;
            AliyunAlphaAction *action = [[AliyunAlphaAction alloc] init];
            action.startTime = startTime;
            action.duration = duration;
            action.fillBefore = YES;
            action.animationConfig = @"0:0;0.7:1;";
            action.sourceId = sourceId;

            AliyunPartAction *partAimation = [[AliyunPartAction alloc] initWithAction:action];
            if ([vc conformsToProtocol:@protocol(AliyunPartFrameAnimationProtocol)]) {
                id<AliyunPartFrameAnimationProtocol> animaVC = vc;
                [animaVC addPartFrameAnimation:partAimation];
            }

        }
            break;
        case TextActionTypeClock:
        {
            
            float startTime = model.startTime;
            float duration = 4;
            
            AliyunSetAction *action = [[AliyunSetAction alloc]init];
            action.subSetMode = AliyunSetActionPlayModeIndependent;
        
          //首选向左转 30度
          AliyunRotateByAction *action1 = [[AliyunRotateByAction alloc] init];
          action1.fromDegree = 0;
          action1.rotateDegree = -M_PI/6.0;
         action1.normalizedCenter = CGPointMake(0, 1);
            
          action1.startTime = startTime;
         action1.duration = duration/6;
            
            AliyunRotateByAction *action2 = [[AliyunRotateByAction alloc] init];
            action2.fromDegree = -M_PI/6.0;
            action2.rotateDegree = M_PI/3.0;
            action2.normalizedCenter = CGPointMake(0, 1);
            action2.repeatMode = 2;
            
            action2.startTime = startTime + action1.duration;
            action2.duration = duration * 2 / 6.0;

  
            action.sourceId = sourceId;
            action.subList = @[action1, action2];
            [vc addFrameAnimation:action];

        }
            break;
        case TextActionTypeBrush:
        {
            
            float startTime = model.startTime;
            float duration = 4;
            
            AliyunSetAction *action = [AliyunSetAction new];
            action.subSetMode = AliyunSetActionPlayModeIndependent;

            //雨刷使用RotateTo的实现
            AliyunRotateToAction *lActionRotateTo1 = [AliyunRotateToAction new];
            //首选向右转 30度
            lActionRotateTo1.fromDegree = 0;
            lActionRotateTo1.toDegree = M_PI/6.0;
            lActionRotateTo1.normalizedCenter = CGPointMake(0, -1);
            lActionRotateTo1.startTime = startTime;
            lActionRotateTo1.duration = duration/6.0;
            //再向左转60，并来回转动
            AliyunRotateToAction * lActionRotateTo2 = [AliyunRotateToAction new];
            lActionRotateTo2.fromDegree = M_PI/6.0;
            lActionRotateTo2.toDegree = -M_PI/6.0;
            lActionRotateTo2.normalizedCenter = CGPointMake(0, -1);

            lActionRotateTo2.repeatMode = AliyunActionRepeatModeReverse;
            lActionRotateTo2.startTime = startTime + lActionRotateTo1.duration  ;
            lActionRotateTo2.duration = duration/3;

            action.sourceId = sourceId;
            action.subList = @[lActionRotateTo1,lActionRotateTo2];
            [vc addFrameAnimation:action];


        }
            break;
        case TextActionTypeSet_1:
        {
            float startTime = model.startTime;
            float duration = 4;
            
            AliyunSetAction *action = [AliyunSetAction new];
            action.subSetMode = AliyunSetActionPlayModeTogether;
      
            AliyunAlphaAction *lActionFade1 = [AliyunAlphaAction new];
            lActionFade1.fromAlpha  = 0.1;
            lActionFade1.toAlpha  = 1;
            lActionFade1.startTime = startTime;
            lActionFade1.duration = duration;
            lActionFade1.fillBefore = YES;
            
            AliyunAlphaAction *lActionFade2 = [AliyunAlphaAction new];
            lActionFade2.fromAlpha  = 1;
            lActionFade2.toAlpha  =0.1;
            lActionFade2.startOffset = duration/4.0 * 3;

            lActionFade2.duration = duration/4.0;

     

            AliyunRotateByAction *lActionRotateBy1 = [AliyunRotateByAction new];
            lActionRotateBy1.fromDegree = 0;
            lActionRotateBy1.rotateDegree = M_PI * 2.0;
            lActionRotateBy1.duration = duration/2.0;
            lActionRotateBy1.fillBefore = YES;
            lActionRotateBy1.fillAfter = YES;

            AliyunScaleAction *lActionScale1 = [AliyunScaleAction new];
            lActionScale1.fromScale = 0.25;
            lActionScale1.toScale = 1.0;
            lActionScale1.duration = duration/2.0;
            lActionScale1.fillBefore = YES;
            lActionScale1.fillAfter = YES;
            action.sourceId = sourceId;
            action.subList = @[lActionFade1,lActionFade2,lActionRotateBy1,lActionScale1];
            action.startTime = startTime;
            action.duration = duration;
            [vc addFrameAnimation:action];
        }
            break;
        case TextActionTypeSet_2:
        {
            float startTime = model.startTime;
            float duration = 4;
            
            AliyunSetAction *action = [AliyunSetAction new];
            action.subSetMode = 1;

            AliyunAlphaAction *lActionFade1 = [AliyunAlphaAction new];
            lActionFade1.fromAlpha  = 1;
            lActionFade1.toAlpha  =1;
            lActionFade1.startTime = 0.f;
            lActionFade1.duration = duration/3.0;
            lActionFade1.fillAfter = YES;
            

            
            
            AliyunRotateByAction *lActionRotateBy1 = [AliyunRotateByAction new];
            lActionRotateBy1.fromDegree = 0;
            lActionRotateBy1.rotateDegree = M_PI * 2.0;
            lActionRotateBy1.duration = duration/2.0;
            lActionRotateBy1.fillAfter = YES;


            AliyunScaleAction *lActionScale1 = [AliyunScaleAction new];
            lActionScale1.fromScale = 0.f;
            lActionScale1.toScale = 1.0;
            lActionScale1.startTime = 0.f;
            lActionScale1.duration = duration/2.0;
            lActionScale1.fillAfter = YES;

            action.subList = @[lActionFade1,lActionRotateBy1,lActionScale1];
            action.startTime = startTime;
            action.duration = duration;
            action.sourceId = sourceId;
            [vc addFrameAnimation:action];

        }
            break;
        case TextActionTypeWave:
        {
        
            float startTime = model.startTime;
            float duration = 4;
            
            AliyunCustomAction *custom = [AliyunCustomAction new];
            
            
            NSString *dirPath =  [[NSBundle mainBundle] pathForResource:@"AnimationFrag.bundle" ofType:nil];
            
            NSString *vertexPath = [dirPath stringByAppendingPathComponent:@"wave.vert"];
            
            NSString *vertexFunc = [NSString stringWithContentsOfFile:vertexPath encoding:kCFStringEncodingUTF8 error:nil];
            
            
            NSString *fragmentPath =  [dirPath stringByAppendingPathComponent:@"wave.frag"];
            NSString *fragmentFunc = [NSString stringWithContentsOfFile:fragmentPath encoding:kCFStringEncodingUTF8 error:nil];
            
            
            custom.vertexShader = vertexFunc;
            custom.fragmentShader = fragmentFunc;
            custom.startTime = startTime;
            custom.duration = duration;
            custom.sourceId = sourceId;
            [vc addFrameAnimation:custom];

        }
            break;
        case TextActionTypeScrewUp:
        {
            float startTime = model.startTime;
            float duration = 3;
            
            AliyunSetAction *action = [AliyunSetAction new];
            action.subSetMode = 0;
            
            AliyunActionPartParam *lPartParam = [AliyunActionPartParam new];
            lPartParam.partMode = 0;
            lPartParam.partOverlayRadio = 0.7;
            
            AliyunPartAction *partAimation = [[AliyunPartAction alloc] initWithAction:action];
            partAimation.partParam = lPartParam;
            
            AliyunAlphaAction *lActionFade1 = [AliyunAlphaAction new];
            lActionFade1.fromAlpha  = 0.1;
            lActionFade1.toAlpha  = 1;
            lActionFade1.duration = duration/4.0;
            lActionFade1.fillBefore = YES;
            lActionFade1.fillAfter = YES;


            AliyunRotateByAction *lActionRotateBy1 = [AliyunRotateByAction new];
            lActionRotateBy1.fromDegree = 0;
            lActionRotateBy1.rotateDegree = M_PI * 2.0;
            lActionRotateBy1.duration = duration/2.0;
            lActionRotateBy1.fillBefore = YES;
            lActionRotateBy1.fillAfter = YES;
            lActionRotateBy1.repeatMode = AliyunActionRepeatModeNormal;


            AliyunMoveAction *lActionTranslate = [[AliyunMoveAction alloc]init];
            lActionTranslate.translateType = 1;
            lActionTranslate.startTime = 0;
            lActionTranslate.duration = duration;
            lActionTranslate.fromePoint = CGPointMake(model.center.x, model.center.y + 300);
            lActionTranslate.toPoint = CGPointMake(model.center.x, model.center.y);
            lActionTranslate.fillBefore = YES;


            action.fillBefore = YES;
            action.duration = duration * 3 / 4.0;
            action.startTime = startTime;
            action.subList = @[lActionFade1,lActionRotateBy1,lActionTranslate];
            
            action.sourceId = sourceId;
            if ([vc conformsToProtocol:@protocol(AliyunPartFrameAnimationProtocol)]) {
                id<AliyunPartFrameAnimationProtocol> animaVC = vc;
                [animaVC addPartFrameAnimation:partAimation];
            }

        }
            break;
        case TextActionTypeHeart:
        {
            AliyunScaleAction *lActionScale1 = [AliyunScaleAction new];

            lActionScale1.animationConfig =
            
           @"0:1.0,1.0;0.06:0.92,0.92;0.12:1.0252,1.0252;0.18:1.1775,1.1775;0.24:1.3116,1.3116;0.3:1.4128,1.4128;0.36:1.4761,1.4761;0.42:1.5,1.5;0.48:1.5,1.5;0.54:1.4727,1.4727;0.6:1.4089,1.4089;0.66:1.3093,1.3093;0.72:1.1779,1.1779;0.78:1.0283,1.0283;0.9:0.92,0.92;1.0:1.0,1.0;";


            
            lActionScale1.startTime = model.startTime;
            lActionScale1.duration = 2;
            lActionScale1.repeatMode = AliyunActionRepeatModeNormal;
            lActionScale1.sourceId = sourceId;
            [vc addFrameAnimation:lActionScale1];
        }
            break;
        case TextActionTypeCircularScan:
        {
            float startTime = model.startTime;
            float duration = 4;
            
            AliyunCustomAction *custom = [AliyunCustomAction new];
            
            NSString *dirPath =  [[NSBundle mainBundle] pathForResource:@"AnimationFrag.bundle" ofType:nil];
            
            NSString *vertexPath = [dirPath stringByAppendingPathComponent:@"round_scan.vert"];
            

            NSString *vertexFunc = [NSString stringWithContentsOfFile:vertexPath encoding:kCFStringEncodingUTF8 error:nil];
            
            
            NSString *fragmentPath = [dirPath stringByAppendingPathComponent:@"round_scan.frag"];
            NSString *fragmentFunc = [NSString stringWithContentsOfFile:fragmentPath encoding:kCFStringEncodingUTF8 error:nil];
            
            
            custom.vertexShader = vertexFunc;
            custom.fragmentShader = fragmentFunc;
            custom.startTime = startTime;
            custom.duration = duration;
            custom.sourceId = sourceId;

            [vc addFrameAnimation:custom];

        }
            break;
        case TextActionTypeWaveIn:
        {
            float startTime = model.startTime;
            float duration = model.duration;
            
            AliyunSetAction *action = [AliyunSetAction new];
            action.subSetMode = 0;
            
            
            AliyunActionPartParam *lPartParam = [AliyunActionPartParam new];
            lPartParam.partMode = AliyunActionPartParamModeSequence;
            lPartParam.partOverlayRadio = 0.6;
            
            AliyunPartAction *partAimation = [[AliyunPartAction alloc] initWithAction:action];
            partAimation.partParam = lPartParam;

            
            AliyunMoveAction *lActionTranslate = [[AliyunMoveAction alloc]init];
            lActionTranslate.translateType = 1;
            lActionTranslate.startTime = 0;
            lActionTranslate.duration = duration/2;
            lActionTranslate.fromePoint = CGPointMake(model.center.x, model.center.y);
            lActionTranslate.toPoint = CGPointMake(model.center.x, model.center.y + 300);
            lActionTranslate.fillBefore = YES;
            

            AliyunMoveAction *lActionTranslate2 = [[AliyunMoveAction alloc]init];
            lActionTranslate2.translateType = 1;
            lActionTranslate2.startOffset = duration / 2.0f;
            lActionTranslate2.duration = duration/2;
            lActionTranslate2.fromePoint = CGPointMake(model.center.x, model.center.y + 300);
            lActionTranslate2.toPoint = CGPointMake(model.center.x, model.center.y);
            lActionTranslate2.fillAfter = YES;
    
            AliyunAlphaAction *lActionFade1 = [AliyunAlphaAction new];
            lActionFade1.fromAlpha  = 0.0;
            lActionFade1.toAlpha  = 1;
            lActionFade1.startTime = 0.f;
            lActionFade1.duration = duration/4.0;
            lActionFade1.fillBefore = YES;


            action.subList = @[lActionTranslate,lActionTranslate2,lActionFade1];
            action.fillBefore = YES;
            action.fillAfter = YES;
            
            action.startTime = startTime;
            action.duration = duration;
            
            action.sourceId = sourceId;

            if ([vc conformsToProtocol:@protocol(AliyunPartFrameAnimationProtocol)]) {
                id<AliyunPartFrameAnimationProtocol> animaVC = vc;
                [animaVC addPartFrameAnimation:partAimation];
            }
        }
            break;
            
            
        default:
            break;
    }

}


@end
