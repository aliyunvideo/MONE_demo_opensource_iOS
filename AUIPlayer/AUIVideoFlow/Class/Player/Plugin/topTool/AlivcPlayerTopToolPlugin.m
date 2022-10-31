//
//  AlivcPlayerTopToolPlugin.m
//  ApsaraVideo
//
//  Created by mengyehao on 2021/7/14.
//

#import "AlivcPlayerTopToolPlugin.h"
#import "AlivcPlayerManager.h"
#import "AUIPlayerStatusBar.h"
#import "AUIPlayerTopView.h"
#import "AlivcPlayerRouter.h"


@interface AlivcPlayerTopToolPlugin()
@property (nonatomic, strong) AUIPlayerTopView *topView;

@end

@implementation AlivcPlayerTopToolPlugin

- (AUIPlayerTopView *)topView
{
    if (!_topView) {
        _topView = [[AUIPlayerTopView alloc] initWithFrame:CGRectMake(0, 0, self.containerView.bounds.size.width, 88)];
        _topView.accessibilityIdentifier = AUIVideoFlowAccessibilityStr(@"topView");
        _topView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _topView.topActionView.onButtonBlock = ^(NSUInteger type) {
            
            switch (type) {
                case AUIPlayerTopViewButtonTypeListen:
                {
                    [AlivcPlayerManager manager].disableVideo = YES;
                }
                    break;
                default:
                    break;
            }
        };
        
        _topView.topActionView.onBackButtonBlock = ^{
            if ([AlivcPlayerManager manager].pageEventFrom == AlivcPlayerPageEventFromFullScreenPlayPage) {
                [[AlivcPlayerManager manager] dispatchEvent:AlivcPlayerEventCenterTypeFullScreenPlayToDetailPage userInfo:nil];
            } else {
                if ([AlivcPlayerManager manager].currentOrientation != 0) {
                    [[AlivcPlayerManager manager] setCurrentOrientation:0];
                } else {
                    [[AlivcPlayerRouter currentViewController].navigationController popViewControllerAnimated:YES];
                }
            }
        };
        
    }
    return _topView;
}

- (NSInteger)level
{
    return 3;
}

- (void)onInstall
{
    [super onInstall];

    [self.containerView addSubview:self.topView];
    
    [self updateUIHidden];
}

- (void)onUnInstall
{
    [super onUnInstall];
    [_topView removeFromSuperview];
    _topView = nil;
}


- (NSArray<NSNumber *> *)eventList
{
    return @[@(AlivcPlayerEventCenterTypeOrientationChanged),
             @(AlivcPlayerEventCenterTypeLockChanged),
             @(AlivcPlayerEventCenterTypeControlToolHiddenChanged),
             @(AlivcPlayerEventCenterTypePlayerDisableVideoChanged),
    ];
}

- (void)onReceivedEvent:(AlivcPlayerEventCenterType)eventType userInfo:(NSDictionary *)userInfo
{
    if (eventType == AlivcPlayerEventCenterTypeLockChanged) {
        [self updateUIHidden];
    }  else if (eventType == AlivcPlayerEventCenterTypeControlToolHiddenChanged) {
        [self updateUIHidden];
    } else if (eventType == AlivcPlayerEventCenterTypeOrientationChanged) {
        [self updateUIOrientation];
    } else if (eventType == AlivcPlayerEventCenterTypePlayerDisableVideoChanged) {
        [self updateUIHidden];
    }
}

- (void)updateUIHidden
{
    bool hidden =  [AlivcPlayerManager manager].controlToolHidden || [AlivcPlayerManager manager].lock;
    
    if ([AlivcPlayerManager manager].currentOrientation == 0) {
        if ([AlivcPlayerManager manager].disableVideo) {
            hidden = YES;
        }
    }
    
    self.topView.listening = [AlivcPlayerManager manager].disableVideo;
    self.topView.hidden = hidden;
    NSString *title =  [AlivcPlayerManager manager].getMediaInfo.title;
    if ([title hasSuffix:@".mp4"]) {
        title = [title substringToIndex:title.length - @".mp4".length];
    }
    self.topView.topActionView.titleLabel.text = title;
    self.topView.landScape = [AlivcPlayerManager manager].currentOrientation != 0;
    if (!hidden && self.topView.landScape) {
        [self.topView.statusBar updateData];
    }
    
    [self.topView setNeedsLayout];
   
}

- (void)updateUIOrientation
{
    BOOL fullscreen = [AlivcPlayerManager manager].currentOrientation != 0;
    if (!fullscreen) {
        self.topView.frame = CGRectMake(0, 0, self.containerView.bounds.size.width, 42);
    } else {
        self.topView.frame = CGRectMake(0, 0, self.containerView.bounds.size.width, 88);

    }
    self.topView.landScape = [AlivcPlayerManager manager].currentOrientation != 0;

    [self updateUIHidden];
    
    [self.topView setNeedsLayout];
}

@end
