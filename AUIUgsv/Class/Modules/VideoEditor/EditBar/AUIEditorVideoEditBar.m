//
//  AUIEditorVideoEditBar.m
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/6/9.
//

#import "AUIEditorVideoEditBar.h"
#import <AUIUgsvCom/AUIUgsvCom.h>
#import "AUIVolumePanel.h"
#import "AUIVideoAugmentationPanel.h"
#import "AUISpeedChangedControllPanel.h"
#import "AUIAudioEffectPanel.h"

@interface AUIEditorVideoEditBar ()


@end

@implementation AUIEditorVideoEditBar

+ (NSString *)title {
    return AUIUgsvGetString(@"剪辑");
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupMenuItem];
    }
    return self;
}

- (BOOL)hiddenMainTrakcerHeader {
    return NO;
}

- (void)setupMenuItem {
    NSInteger count = 4;
    CGFloat width = 46;
    CGFloat height = 38;
    CGFloat top = (self.menuView.av_height - height) / 2.0;
    
    __weak typeof(self) weakSelf = self;
    CGFloat left = (self.menuView.av_width - count * width) / 2.0;
    AVBaseButton *btn = [self.class createMenuButton:AUIUgsvGetString(@"变速") image:AUIUgsvEditorImage(@"ic_menu_speed")];
    btn.frame = CGRectMake(left, top, width, height);
    btn.action = ^(AVBaseButton * _Nonnull btn) {
        
        AUISpeedChangedControllPanel *panel = [[AUISpeedChangedControllPanel alloc] initWithFrame:weakSelf.bounds];
        [panel updateCurentValue:[AUIAepHelper timeSpeed:weakSelf.editor]];
        panel.onValueChanged = ^(float value) {
            AUIEditorVideoApplyTimeFilterActionItem *item = [AUIEditorVideoApplyTimeFilterActionItem new];
            item.input = @(value);
            [weakSelf.actionManager doAction:item];
        };
        [AUISpeedChangedControllPanel present:panel onView:weakSelf backgroundType:AVControllPanelBackgroundTypeClickToClose];
        
    };
    [self.menuView addSubview:btn];
    
    left += width;
    btn = [self.class createMenuButton:AUIUgsvGetString(@"音量") image:AUIUgsvEditorImage(@"ic_menu_volume")];
    btn.frame = CGRectMake(left, top, width, height);
    btn.action = ^(AVBaseButton * _Nonnull btn) {
        [AUIVolumePanel presentOnView:weakSelf withActionManager:weakSelf.actionManager];
    };
    [self.menuView addSubview:btn];
    
    left += width;
    btn = [self.class createMenuButton:AUIUgsvGetString(@"变声") image:AUIUgsvEditorImage(@"ic_menu_audio_effect")];
    btn.action = ^(AVBaseButton * _Nonnull btn) {
        [AUIAudioEffectPanel presentOnView:weakSelf withActionManager:weakSelf.actionManager];
    };
    btn.frame = CGRectMake(left, top, width, height);
    [self.menuView addSubview:btn];
    
    left += width;
    btn = [self.class createMenuButton:AUIUgsvGetString(@"增强") image:AUIUgsvEditorImage(@"ic_menu_augmentation")];
    btn.frame = CGRectMake(left, top, width, height);
    btn.action = ^(AVBaseButton * _Nonnull btn) {
        [AUIVideoAugmentationPanel presentOnView:weakSelf withActionManager:weakSelf.actionManager];
    };
    [self.menuView addSubview:btn];
}

- (void)actionItem:(AUIEditorActionItem *)item doActionResult:(NSError *)error retObject:(id)retObject {
    [super actionItem:item doActionResult:error retObject:retObject];
    
    if (error) {
        return;
    }
    if ([item isKindOfClass:AUIEditorVideoApplyTimeFilterActionItem.class]) {
        [self reloadMainTimeline];
        return;
    }
}

@end
