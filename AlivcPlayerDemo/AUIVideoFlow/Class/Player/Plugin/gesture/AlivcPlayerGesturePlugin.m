//
//  AlivcPlayerGesturePlugin.m
//  ApsaraVideo
//
//  Created by mengyehao on 2021/7/14.
//

#import "AlivcPlayerGesturePlugin.h"
#import "AlivcPlayerManager.h"
#import "AUIPlayerZFVolumeBrightnessView.h"
#import "AUIPlayerSpeedSwipeView.h"

@interface AlivcPlayerGesturePlugin()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView *gestureView;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGesture;
@property (nonatomic, assign) BOOL isVerticalGesture;
@property (nonatomic, assign) BOOL isLeft;
@property (nonatomic, strong) AUIPlayerSpeedSwipeView *speedSwiper;
@property (nonatomic, assign) CGFloat currentSpeed;

@property (nonatomic, strong) AUIPlayerZFVolumeBrightnessView *volumeBrightnessView;

@end

@implementation AlivcPlayerGesturePlugin


- (NSInteger)level
{
    return 2;
}

- (UIView *)gestureView
{
    if (!_gestureView) {
        _gestureView = [[UIView alloc] init];
        _gestureView.bounds = self.containerView.bounds;
        _gestureView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [_gestureView addGestureRecognizer:self.tapGesture];
        [_gestureView addGestureRecognizer:self.panGesture];
        [_gestureView addGestureRecognizer:self.longPressGesture];
        self.panGesture.delegate = self;
        [self.tapGesture shouldRequireFailureOfGestureRecognizer:self.panGesture];
        self.panGesture.enabled = [AlivcPlayerManager manager].playScene != 0;
        
        [self.tapGesture shouldRequireFailureOfGestureRecognizer:self.longPressGesture];
    }
    return _gestureView;
}

- (void)onInstall
{
    [super onInstall];
    [self.containerView addSubview:self.gestureView];
 
}

- (NSArray<NSNumber *> *)eventList
{
    return  @[@(AlivcPlayerEventCenterPlaySceneChanged)];
}

- (void)onReceivedEvent:(AlivcPlayerEventCenterType)eventType userInfo:(NSDictionary *)userInfo
{
    if (eventType == AlivcPlayerEventCenterPlaySceneChanged) {
        self.panGesture.enabled = [AlivcPlayerManager manager].playScene != 0;
    }
}

- (UITapGestureRecognizer *)tapGesture
{
    if (!_tapGesture) {
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSingeleTap:)];
    }
    return _tapGesture;
}

- (UIPanGestureRecognizer *)panGesture
{
    if (!_panGesture) {
        _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPan:)];
    }
    return _panGesture;
}

- (UILongPressGestureRecognizer *)longPressGesture {
    if (!_longPressGesture) {
        _longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPress:)];
    }
    return _longPressGesture;
}

- (void)onSingeleTap:(UITapGestureRecognizer *)sender
{
    [[AlivcPlayerManager manager] setControlToolHidden:![AlivcPlayerManager manager].controlToolHidden];
}

- (void)onPan:(UIPanGestureRecognizer *)sender
{
    
    if ([AlivcPlayerManager manager].playScene == 0) {
        return;
    }

    if (sender.state == UIGestureRecognizerStateBegan) {
        CGPoint velocity = [sender velocityInView:self.containerView];
        BOOL isVerticalGesture = fabs(velocity.y) > fabs(velocity.x);
        
        self.isLeft = [sender locationInView:self.containerView].x < self.containerView.bounds.size.width/2;
        self.isVerticalGesture = isVerticalGesture;
        
        if (isVerticalGesture) {
            [self.containerView addSubview:self.volumeBrightnessView];
            self.volumeBrightnessView.frame = CGRectMake((self.containerView.bounds.size.width - 160)/2, 88, 160, 24);
            self.volumeBrightnessView.hidden = NO;
        }
        
        // self.currentSpeed = [AlivcPlayerManager manager].rate;

    } else if (sender.state == UIGestureRecognizerStateChanged) {
        
        CGPoint velocity = [sender velocityInView:self.containerView];
        
        CGPoint tranPoint = [sender translationInView:self.containerView];
        
        if (self.isVerticalGesture) {
            if (self.isLeft) {
                CGFloat brightness = [UIScreen mainScreen].brightness;
                brightness += (-velocity.y/10000);
                [self.volumeBrightnessView updateProgress:brightness withVolumeBrightnessType:ZFVolumeBrightnessTypeumeBrightness];
                [UIScreen mainScreen].brightness = brightness;
                
            } else {
                [self.volumeBrightnessView addSystemVolumeView];
                CGFloat volume = [AlivcPlayerManager manager].volume/2.0;
                volume += (-velocity.y/10000);
                [self.volumeBrightnessView updateProgress:volume withVolumeBrightnessType:ZFVolumeBrightnessTypeVolume];
                [AlivcPlayerManager manager].volume = volume *2;

            }
        } else {
            if ([AlivcPlayerManager manager].duration) {
                BOOL moveProgress = (velocity.y >= self.containerView.av_height - 42);
                if (moveProgress) {
                    CGFloat gap = (velocity.x/40000);
                    float time = [AlivcPlayerManager manager].currentPosition+ (float)[AlivcPlayerManager manager].duration *  gap;
                    [[AlivcPlayerManager manager]dispatchEvent:AlivcPlayerEventCenterTypePlayerPlayProgress userInfo:@{
                        @"position":@(time),
                        @"duration":@([AlivcPlayerManager manager].duration)
                    }];
                    [[AlivcPlayerManager manager] seekToTimeProgress:time/[AlivcPlayerManager manager].duration seekMode:AVP_SEEKMODE_INACCURATE];
                } else {
                    
                    // [self showSpeedSwiperAtDirection:tranPoint.x > 0 isChange:YES];
                }
            }
        }
       
    } else if (sender.state == UIGestureRecognizerStateEnded) {
//        [AlivcPlayerManager manager].rate = [self getCurrentRate];
//        [self hideSpeedSwiper];
//        NSString *text = [NSString stringWithFormat:@"已切换为 %.2f 倍速度播放",[AlivcPlayerManager manager].rate];
//        [AVToastView show:text view:self.containerView position:AVToastViewPositionMid];
    }
}

- (void)onLongPress:(UILongPressGestureRecognizer *)sender {
    if ([AlivcPlayerManager manager].playScene == 0) {
        return;
    }
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        self.currentSpeed = [AlivcPlayerManager manager].rate;

    } else if (sender.state == UIGestureRecognizerStateChanged) {
        [AlivcPlayerManager manager].rate = 2.0;
        [self showSpeedSwiperAtDirection:YES isChange:YES];
       
    } else if (sender.state == UIGestureRecognizerStateEnded) {
        [self hideSpeedSwiper];
        [AlivcPlayerManager manager].rate = self.currentSpeed;
    }
}

- (void)showSpeedSwiperAtDirection:(BOOL)right isChange:(BOOL)isChange {
    [self hideSpeedSwiper];
    self.speedSwiper.frame = CGRectMake((self.containerView.av_width - 130) / 2.0, 36, 130, 36);
    [self.containerView addSubview:self.speedSwiper];
    
//    if (isChange) {
//        if (right) {
//            self.currentSpeed += 0.01;
//            if (self.currentSpeed > 2.0) {
//                self.currentSpeed = 2.0;
//            }
//        } else {
//            self.currentSpeed -= 0.01;
//            if (self.currentSpeed < 0) {
//                self.currentSpeed = 0;
//            }
//        }
//    }
//
//    NSString *speedStr = @"";
//    if (speed == 0) {
//        speedStr = @"0X";
//    }else if (speed <= 0.25){
//        speedStr = @"0.25X";
//    }else if (speed <= 0.5){
//        speedStr = @"0.5X";
//    }else if (speed <= 1){
//        speedStr = @"1X";
//    }else if (speed <= 1.25){
//        speedStr = @"1.25X";
//    }else if (speed <= 1.5){
//        speedStr = @"1.5X";
//    }else if (speed <= 2){
//        speedStr = @"2X";
//    }
    [self.speedSwiper updateDirection:YES speed:@"2X"];
}

//- (float)getCurrentRate {
//    if (self.currentSpeed >= 0 && self.currentSpeed < 0.25) {
//        return 0;
//    }else if (self.currentSpeed >= 0.25 && self.currentSpeed < 0.5){
//        return 0.25;
//    }else if (self.currentSpeed >= 0.5 && self.currentSpeed < 1){
//        return 0.5;
//    }else if (self.currentSpeed >= 1 && self.currentSpeed < 1.25){
//        return 1;
//    }else if (self.currentSpeed >= 1.25 && self.currentSpeed < 1.5){
//        return 1.25;
//    }else if (self.currentSpeed >= 1.5 && self.currentSpeed < 2){
//        return 1.5;
//    }else if (self.currentSpeed == 2){
//        return 2;
//    } else {
//        return 0;
//    }
//}

- (void)hideSpeedSwiper {
    if (_speedSwiper) {
        [self.speedSwiper removeFromSuperview];
        _speedSwiper = nil;
    }
}

- (AUIPlayerZFVolumeBrightnessView *)volumeBrightnessView {
    if (!_volumeBrightnessView) {
        _volumeBrightnessView = [[AUIPlayerZFVolumeBrightnessView alloc] init];
        _volumeBrightnessView.accessibilityIdentifier = [self accessibilityId:@"volumeBrightnessView"];
        _volumeBrightnessView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
        _volumeBrightnessView.hidden = YES;
    }
    return _volumeBrightnessView;
}

- (AUIPlayerSpeedSwipeView *)speedSwiper {
    if (!_speedSwiper) {
        _speedSwiper = [[AUIPlayerSpeedSwipeView alloc] initWithFrame:CGRectMake(0, 0, 130, 36)];
        _speedSwiper.accessibilityIdentifier = [self accessibilityId:@"speedSwiper"];
        _speedSwiper.backgroundColor = AUIVideoFlowColor(@"vf_speed_bg");
    }
    return _speedSwiper;
}


#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer == self.panGesture) {
        CGPoint point = [gestureRecognizer locationInView:gestureRecognizer.view];
        //保留右边返回手势
        if (point.x <= 36) {
            return NO;
        }
        return YES;
    }
    
    return YES;
}

- (NSString *)accessibilityId:(NSString *)key {
    NSString *name = NSStringFromClass([self class]);
    return [AUIVideoFlowAccessibilityStr(name) stringByAppendingString:key];
}

@end
