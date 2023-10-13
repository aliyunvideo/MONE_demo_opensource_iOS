//
//  AUIFilterView.m
//  AlivcUgsvDemo
//
//  Created by coder.pi on 2022/6/7.
//

#import "AUIFilterView.h"
#import "AUIFilterCell.h"
#import "AUIFilterModel.h"
#import "Masonry.h"
#import "AUIUgsvMacro.h"

static NSString *kFilterCellIdentifier = @"FilterCellIdentifier";

@interface AUIFilterView ()

@property (nonatomic, strong) NSMutableArray *dataList;
@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation AUIFilterView

- (instancetype) init {
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void) setup {
    // clear
    [_collectionView removeFromSuperview];
    
    // create
    _dataList = @[].mutableCopy;
    
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.itemSize = CGSizeMake(54.0, 74.0);
    layout.sectionInset = UIEdgeInsetsMake(20.0, 20.0, 20.0, 20.0);
    layout.minimumInteritemSpacing = 4.0;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
    _collectionView.backgroundColor = UIColor.clearColor;
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [_collectionView registerClass:AUIFilterCell.class forCellWithReuseIdentifier:kFilterCellIdentifier];
    [self addSubview:_collectionView];
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.height.mas_equalTo(layout.itemSize.height + layout.sectionInset.top + layout.sectionInset.bottom);
        make.centerY.equalTo(self);
    }];
    
    // update
    [self fetchData];
}

- (void) updateDataSource:(NSArray *)list {
    [self.dataList removeAllObjects];
    [self.dataList addObjectsFromArray:list];
    [self.collectionView reloadData];
}

- (void)selectFilter:(AUIFilterModel *)filter {
    if (self.currentSelected == filter) {
        return;
    }
    if (!filter) {
        [self selectWithIndex:0];
        return;
    }
    for (NSUInteger i = 0; i < self.dataList.count; ++i) {
        AUIFilterModel *item = self.dataList[i];
        if ([item isEqual:filter]) {
            [self selectWithIndex:i];
            return;
        }
    }
    [self selectWithIndex:0];
}

- (void) selectWithIndex:(NSUInteger)index {
    if (index >= self.dataList.count) {
        return;
    }
    
    NSIndexPath *idxPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.collectionView selectItemAtIndexPath:idxPath animated:YES scrollPosition:UICollectionViewScrollPositionLeft];
    self.currentSelected = self.dataList[index];
}

// MARK: - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataList.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AUIFilterCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kFilterCellIdentifier forIndexPath:indexPath];
    cell.model = self.dataList[indexPath.row];
    return cell;
}

// MARK: - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.currentSelected = self.dataList[indexPath.row];
}

- (void) setCurrentSelected:(AUIFilterModel *)currentSelected {
    if (_currentSelected == currentSelected) {
        return;
    }
    _currentSelected = currentSelected;
    if (self.onSelectedChanged) {
        self.onSelectedChanged(_currentSelected);
    }
}

// MARK: - pure virtual
- (void) fetchData
{
    NSAssert(NO, @"子类必须重写该方法提供数据源");
}

@end
