//
//  AUIFilterPanel.m
//  AlivcUgsvDemo
//
//  Created by coder.pi on 2022/6/13.
//

#import "AUIFilterPanel.h"
#import "AUIFoundation.h"
#import "Masonry.h"

@interface AUIFilterInnerView : AUIFilterView
@property (nonatomic, readonly) BOOL hasEmptySelected;
@property (nonatomic, copy) FilterDataFetcher dataFetcher;
@end

@implementation AUIFilterInnerView

- (instancetype)initWithDataFetcher:(FilterDataFetcher)dataFetcher hasEmptySelected:(BOOL)hasEmptySelected {
    _dataFetcher = dataFetcher;
    _hasEmptySelected = hasEmptySelected;
    return [super init];
}

- (void)fetchData {
    __weak typeof(self) weakSelf = self;
    _dataFetcher(^(NSError * _Nullable error, NSArray *data) {
        NSMutableArray *result = data.mutableCopy;
        if (weakSelf.hasEmptySelected) {
            [result insertObject:AUIFilterModel.EmptyModel atIndex:0];
        }
        [weakSelf updateDataSource:result];
        if (weakSelf.hasEmptySelected) {
            [weakSelf selectFilter:AUIFilterModel.EmptyModel];
        }
    });
}

@end

@implementation AUIFilterPanel

+ (CGFloat)panelHeight {
    return 186.0 + AVSafeBottom;
}

+ (BOOL)hasEmptySelected {
    return YES;
}

- (instancetype)initWithFrame:(CGRect)frame dataFetcher:(FilterDataFetcher)dataFetcher {
    self = [super initWithFrame:frame];
    if (self) {
        _filterView = [[AUIFilterInnerView alloc] initWithDataFetcher:dataFetcher hasEmptySelected:self.class.hasEmptySelected];
        [self.contentView addSubview:_filterView];
        [_filterView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(self.contentView);
            make.bottom.equalTo(self.contentView).inset(AVSafeBottom);
        }];
    }
    return self;
}

- (void)selectFilter:(AUIFilterModel *)filter {
    [_filterView selectFilter:filter];
}

- (void) setOnSelectedChanged:(OnFilterSelectedChanged)onSelectedChanged {
    self.filterView.onSelectedChanged = onSelectedChanged;
}
- (OnFilterSelectedChanged) onSelectedChanged {
    return self.filterView.onSelectedChanged;
}

@end
