//
//  AUIEditorFilterEditBar.m
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/6/9.
//

#import "AUIEditorFilterEditBar.h"
#import "AUIFilterModel.h"
#import "AUIFilterView.h"
#import "AUIResourceManager.h"
#import "Masonry.h"

@interface AUIEditorFilterView : AUIFilterView

@end

@implementation AUIEditorFilterView

- (void)fetchData
{
    __weak typeof(self) weakSelf = self;
    [AUIResourceManager.manager fetchFilterDataWithCallback:^(NSError * _Nullable error, NSArray * _Nonnull data) {
        NSMutableArray *result = data.mutableCopy;
        [result insertObject:AUIFilterModel.EmptyModel atIndex:0];
        [weakSelf updateDataSource:result];
        [weakSelf selectFilter:self.currentSelected];
    }];
}

@end

@interface AUIEditorFilterEditBar ()

@property (nonatomic, strong) AUIEditorFilterView *filterView;

@end

static NSString * const FilterModelAssociatedKey = @"filter_selected_model";

@implementation AUIEditorFilterEditBar

+ (BOOL)isMenuViewHidden {
    return YES;
}

+ (NSString *)title {
    return AUIUgsvGetString(@"滤镜");
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _filterView = [[AUIEditorFilterView alloc] initWithFrame:self.bounds];
        [self.contentView addSubview:_filterView];
        [_filterView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(self.contentView);
            make.bottom.equalTo(self.contentView).inset(AVSafeBottom);
        }];
        
        __weak typeof(self) weakSelf = self;
        _filterView.onSelectedChanged = ^(AUIFilterModel * _Nonnull model) {
            AUIEditorFilterSetActionItem *item = [AUIEditorFilterSetActionItem new];
            item.input = model;
            if ([weakSelf.actionManager doAction:item]) {
                [weakSelf.actionManager.currentOperator setAssociatedObject:model forKey:FilterModelAssociatedKey];
            }
        };
    }
    return self;
}

- (void)barWillAppear {
    [super barWillAppear];
    
    AUIFilterModel *selectedModel = (AUIFilterModel *)[self.actionManager.currentOperator associatedObjectForKey:FilterModelAssociatedKey];
    if (!selectedModel) {
        selectedModel = AUIFilterModel.EmptyModel;
    }
    [_filterView selectFilter:selectedModel];
}

@end
