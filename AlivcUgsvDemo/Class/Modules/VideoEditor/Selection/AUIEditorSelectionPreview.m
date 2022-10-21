//
//  AUIEditorSelectionPreview.m
//  AliyunVideo
//
//  Created by Vienta on 2017/3/7.
//  Copyright (C) 2010-2015 Alibaba Group Holding Limited. All rights reserved.
//

#import "AUIEditorSelectionPreview.h"
#import "AUIUgsvMacro.h"
#import "AlivcUgsvSDKHeader.h"
#import "AUIEditorActionManager.h"
#import "AUIEditorSelectionManager.h"
#import "AUICaptionControllPanel.h"
#import "AUIEditorCaptionActionItem.h"

typedef NS_ENUM(NSInteger, AUIEditorSelectionPreviewActionType) {
    AUIEditorSelectionPreviewActionTypeNone,
    AUIEditorSelectionPreviewActionTypeMove,
    AUIEditorSelectionPreviewActionTypeScaleAndRotate,
};

@interface AUIEditorSelectionPreview ()<AVTimerDelegate, UIGestureRecognizerDelegate, AUIEditorActionObserver>

@property (nonatomic, strong) UIView   *borderView;
@property (nonatomic, strong) UIImageView *closeButton;
@property (nonatomic, strong) UIImageView *scaleButton;
@property (nonatomic, strong) UIImageView *editButton;
@property (nonatomic, strong) UIImageView *captureImageView;

@property (nonatomic, assign) AUIEditorSelectionPreviewActionType gestureActionType;

@property (nonatomic, assign) CGPoint lastPoint;
@property (nonatomic, assign) CGFloat viewZoomSize;
@property (nonatomic, assign) CGFloat rotateAngle;
@property (nonatomic, assign) CGFloat originSizeRatio;
@property (nonatomic, assign) CGSize originSize;


@property (nonatomic, weak, readonly) AliyunRenderBaseController *stickerController;

@end

@implementation AUIEditorSelectionPreview

- (instancetype)initWithRenderBaseController:(AliyunRenderBaseController *)stickerController {
    self = [super init];
    if (self) {
        _stickerController = stickerController;
        _viewZoomSize = MAX(CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds));
        
        [self setupUI];
        [self updateLayout];
        
        if ([stickerController isKindOfClass:AliyunCaptionStickerController.class]) {
            [[AVTimer Shared] startTimer:1.0/60.0 withTarget:self];
        }
    }
    return self;
}

- (void)removeFromSuperview {
    [super removeFromSuperview];
    
    if ([self.stickerController isKindOfClass:[AliyunGifStickerController class]]) {
        [self.captureImageView stopAnimating];
        
        CGFloat radians = atan2f(self.transform.b, self.transform.a); //warning: 底层接口逆时针旋转为正 顺时针旋转为负
        AliyunGifSticker *gif = (AliyunGifSticker *)self.stickerController.model;
        gif.size = CGSizeMake(self.bounds.size.width - [self marginSize].width * 2, self.bounds.size.height - [self marginSize].height * 2);
        gif.center = self.center;
        CGFloat rotation = -radians;
        gif.rotation = rotation;
        [self.stickerController endEdit];
    }
}

- (CGSize)marginSize {
    return CGSizeMake(18, 10);
}

- (void)updateLayout {
    self.transform = CGAffineTransformIdentity;
    
    AliyunRenderModel *model = self.stickerController.model;
    self.av_size = CGSizeMake(model.size.width + [self marginSize].width * 2, model.size.height + [self marginSize].height * 2);
    self.center = CGPointMake(model.center.x, model.center.y);

    [self updateSubviewLayout];

    CGFloat angle = -model.rotation ;
    CGAffineTransform transfrom = CGAffineTransformMakeRotation(angle);
    self.transform = transfrom;
}

- (void)updateSubviewLayout {
    self.borderView.frame = self.bounds;
    self.closeButton.center = CGPointMake(0, 0);
    self.scaleButton.center = CGPointMake(self.av_width, self.av_height);
    self.editButton.center = CGPointMake(self.av_width, 0);
    self.captureImageView.frame = self.bounds;
}

- (void)setupUI {
    CGRect pasterRect = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    
    self.borderView = [[UIView alloc] initWithFrame:pasterRect];
    self.borderView.layer.masksToBounds = YES;
    self.borderView.layer.borderColor = [UIColor colorWithRed:239.0 / 255 green:75.0 / 255 blue:129.0 / 255 alpha:1].CGColor;
    self.borderView.layer.borderWidth = 1.5;
    self.borderView.layer.cornerRadius = 2.0;
    [self addSubview:self.borderView];

    self.closeButton = [[UIImageView alloc] init];
    self.closeButton.image = AUIUgsvEditorImage(@"ic_close");
    self.closeButton.contentMode = UIViewContentModeCenter;
    self.closeButton.bounds = CGRectMake(0, 0, 40, 40);
    self.closeButton.center = CGPointMake(0, 0);
    [self addSubview:self.closeButton];

    if ([self.stickerController isKindOfClass:AliyunCaptionStickerController.class]) {
        self.editButton = [[UIImageView alloc] init];
        self.editButton.image = AUIUgsvEditorImage(@"ic_edit");
        self.editButton.contentMode = UIViewContentModeCenter;
        self.editButton.bounds = CGRectMake(0, 0, 40, 40);
        self.editButton.center = CGPointMake(self.av_width, 0);
        [self addSubview:self.editButton];
    }
    else {
        self.captureImageView = [[UIImageView alloc] initWithFrame:pasterRect];
        [self addSubview:self.captureImageView];
        
        AliyunGifSticker *gif = (AliyunGifSticker *)self.stickerController.model;
        NSArray *frames = gif.frameItems;
        
        NSMutableArray *list = [NSMutableArray array];
        for (int idx = 0; idx < frames.count; idx++) {
                  AliyunEffectPasterFrameItem *frameItem = [frames objectAtIndex:idx];
            if (frameItem.picPath) {
                
                UIImage *image = [UIImage imageWithContentsOfFile:frameItem.picPath];
                if (image) {
                    [list addObject:image];
                }
            }
            self.captureImageView.animationDuration  = gif.originDuration;
            self.captureImageView.animationImages = list;
            [self.captureImageView startAnimating];
            [self.stickerController beginEdit];
        }
    }
    
    self.scaleButton = [[UIImageView alloc] init];
    self.scaleButton.contentMode = UIViewContentModeCenter;
    self.scaleButton.image = AUIUgsvEditorImage(@"ic_reset");
    self.scaleButton.bounds = CGRectMake(0, 0, 40, 40);
    self.scaleButton.center = CGPointMake(self.av_width, self.av_height);
    [self addSubview:self.scaleButton];
}

- (void)setActionManager:(AUIEditorActionManager *)actionManager {
    _actionManager = actionManager;
}

- (void)setSelectionManager:(AUIEditorSelectionManager *)selectionManager {
    _selectionManager = selectionManager;
}

- (void)setEnableEdit:(BOOL)enableEdit {
    _enableEdit = enableEdit;
    self.editButton.hidden = !enableEdit;
}

#pragma mark - Private Methods -

- (void)move:(CGPoint)fp to:(CGPoint)tp {
    CGPoint cp = self.center;
    CGPoint np = CGPointZero;
    np.x = tp.x - fp.x + cp.x;
    np.y = tp.y - fp.y + cp.y;
    self.center = np;
}

- (void)rotate:(CGPoint)fp to:(CGPoint)tp {
    if (self.rotateAngle == 0.0) {
        [self calculateRotateButtonAngle];
    }
    
    CGPoint cp = self.center; //center point
    CGPoint op = CGPointMake(cp.x + 600, cp.y);//offset point
    float angle = [self angleFromTriangleThreePointsAp:cp Bp:op Cp:tp];
    if (tp.y < cp.y) {
        angle = M_PI*2 - (self.rotateAngle + angle);
    }
    else {
        angle = angle - self.rotateAngle;
    }
    
    float cps = sqrtf(powf((tp.x - cp.x),2.0) + powf((tp.y - cp.y),2.0)) / self.originSizeRatio;
    float w = cps * cos(self.rotateAngle) * 2;
    float h = cps * sin(self.rotateAngle) * 2;
    float safeWidth = ((w > _viewZoomSize) ? CGRectGetWidth(self.bounds):w);
    float safeHeight = ((w > _viewZoomSize) ? CGRectGetHeight(self.bounds):h);
    if (safeHeight<20) {
        safeWidth =  20 * safeWidth / safeHeight;
        safeHeight = 20;
        
    }
    self.transform = CGAffineTransformIdentity;
    CGRect newRect = CGRectMake(0, 0, safeWidth, safeHeight);
    self.bounds = newRect;
    [self updateSubviewLayout];
        
    CGAffineTransform transfrom = CGAffineTransformMakeRotation(angle);
    self.transform = transfrom;
    CGFloat radians = atan2f(self.transform.b, self.transform.a); //warning: 底层接口逆时针旋转为正 顺时针旋转为负
    if ([self.stickerController isKindOfClass:AliyunCaptionStickerController.class]) {
        AliyunCaptionSticker *model = (AliyunCaptionSticker *)self.stickerController.model;
        if (model.size.height > 0 && !isnan(radians)) {
            CGFloat scale = MIN((newRect.size.height - [self marginSize].height * 2) /model.size.height, (newRect.size.width - [self marginSize].width * 2) /model.size.width);
            CGFloat rotation = -radians;
            model.rotation = rotation;
            model.scale = MAX(0.2, model.scale * scale);
        }
    }
}

- (void)calculateRotateButtonAngle {
    CGPoint rp = self.scaleButton.center; //rotate button center point
    CGPoint cp =  CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    CGPoint op = CGPointMake(cp.x + 100, cp.y);
    self.rotateAngle = [self angleFromTriangleThreePointsAp:cp Bp:rp Cp:op];
    
    CGFloat a1 = sqrtf(powf((rp.x - cp.x),2.0) + powf((rp.y - cp.y),2.0));
    CGPoint mp = CGPointMake(CGRectGetMaxX(self.bounds), CGRectGetMaxY(self.bounds));
    CGFloat a2 = sqrtf(powf((mp.x - cp.x),2.0) + powf((mp.y - cp.y),2.0));
    self.originSizeRatio = a1 / a2;
}

//cosA = (a^2 + c^2 - c^2) / 2ac
- (float)angleFromTriangleThreePointsAp:(CGPoint)Ap Bp:(CGPoint)Bp Cp:(CGPoint)Cp {
    float BC = powf((Cp.x - Bp.x),2.0) + powf((Cp.y - Bp.y),2.0);
    float AC = powf((Cp.x - Ap.x),2.0) + powf((Cp.y - Ap.y),2.0);
    float AB = powf((Bp.x - Ap.x),2.0) + powf((Bp.y - Ap.y),2.0);
    
    return acosf((AC + AB - BC)/(2 * sqrtf(AC) * sqrtf(AB)));
}

#pragma mark - Public Methods -

//
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if (CGRectContainsPoint(self.bounds, point)){
        return YES;
    }
    else {
        if (CGRectContainsPoint(self.closeButton.frame, point) ){
            return YES;
        }

        if (CGRectContainsPoint(self.scaleButton.frame, point) ){
            return YES;
        }

        if (CGRectContainsPoint(self.editButton.frame, point) ){
            return YES;
        }
    }
    return NO;
}

- (BOOL)touchPoint:(CGPoint)point fromView:(UIView *)view {
    CGPoint localPoint = [self convertPoint:point fromView:view];
    BOOL isPointInside = [self pointInside:localPoint withEvent:nil];
    
    CGPoint closePoint = [self.closeButton convertPoint:localPoint fromView:self];
    CGPoint scalePoint = [self.scaleButton convertPoint:localPoint fromView:self];
    CGPoint editPoint = [self.editButton convertPoint:localPoint fromView:self];

    BOOL pointInCloseButton = [self.closeButton pointInside:closePoint withEvent:nil];
    BOOL pointInScaleButton = [self.scaleButton pointInside:scalePoint withEvent:nil];
    BOOL pointInEditButton = [self.editButton pointInside:editPoint withEvent:nil];
    
    self.gestureActionType =  AUIEditorSelectionPreviewActionTypeNone;

    if (pointInCloseButton) {
        isPointInside = YES;
        [self onCloseButtonClick];
    }
    else if (pointInScaleButton) {
        isPointInside = YES;
        self.gestureActionType = AUIEditorSelectionPreviewActionTypeScaleAndRotate;
        
    }
    else if (pointInEditButton) {
        isPointInside = YES;
        [self onEditButtonClick];
        
    }
    else {
        self.gestureActionType = isPointInside ? AUIEditorSelectionPreviewActionTypeMove : AUIEditorSelectionPreviewActionTypeNone;
    }
        
    return isPointInside;
}


- (void)onCloseButtonClick
{
    if ([self.stickerController isKindOfClass:AliyunCaptionStickerController.class]) {
        AUIEditorCaptionRemoveActionItem *item = [AUIEditorCaptionRemoveActionItem new];
        item.input = self.selectionManager.selectionObject.aepObject;
        [self.actionManager doAction:item];
    } else {
        AUIEditorStickerRemoveActionItem *item = [AUIEditorStickerRemoveActionItem new];
        item.input = self.selectionManager.selectionObject.aepObject;
        [self.actionManager doAction:item];
    }

}

- (void)onEditButtonClick {
    if (self.editButton.hidden) {
        return;
    }
    if (self.onEditBlock) {
        self.onEditBlock();
    }
}

- (void)gestureActionFromPoint:(CGPoint)fromPoint to:(CGPoint)toPoint {
    if (CGPointEqualToPoint(fromPoint, toPoint)) {
        return;
    }
    if (self.gestureActionType == AUIEditorSelectionPreviewActionTypeMove) {
        [self move:fromPoint to:toPoint];
    }
    else if (self.gestureActionType == AUIEditorSelectionPreviewActionTypeScaleAndRotate) {
        [self rotate:fromPoint to:fromPoint];
    }
}
    
#pragma mark - AVTimerDelegate

- (void)onAVTimerStepWithDuration:(NSTimeInterval)duration settingInterval:(NSTimeInterval)interval {
    if ([self.stickerController isKindOfClass:AliyunCaptionStickerController.class]) {
        AliyunRenderModel *render = self.stickerController.model;
        render.center = self.center;
        self.bounds = CGRectMake(0, 0, render.size.width + 36, render.size.height + 20);
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
        CGPoint preLocation = [[touches anyObject] previousLocationInView:self.superview];
    [self touchPoint:preLocation fromView:self.superview];
    NSLog(@"%s",__func__);
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
        UITouch *touch = (UITouch *)[touches anyObject];
        CGPoint fp = [touch previousLocationInView:self.superview];
        CGPoint tp = [touch locationInView:self.superview];
    self.lastPoint = fp;
    [self gestureActionFromPoint:fp to:tp];
    self.lastPoint = tp;

    NSLog(@"%s",__func__);
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    NSLog(@"%s",__func__);
}

@end


