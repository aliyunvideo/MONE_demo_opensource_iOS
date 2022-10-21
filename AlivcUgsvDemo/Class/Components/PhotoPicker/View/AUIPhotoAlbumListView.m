//
//  AUIPhotoAlbumListView.m
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/5/25.
//

#import "AUIPhotoAlbumListView.h"
#import "AUIPhotoAlbumCell.h"


@interface AUIPhotoAlbumListView () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, copy) NSArray<AUIPhotoAlbumModel *> *albumModelList;
@property (nonatomic, copy) void(^selectedBlock)(AUIPhotoAlbumModel *selectedModel);

@property (nonatomic, strong) UICollectionView *collectionView;

@end


@implementation AUIPhotoAlbumListView


- (instancetype)initWithFrame:(CGRect)frame
           withAlbumModelList:(NSArray<AUIPhotoAlbumModel *> *)modelList
            withSelectedBlock:(void(^)(AUIPhotoAlbumModel *selectedModel))selectedBlock {
    self = [super initWithFrame:frame];
    if (self) {
        _albumModelList = modelList;
        _selectedBlock = selectedBlock;
        
        self.backgroundColor = AUIFoundationColor(@"bg_medium");
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        self.collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flowLayout];
        self.collectionView.backgroundColor = [UIColor clearColor];
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
        self.collectionView.bounces = YES;
        self.collectionView.scrollsToTop = YES;
        self.collectionView.alwaysBounceVertical = NO;
        self.collectionView.delaysContentTouches = YES;
        self.collectionView.showsVerticalScrollIndicator = YES;
        [self.collectionView registerClass:AUIPhotoAlbumCell.class forCellWithReuseIdentifier:AVCollectionViewCellIdentifier];

    #ifdef __IPHONE_11_0
        if ([self.collectionView respondsToSelector:@selector(setContentInsetAdjustmentBehavior:)])
        {
            if (@available(iOS 11.0, *)) {
                self.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
            } else {
                // Fallback on earlier versions
            }
        }
    #endif
        
        [self addSubview:self.self.collectionView];
    }
    return self;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.albumModelList.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    AUIPhotoAlbumCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:AVCollectionViewCellIdentifier forIndexPath:indexPath];
    [cell updateAlbumModel:self.albumModelList[indexPath.row]];
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.selectedBlock) {
        self.selectedBlock(self.albumModelList[indexPath.row]);
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(self.collectionView.av_width, 92.0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0f;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, AVSafeBottom, 0);
}

- (void)appear:(void (^)(void))completed {
    self.collectionView.transform = CGAffineTransformMakeTranslation(0, self.av_height);
    [UIView animateWithDuration:0.25 animations:^{
        self.collectionView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        self.collectionView.transform = CGAffineTransformIdentity;
        if (completed) {
            completed();
        }
    }];
}

- (void)disappear:(void (^)(void))completed {
    self.collectionView.transform = CGAffineTransformIdentity;
    [UIView animateWithDuration:0.25 animations:^{
        self.collectionView.transform = CGAffineTransformMakeTranslation(0, self.av_height);
    } completion:^(BOOL finished) {
        self.collectionView.transform = CGAffineTransformIdentity;
        if (completed) {
            completed();
        }
    }];
}

@end
