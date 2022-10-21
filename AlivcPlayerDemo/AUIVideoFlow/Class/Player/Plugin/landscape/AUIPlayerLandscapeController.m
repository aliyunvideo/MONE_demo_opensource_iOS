
#import "AUIPlayerLandscapeController.h"
#import "AlivcPlayerManager.h"
#import "AlivcPlayerRotateAnimator.h"
#import "AUIPlayerLandscapeVideoContainer.h"


@interface AUIPlayerLandscapeController ()

@property (nonatomic, strong) UIView *playerView;
@property (nonatomic, strong) UIButton *backButton;

@property (nonatomic, assign) UIInterfaceOrientation currentOrientation;
@property (nonatomic, strong) AlivcPlayerRotateAnimator *customAnimator;
@property (nonatomic, strong) AUIPlayerLandscapeVideoContainer *videoContainer;



@end

@implementation AUIPlayerLandscapeController

- (void)dealloc
{
    NSLog(@"release class:%@",NSStringFromClass([self class]));
}

- (instancetype)initWithPlayView:(UIView *)playView
{
    self = [super init];
    if (self) {
        _playerView = playView;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)loadView
{
    self.view = [[AUIPlayerLandscapeVideoContainer alloc] initWithFrame:[UIScreen mainScreen].bounds];
}

- (void)viewDidAppear:(BOOL)animated
{
     [super viewDidAppear:animated];
//    [self.view addSubview:self.backButton];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
//    [self.backButton removeFromSuperview];
}

#pragma mark - public

- (void)expandOrCloseWithOrientation:(UIInterfaceOrientation)orientation
{
    if (_currentOrientation == orientation) {
        return;
    }
    
    _currentOrientation = orientation;

    if (UIInterfaceOrientationMaskLandscape & orientation) {
        return;
    }
//    //横屏方向切换
//    if (_currentOrientation == UIInterfaceOrientationLandscapeLeft && orientation == UIInterfaceOrientationLandscapeRight) {
//        self.customAnimator.isLeft = NO;
////        self.playerView.transform = CGAffineTransformMakeRotation(-M_PI);
////
////        [UIView animateWithDuration:0.3 animations:^{
////            self.playerView.transform = CGAffineTransformIdentity;
////        }];
//        self.currentOrientation = orientation;
//
//        return;
//    }
//
//    if (_currentOrientation == UIInterfaceOrientationLandscapeRight && orientation == UIInterfaceOrientationLandscapeLeft) {
//        self.customAnimator.isLeft = YES;
//        self.currentOrientation = orientation;
//
////        self.playerView.transform = CGAffineTransformMakeRotation(-M_PI);
////
////        [UIView animateWithDuration:0.3 animations:^{
////            self.playerView.transform = CGAffineTransformIdentity;
////        }];
//
//        return;
//    }
//    
//    self.currentOrientation = orientation;

    switch (orientation) {
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
        {
            [self expandLandscape];
        }
            break;
        case UIInterfaceOrientationPortrait:
        {
            [self closeLandscape];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - private

- (void)expandLandscape
{
    if (self.presentingViewController) {
        return;
    }
    self.customAnimator.playView = self.playerView;
    self.customAnimator.playViewOriginFrame = self.playerView.frame;
    if (self.currentOrientation == UIInterfaceOrientationLandscapeLeft) {
        self.customAnimator.toLeft = YES;
    } else {
        self.customAnimator.toLeft = NO;
    }
    self.transitioningDelegate = self.customAnimator;
    self.modalPresentationStyle = UIModalPresentationOverFullScreen;
    
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:self animated:YES completion:nil];
}


- (void)closeLandscape
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}


- (void)onBackButton:(id)sender
{
    [[AlivcPlayerManager manager] setCurrentOrientation:AlivcPlayerEventCenterTypeOrientationPortrait];
}


#pragma mark - getter

- (AlivcPlayerRotateAnimator *)customAnimator
{
    if (!_customAnimator) {
        _customAnimator = [[AlivcPlayerRotateAnimator alloc] init];
    }
    return _customAnimator;
}

- (UIButton *)backButton
{
    if (!_backButton) {
        _backButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 20, 100, 30)];
        _backButton.accessibilityIdentifier = [self accessibilityId:@"backButton"];
        _backButton.backgroundColor = [UIColor cyanColor];
        [_backButton addTarget:self action:@selector(onBackButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape | UIInterfaceOrientationMaskPortrait;
}

- (NSString *)accessibilityId:(NSString *)key {
    NSString *name = NSStringFromClass([self class]);
    return [AUIVideoFlowAccessibilityStr(name) stringByAppendingString:@"_key"];
}

@end

