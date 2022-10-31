//
//  AUIStickerView.m
//  AlivcUgsvDemo
//
//  Created by mengyehao on 2022/6/1.
//


#import "AUIStickerView.h"
#import "UIView+AVHelper.h"
#import "AUIPureImageCell.h"
#import "AUIStickerModel.h"
#import "AUIUgsvMacro.h"

static NSString *KAUIPureImageCell = @"KAUIPureImageCell";



@interface AUIStickerView()<UICollectionViewDataSource,UICollectionViewDelegate>
@property (nonatomic, strong) NSMutableArray *dataList;
@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation AUIStickerView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.collectionView];
        [self fetchData];
    }
    return self;
}

- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.itemSize = CGSizeMake(60, 60);
        layout.sectionInset = UIEdgeInsetsMake(20, 20, 20, 20);
        layout.minimumLineSpacing = 12;
        layout.minimumInteritemSpacing = 8;
        
        
        _collectionView = [[UICollectionView alloc]initWithFrame:self.bounds collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        
        [_collectionView registerClass:[AUIPureImageCell class] forCellWithReuseIdentifier:KAUIPureImageCell];
    }
    
    return _collectionView;
}

#pragma mark - CollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.dataList.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    AUIPureImageCell
    *cell = [collectionView dequeueReusableCellWithReuseIdentifier:KAUIPureImageCell forIndexPath:indexPath];
    AUIStickerModel *model = self.dataList[indexPath.row];
    if (model.isEmpty) {
        cell.iconView.image = AUIUgsvGetImage(@"ic_panel_clear");
    }
    else {
        cell.iconView.image = [UIImage imageWithContentsOfFile:model.iconPath];
    }

    return cell;
    
}

- (void)selectWithIndex:(NSUInteger)index {
    if (index >= self.dataList.count) {
        return;
    }
    
    NSIndexPath *idxPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.collectionView selectItemAtIndexPath:idxPath animated:YES scrollPosition:UICollectionViewScrollPositionTop];
    self.currentSelected = self.dataList[index];
}

- (void) setCurrentSelected:(AUIStickerModel *)currentSelected {
    if (_currentSelected == currentSelected) {
        return;
    }
    _currentSelected = currentSelected;
    if (self.onSelectedChanged) {
        self.onSelectedChanged(_currentSelected);
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.currentSelected = self.dataList[indexPath.row];
}


#pragma mark - Set

- (NSMutableArray *)dataList {
    if (!_dataList) {
        _dataList = [[NSMutableArray alloc] init];
    }
    return _dataList;
}

//overwrite
- (void)fetchData
{

}


- (void)updateDataSource:(NSArray *)list
{
    [self.dataList removeAllObjects];
    [self.dataList addObjectsFromArray:list];
    [self.collectionView reloadData];
}

@end
