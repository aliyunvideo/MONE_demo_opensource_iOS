//
//  AUIEditorSelectEffectPanel.m
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/6/21.
//

#import "AUIEditorSelectEffectPanel.h"
#import "AUIResourceManager.h"
#import "AUIFoundation.h"

@implementation AUIEditorSelectEffectPanel

+ (CGFloat)panelHeight {
    return 240 + AVSafeBottom;
}

+ (BOOL)hasEmptySelected {
    return NO;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame dataFetcher:^(FilterDataCallback cb) {
        [AUIResourceManager.manager fetchAnimationEffectsDataWithCallback:cb];
    }];
    if (self) {
        self.titleView.text = nil;
        
        __weak typeof(self) weakSelf = self;
        self.onSelectedChanged = ^(AUIFilterModel * _Nonnull model) {
            AUIEditorEffectAddActionItem *item = [AUIEditorEffectAddActionItem new];
            item.input = model;
            [weakSelf.actionManager doAction:item];
            [weakSelf hide];
        };
        self.showBackButton = YES;
    }
    return self;
}

@end
