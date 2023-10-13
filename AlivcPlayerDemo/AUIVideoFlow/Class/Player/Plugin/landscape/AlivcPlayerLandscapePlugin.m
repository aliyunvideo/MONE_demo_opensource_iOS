//
//  AlivcPlayerLandscapePlugin.m
//  ApsaraVideo
//
//  Created by mengyehao on 2021/7/5.
//

#import "AlivcPlayerLandscapePlugin.h"
#import "AlivcPlayerManager.h"
#import "AUIPlayerLandscapeController.h"
#import "AlivcPlayerRotateAnimator.h"

@interface AlivcPlayerLandscapePlugin ()

@property (nonatomic, strong) AUIPlayerLandscapeController *landscapeController;

@end

@implementation AlivcPlayerLandscapePlugin

#pragma mark - overwitter

- (void)onInstall
{
    [super onInstall];
}

- (NSInteger)level
{
    return 0;
}

- (NSArray<NSNumber *> *)eventList
{
    return @[@(AlivcPlayerEventCenterTypeOrientationChanged)];
}

- (void)onReceivedEvent:(AlivcPlayerEventCenterType)eventType userInfo:(NSDictionary *)userInfo
{
    if (eventType == AlivcPlayerEventCenterTypeOrientationChanged) {
        if ([AlivcPlayerManager manager].pageEventFrom == AlivcPlayerPageEventFromFlowPage ||
            [AlivcPlayerManager manager].pageEventFrom == AlivcPlayerPageEventFromDetailPage) {
            AlivcPlayerEventCenterTypeOrientation orientation = [[userInfo objectForKey:@"orientation"] integerValue];
            [self handleOrientationChanged:orientation];
        }
    }
}

-(void)handleOrientationChanged:(AlivcPlayerEventCenterTypeOrientation)orientation
{
    if ([AlivcPlayerRotateAnimator isAimationing]) {
        return;
    }
    
    switch (orientation) {
        case AlivcPlayerEventCenterTypeOrientationPortrait:
            [self.landscapeController expandOrCloseWithOrientation:UIInterfaceOrientationPortrait];
            self.landscapeController = nil;
            break;
        case AlivcPlayerEventCenterTypeOrientationLandsacpeLeft:
        case AlivcPlayerEventCenterTypeOrientationLandsacpeRight:
        {
            if (!self.landscapeController) {
                UIView *playerView = [AlivcPlayerManager manager].playContainView;
                AUIPlayerLandscapeController *landscapeController = [[AUIPlayerLandscapeController alloc] initWithPlayView:playerView];
                self.landscapeController = landscapeController;
            }
            
            UIInterfaceOrientation interOrientation = UIInterfaceOrientationLandscapeLeft;
            if (orientation == AlivcPlayerEventCenterTypeOrientationLandsacpeRight) {
                interOrientation = UIInterfaceOrientationLandscapeRight;
            } else if (orientation == AlivcPlayerEventCenterTypeOrientationLandsacpeLeft) {
                interOrientation = UIInterfaceOrientationLandscapeLeft;
            }
            
            [self.landscapeController expandOrCloseWithOrientation:interOrientation];
        }
            break;
    }
  
}

@end
