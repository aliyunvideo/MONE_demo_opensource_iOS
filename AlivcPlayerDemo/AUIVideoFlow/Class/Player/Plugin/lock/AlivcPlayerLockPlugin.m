//
//  AlivcPlayerLockPlugin.m
//  ApsaraVideo
//
//  Created by mengyehao on 2021/7/14.
//

#import "AlivcPlayerLockPlugin.h"
#import <Masonry/Masonry.h>
#import "AlivcPlayerAsset.h"
#import "AlivcPlayerManager.h"

@interface AlivcPlayerLockPlugin ()
@property (nonatomic, strong) UIButton *lockButton;
@end

@implementation AlivcPlayerLockPlugin

- (UIButton *)lockButton
{
    if (!_lockButton) {
        _lockButton = [[UIButton alloc]init];
        _lockButton.accessibilityIdentifier = [self accessibilityId:@"lockButton"];
        [_lockButton addTarget:self action:@selector(onLockButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [_lockButton setImage:AUIVideoFlowImage(@"player_unlock") forState:UIControlStateNormal];
        [_lockButton setImage:AUIVideoFlowImage(@"player_lock") forState:UIControlStateSelected];
        
        [self.containerView addSubview:_lockButton];
        
        CGSize buttonsize = CGSizeMake(24, 24);
        
        CGFloat left = [AlivcPlayerManager manager].currentOrientation == AlivcPlayerEventCenterTypeOrientationLandsacpeLeft ? 34 + 24 : 24;
        [_lockButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(buttonsize);
            make.left.equalTo(self.containerView).offset(left);
            make.centerY.equalTo(self.containerView.mas_centerY);
        }];
    }
    return _lockButton;
}

- (NSInteger)level
{
    return 3;
}



- (void)onUnInstall
{
    [super onUnInstall];
    [_lockButton removeFromSuperview];
    _lockButton = nil;
}

- (NSArray<NSNumber *> *)eventList
{
    return  @[@(AlivcPlayerEventCenterTypeControlToolHiddenChanged),@(AlivcPlayerEventCenterTypeOrientationChanged)];
}

- (void)onReceivedEvent:(AlivcPlayerEventCenterType)eventType userInfo:(NSDictionary *)userInfo
{
    if (eventType == AlivcPlayerEventCenterTypeControlToolHiddenChanged) {
        [self updateUIHidden];
    } else if (eventType == AlivcPlayerEventCenterTypeOrientationChanged) {
        [self updateButtonFrame];
    }
}

- (void)updateUIHidden
{
    self.lockButton.hidden = [AlivcPlayerManager manager].controlToolHidden || [AlivcPlayerManager manager].currentOrientation == 0;
}

- (void)updateButtonFrame
{
    if ([UIView av_isIphoneX]) {
        CGFloat left = [AlivcPlayerManager manager].currentOrientation == AlivcPlayerEventCenterTypeOrientationLandsacpeLeft ? 34 + 24 : 24;
        [self.lockButton mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.containerView).offset(left);
        }];
       
    }
}

- (void)onLockButtonClick:(UIButton *)button
{
    button.selected = !button.selected;
    BOOL lock = button.selected;
    [[AlivcPlayerManager manager] setLock:lock];
}

- (NSString *)accessibilityId:(NSString *)key {
    NSString *name = NSStringFromClass([self class]);
    return [AUIVideoFlowAccessibilityStr(name) stringByAppendingString:@"_key"];
}

@end
