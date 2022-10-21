//
//  AUIVideoEditorUtils.m
//  AlivcUgsvDemo
//
//  Created by coder.pi on 2022/6/23.
//

#import "AUIVideoEditorUtils.h"
#import "AUIUgsvMacro.h"

@implementation AUIVideoEditorUtils

+ (AVBaseButton *) SettingForAllButton {
    AVBaseButton *setForAllBtn = [AVBaseButton ImageTextWithTitlePos:AVBaseButtonTitlePosRight];
    setForAllBtn.backgroundColor = AUIFoundationColor(@"fill_medium");
    setForAllBtn.layer.cornerRadius = 12.0;
    setForAllBtn.layer.masksToBounds = YES;
    setForAllBtn.title = AUIUgsvGetString(@"全部镜头");
    setForAllBtn.font = AVGetRegularFont(12);
    setForAllBtn.image = AUIUgsvEditorImage(@"ic_radiobox");
    setForAllBtn.selectedImage = AUIUgsvEditorImage(@"ic_radiobox_selected");
    setForAllBtn.insets = UIEdgeInsetsMake(3, 8, 3, 8);
    setForAllBtn.spacing = 4.0;
    return setForAllBtn;
}

@end

@implementation AUIVideoEditorHelperSettingForAll

+ (AUIVideoEditorHelperSettingForAll *) SettingForKey:(NSString *)key onChanged:(OnSettingForAllDidChanged)onChanged {
    AUIVideoEditorHelperSettingForAll *settingForAll = [[AUIVideoEditorHelperSettingForAll alloc] initWithKey:key];
    settingForAll.onChanged = onChanged;
    return settingForAll;
}

- (instancetype)initWithKey:(NSString *)key {
    self = [super init];
    if (self) {
        _saveKey = key;
        _button = [AUIVideoEditorUtils SettingForAllButton];
        __weak typeof(self) weakSelf = self;
        _button.action = ^(AVBaseButton * _Nonnull btn) {
            weakSelf.isOn = !weakSelf.isOn;
            if (weakSelf.onChanged) {
                weakSelf.onChanged(weakSelf.isOn);
            }
        };
    }
    return self;
}

- (void)setActionOperator:(id<AUIEditorActionOperator>)actionOperator {
    if (_actionOperator == actionOperator) {
        return;
    }
    _actionOperator = actionOperator;
    self.isOn = self.isOnByDefault;
}

- (void)setIsOn:(BOOL)isOn {
    self.isOnByDefault = isOn;
    if (_isOn == isOn) {
        return;
    }
    _isOn = isOn;
    _button.selected = isOn;
}

- (void)setIsOnByDefault:(BOOL)isOnByDefault {
    [self.actionOperator setAssociatedObject:@(isOnByDefault) forKey:self.saveKey];
}
- (BOOL)isOnByDefault {
    return ((NSNumber *)[self.actionOperator associatedObjectForKey:self.saveKey]).boolValue;
}

@end
