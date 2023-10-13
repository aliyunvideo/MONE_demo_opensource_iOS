//
//  AUIPlayerPlayViewLayerManager.m
//  ApsaraVideo
//
//  Created by mengyehao on 2021/7/8.
//

#import "AUIPlayerPlayViewLayerManager.h"
#import "AUIPlayerPlayContainViewPluginInstallProtocol.h"
#import "AlivcPlayerManager.h"
#import "AlivcPlayerBottomToolPlugin.h"
#import "AUIPlayerNoActionView.h"


@interface APPlayContainerView : UIView

@property (nonatomic, strong) UIView *playView;
@property (nonatomic, strong) AUIPlayerNoActionView *lowView;
@property (nonatomic, strong) AUIPlayerNoActionView *middleView;
@property (nonatomic, strong) AUIPlayerNoActionView *heightView;

@end

@implementation APPlayContainerView


- (void)didMoveToSuperview
{
    [super didMoveToSuperview];

    [self updateSuperViewPlugin:self.superview];
 

}

- (void)updateSuperViewPlugin:(UIView *)newSuperview
{
    NSLog(@"newSuperview:%@",newSuperview);
    
    if ([newSuperview conformsToProtocol:@protocol(AUIPlayerPlayContainViewPluginInstallProtocol)]) {
        
        if ([newSuperview respondsToSelector:@selector(pluginMap)]) {
            NSDictionary<NSString *, NSNumber*> *dict = [newSuperview performSelector:@selector(pluginMap)];
            NSArray *currentPluginList = [AlivcPlayerManager manager].currentPluginIDList.copy;
            
            NSArray *idlist = dict.allKeys;
            NSArray *values = dict.allValues;
            
            for (NSString *pluginId in currentPluginList) {
                if (![idlist containsObject:pluginId]) {
                    [[AlivcPlayerManager manager] unRegisterPlugin:pluginId];
                }
            }
        
            for (int i = 0; i<idlist.count; i++) {
                NSString *pluginId = idlist[i];
                AlivcPlayerBasePluginLoadOption option = [values[i] integerValue];
                if (option == AlivcPlayerBasePluginLoadOptionNormal) {
                    [[AlivcPlayerManager manager] registerPlugin:pluginId];
                    
                } else if (option == AlivcPlayerBasePluginLoadOptionDelay) {
                    AVPStatus playerStatus = [AlivcPlayerManager manager].playerStatus;
                    if (playerStatus >= AVPStatusStarted) {
                        [[AlivcPlayerManager manager] registerPlugin:pluginId];
                    }
                }
            }
        }
        
        if ([newSuperview respondsToSelector:@selector(playscene)]) {
            int scene = [newSuperview performSelector:@selector(playscene)];

            [[AlivcPlayerManager manager] setPlayScene:scene];

        }
    }
    
    if (newSuperview == nil) {
        [[AlivcPlayerManager manager] setPlayScene:ApPlayerSceneInFeed];
    }
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI
{
    _playView = [[UIView alloc] init];
    _playView.accessibilityIdentifier = AUIVideoFlowAccessibilityStr(@"playView");
    [self addSubview:_playView];
    
    _lowView = [[AUIPlayerNoActionView alloc] init];
    _lowView.accessibilityIdentifier = AUIVideoFlowAccessibilityStr(@"lowView");
    [self addSubview:_lowView];
    
    _middleView = [[AUIPlayerNoActionView alloc] init];
    _middleView.accessibilityIdentifier = AUIVideoFlowAccessibilityStr(@"middleView");
    [self addSubview:_middleView];
    
    _heightView = [[AUIPlayerNoActionView alloc] init];
    _heightView.accessibilityIdentifier = AUIVideoFlowAccessibilityStr(@"heightView");
    [self addSubview:_heightView];
    
    CGRect frame = self.bounds;
    
    _playView.frame = frame;
    _playView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    _lowView.frame = frame;
    _lowView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    _middleView.frame = frame;
    _middleView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    _heightView.frame = frame;
    _heightView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (UIView *)viewAtLevel:(NSInteger)level
{
    switch (level) {
        case APPlayViewLayerLevelPlayer:
            return self.playView;
            break;
        case APPlayViewLayerLevelLow:
            return self.lowView;
            break;
        case APPlayViewLayerLevelMiddle:
            return self.middleView;
            break;
        case APPlayViewLayerLevelHigh:
            return self.heightView;
            break;
        default:
            return nil;
            break;
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
   UIView *view =  [super hitTest:point withEvent:event];
    return view;
}
@end


@interface AUIPlayerPlayViewLayerManager()
@property (nonatomic, strong) APPlayContainerView *conatainerView;
@end

@implementation AUIPlayerPlayViewLayerManager


- (APPlayContainerView *)conatainerView
{
    if (!_conatainerView) {
        _conatainerView = [[APPlayContainerView alloc] initWithFrame:CGRectZero];
        _conatainerView.accessibilityIdentifier = AUIVideoFlowAccessibilityStr(@"conatainerView");
    }
    return _conatainerView;
}

- (UIView *)viewAtLevel:(NSInteger)level
{
    return [self.conatainerView viewAtLevel:level];
}

- (UIView *)playContainView
{
    return self.conatainerView;
}

@end
