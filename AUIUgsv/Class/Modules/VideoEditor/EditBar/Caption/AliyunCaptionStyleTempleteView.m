//
//  AliyunCaptionStyleTempleteView.m
//  AlivcUgsvDemo
//
//  Created by mengyehao on 2022/6/20.
//

#import "AliyunCaptionStyleTempleteView.h"
#import "AUIResourceManager.h"
#import "AUIPureImageCell.h"
#import "AUIUgsvMacro.h"
#import "Masonry.h"

@interface AUIStickerTempleteImageCell : AUIPureImageCell

@end

@implementation AUIStickerTempleteImageCell

- (void)setup
{
    self.contentView.layer.cornerRadius = 2.f;
    self.contentView.layer.masksToBounds = YES;
    [self.contentView addSubview:self.iconView];
    [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
}

- (void)setSelected:(BOOL)selected
{
    
}

@end

@interface AliyunCaptionStyleTempleteView ()<UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong) NSMutableArray *dataList;
@property (nonatomic, strong) UICollectionView *collectionView;
@end

@implementation AliyunCaptionStyleTempleteView

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
        layout.itemSize = CGSizeMake(28, 28);
        layout.sectionInset = UIEdgeInsetsMake(0, 20, 0, 20);
        layout.minimumInteritemSpacing = 10;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        _collectionView = [[UICollectionView alloc]initWithFrame:self.bounds collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsHorizontalScrollIndicator = NO;
        
        [_collectionView registerClass:[AUIStickerTempleteImageCell class] forCellWithReuseIdentifier:@"AUIStickerTempleteImageCell"];
    }
    
    return _collectionView;
}

- (void)fetchData
{
    [[AUIResourceManager manager] fetchCaptionStyleTempleteWithCallback:^(NSError * _Nullable error, NSArray * _Nonnull data) {

        [self.dataList addObject:[AUICaptionStyleTempleteModel EmptyModel]];
        [self.dataList addObjectsFromArray:data];
        [self.collectionView reloadData];
    }];
    
}

- (void)selectWithIndex:(NSUInteger)index
{
    if (index >= self.dataList.count) {
        return;
    }
    
//    NSIndexPath *idxPath = [NSIndexPath indexPathForRow:index inSection:0];
//    [self.collectionView selectItemAtIndexPath:idxPath animated:YES scrollPosition:UICollectionViewScrollPositionTop];
//    self.currentSelected  = self.dataList[index];

}

#pragma mark - CollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.dataList.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    AUIStickerTempleteImageCell
    *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AUIStickerTempleteImageCell" forIndexPath:indexPath];
    AUICaptionStyleTempleteModel *model = self.dataList[indexPath.row];
    
    if (model.isEmpty) {
        cell.iconView.image = AUIUgsvGetImage(@"ic_panel_clear");
    }
    else {
        cell.iconView.image = [UIImage imageWithContentsOfFile:model.iconPath];
    }
    
    return cell;
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.currentSelected = self.dataList[indexPath.row];

}

- (void) setCurrentSelected:(AUICaptionStyleTempleteModel * _Nonnull)currentSelected
{
    if (_currentSelected == currentSelected) {
        return;
    }
    _currentSelected = currentSelected;
    if (self.onSelectedChanged) {
        self.onSelectedChanged(_currentSelected);
    }
}



@end


