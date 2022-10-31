//
//  AliyunCaptionFontView.m
//  AlivcUgsvDemo
//
//  Created by mengyehao on 2022/6/20.
//

#import "AliyunCaptionFontView.h"
#import "AUICaptionFontModel.h"
#import "AUITextCollectionViewCell.h"
#import "AUIResourceManager.h"


@interface AliyunCaptionFontView ()<UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong) NSMutableArray *dataList;
@property (nonatomic, strong) UICollectionView *collectionView;
@end

@implementation AliyunCaptionFontView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.collectionView];
        [self fetchData];
    }
    return self;
}

- (NSMutableArray *)dataList
{
    if (!_dataList) {
        _dataList = [NSMutableArray array];
    }
    return _dataList;
}

- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.itemSize = CGSizeMake(54, 26);
        layout.sectionInset = UIEdgeInsetsMake(0, 20, 0, 20);
        layout.minimumInteritemSpacing = 10;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        _collectionView = [[UICollectionView alloc]initWithFrame:self.bounds collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsHorizontalScrollIndicator = NO;
        
        [_collectionView registerClass:[AUITextCollectionViewCell class] forCellWithReuseIdentifier:@"AUITextCollectionViewCell"];
    }
    
    return _collectionView;
}

- (void)fetchData
{
    
    [[AUIResourceManager manager] fetchCaptionFontWithCallback:^(NSError * _Nullable error, NSArray * _Nonnull data) {
        
        NSMutableArray *temp = [NSMutableArray array];
        [temp addObject: [AUICaptionFontModel EmptyModel]];
        [temp addObjectsFromArray:data];
        NSArray *result = [temp sortedArrayUsingComparator:^NSComparisonResult(AUICaptionFontModel *  _Nonnull obj1, AUICaptionFontModel *  _Nonnull obj2) {
            return obj1.pority > obj2.pority;
        }];
        [self.dataList addObjectsFromArray:result];

        [self.collectionView reloadData];

    }];

    
}

- (void)selectWithIndex:(NSUInteger)index
{
    if (index >= self.dataList.count) {
        return;
    }
    
    NSIndexPath *idxPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.collectionView selectItemAtIndexPath:idxPath animated:YES scrollPosition:UICollectionViewScrollPositionTop];
    self.currentSelected  = self.dataList[index];

}

- (void)setCurrentSelected:(AUICaptionFontModel * _Nonnull)currentSelected
{
    if (currentSelected != _currentSelected) {
        _currentSelected = currentSelected;
        if (self.onSelectedChanged) {
            self.onSelectedChanged(currentSelected);
        }
    }
}

#pragma mark - CollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.dataList.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    AUITextCollectionViewCell
    *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AUITextCollectionViewCell" forIndexPath:indexPath];

    AUICaptionFontModel *model = self.dataList[indexPath.row];
    cell.textLabel.text = model.showName;
    cell.textLabel.font = [UIFont fontWithName:model.fontName size:12];
    return cell;
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.currentSelected  = self.dataList[indexPath.row];
}


@end
