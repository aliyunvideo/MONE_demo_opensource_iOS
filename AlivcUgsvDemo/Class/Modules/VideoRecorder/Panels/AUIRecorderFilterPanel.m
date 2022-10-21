//
//  AUIRecorderFilterPanel.m
//  AlivcUgsvDemo
//
//  Created by coder.pi on 2022/6/7.
//

#import "AUIRecorderFilterPanel.h"
#import "AUIResourceManager.h"
#import "AUIFilterView.h"
#import "AUIFilterCell.h"
#import "AUIFilterModel.h"
#import "AUIUgsvMacro.h"

@implementation AUIRecorderFilterPanel

+ (AUIRecorderFilterPanel *) present:(UIView *)onView
                   onSelectedChanged:(OnFilterSelectedChanged)selectedChanged
                             forType:(AUIRecorderFilterPanelType)type {
    CGRect frame = CGRectMake(0, 0, onView.av_width, self.panelHeight);
    AUIRecorderFilterPanel *panel = [[AUIRecorderFilterPanel alloc] initWithFrame:frame filterType:type];
    panel.onSelectedChanged = selectedChanged;
    [panel showOnView:onView];
    return panel;
}

+ (FilterDataFetcher) DataFetcherWithType:(AUIRecorderFilterPanelType)filterType {
    if (filterType == AUIRecorderFilterPanelTypeFilter) {
        return ^(FilterDataCallback cb) {
            [AUIResourceManager.manager fetchFilterDataWithCallback:cb];
        };
    }
    return ^(FilterDataCallback cb) {
        [AUIResourceManager.manager fetchAnimationEffectsDataWithCallback:cb];
    };
}

- (instancetype) initWithFrame:(CGRect)frame filterType:(AUIRecorderFilterPanelType)filterType {
    self = [super initWithFrame:frame dataFetcher:[AUIRecorderFilterPanel DataFetcherWithType:filterType]];
    if (self) {
        _filterType = filterType;
        if (filterType == AUIRecorderFilterPanelTypeFilter) {
            self.titleView.text = AUIUgsvGetString(@"滤镜");
        }
        else {
            self.titleView.text = AUIUgsvGetString(@"特效");
        }
    }
    return self;
}

@end
