//
//  AlivcPlayerListenPlugin.m
//  ApsaraVideo
//
//  Created by mengyehao on 2021/7/16.
//

#import "AlivcPlayerListenPlugin.h"

//
//  AlivcPlayerListenPlugin.m
//  ApsaraVideo
//
//  Created by mengyehao on 2021/7/15.
//

#import "AlivcPlayerListenPlugin.h"
#import "AUIPlayerListenView.h"
#import "AlivcPlayerManager.h"

@interface AlivcPlayerListenPlugin()
@property (nonatomic, strong) AUIPlayerListenView *listenView;
@end

@implementation AlivcPlayerListenPlugin

- (NSInteger)level
{
    return 2;
}

- (NSArray<NSNumber *> *)eventList
{
    return @[
        @(AlivcPlayerEventCenterTypePlayerDisableVideoChanged),
        @(AlivcPlayerEventCenterTypeOrientationChanged),
        @(AlivcPlayerEventCenterTypePlayerEventAVPStatus),
    ];
}

- (void)onUnInstall
{
    [super onUnInstall];
    [self hideListenView];
}

- (void)onReceivedEvent:(AlivcPlayerEventCenterType)eventType userInfo:(NSDictionary *)userInfo
{
    if (eventType == AlivcPlayerEventCenterTypePlayerDisableVideoChanged) {
        if ([AlivcPlayerManager manager].disableVideo) {
            [self showListenView];
        } else {
            [self hideListenView];
        }
    } else if (eventType == AlivcPlayerEventCenterTypeOrientationChanged) {
        _listenView.landScape = [AlivcPlayerManager manager].currentOrientation !=0;
    } else if (eventType == AlivcPlayerEventCenterTypePlayerEventAVPStatus) {
        [self updateListenPlayStatus];
    }
}

- (AUIPlayerListenView *)listenView
{
    if (!_listenView) {
        _listenView = [[AUIPlayerListenView alloc] initWithFrame:self.containerView.bounds];
        _listenView.accessibilityIdentifier = [self accessibilityId:@"listenView"];
        _listenView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _listenView.onPlayButtonBlock = ^{
            AVPStatus status = [AlivcPlayerManager manager].playerStatus;
            if (status == AVPStatusPaused || status == AVPStatusStopped) {
                [[AlivcPlayerManager manager] resume];
            } else if (status == AVPStatusCompletion) {
                [[AlivcPlayerManager manager] seekToTimeProgress:0 seekMode:AVP_SEEKMODE_ACCURATE];
                [[AlivcPlayerManager manager] resume];
            } else {
                [[AlivcPlayerManager manager] pause];
            }
        };
        
        _listenView.onQuitButtonBlock = ^{
            AVPStatus status = [AlivcPlayerManager manager].playerStatus;
            if (status == AVPStatusCompletion) {
                [[AlivcPlayerManager manager] seekToTimeProgress:0 seekMode:AVP_SEEKMODE_ACCURATE];
                [[AlivcPlayerManager manager] resume];
            }
            [AlivcPlayerManager manager].disableVideo = NO;
            [AlivcPlayerManager manager].isListening = NO;
        };
        
        _listenView.onRePlayButtonBlock = ^{
            [[AlivcPlayerManager manager] seekToTimeProgress:0 seekMode:AVP_SEEKMODE_ACCURATE];
            [[AlivcPlayerManager manager] resume];
        };
    }
    return _listenView;
}

- (void)showListenView
{
    self.listenView.frame = self.containerView.bounds;
    NSString *url = [[AlivcPlayerManager manager] getMediaInfo].coverURL;
    [self.listenView updateAvataImageWithCoverurl:url];
    [self.containerView addSubview:self.listenView];
    [self updateListenPlayStatus];
    [AlivcPlayerManager manager].isListening = YES;
}

- (void)hideListenView
{
    [_listenView removeFromSuperview];
    _listenView = nil;
    [AlivcPlayerManager manager].isListening = NO;
}

- (void)updateListenPlayStatus
{
    AVPStatus status = [AlivcPlayerManager manager].playerStatus;
    switch (status) {
        case AVPStatusPaused:
        case AVPStatusStopped:
        case AVPStatusCompletion:
        {
            [self.listenView updatePlayStatus:NO];
            [self.listenView updaRePlayHidden:status != AVPStatusCompletion];
        }

            break;
        case AVPStatusPrepared:
        {
            NSString *url = [[AlivcPlayerManager manager] getMediaInfo].coverURL;
            [self.listenView updateAvataImageWithCoverurl:url];
            [self.listenView updatePlayStatus:YES];
            [self.listenView updaRePlayHidden:YES];
        }
            break;
            
        default:
        {
            [self.listenView updatePlayStatus:YES];
            [self.listenView updaRePlayHidden:YES];
        }
            
            break;
    }
}

- (NSString *)accessibilityId:(NSString *)key {
    NSString *name = NSStringFromClass([self class]);
    return [AUIVideoFlowAccessibilityStr(name) stringByAppendingString:@"_key"];
}

@end
