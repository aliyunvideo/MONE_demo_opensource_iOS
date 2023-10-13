//
//  AUIPhotoPickerBottomView.m
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/5/28.
//

#import "AUIPhotoPickerBottomView.h"
#import "AUIPhotoAssetSelectedCell.h"
#import "AUIUgsvMacro.h"

@interface AUIPhotoPickerBottomView () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UIView *topLineView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UILabel *durationView;
@property (nonatomic, strong) UIButton *nextButton;

@property (nonatomic, copy) void(^willRemoveBlock)(AUIPhotoAssetSelectedItem *item);
@property (nonatomic, copy) void(^completedBlock)(void);

@end

@implementation AUIPhotoPickerBottomView

- (instancetype)initWithFrame:(CGRect)frame
          withWillRemoveBlock:(void(^)(AUIPhotoAssetSelectedItem *item))willRemoveBlock
           withCompletedBlock:(void(^)(void))completedBlock {
    self = [super initWithFrame:frame];
    if (self) {
        _willRemoveBlock = willRemoveBlock;
        _completedBlock = completedBlock;
        
        self.backgroundColor = AUIFoundationColor(@"bg_weak");

        _topLineView = [[UIView alloc] initWithFrame:CGRectZero];
        _topLineView.backgroundColor = AUIFoundationColor(@"border_infrared");
        [self addSubview:_topLineView];
        
        _durationView = [[UILabel alloc] initWithFrame:CGRectZero];
        _durationView.textColor = AUIFoundationColor(@"text_strong");
        _durationView.font = AVGetRegularFont(12);
        [self addSubview:_durationView];
        
        _nextButton = [[UIButton alloc] initWithFrame:CGRectZero];
        _nextButton.backgroundColor = AUIFoundationColor(@"colourful_fill_strong");
        _nextButton.titleLabel.font = AVGetRegularFont(12);
        [_nextButton setTitleColor:AUIFoundationColor(@"text_strong") forState:UIControlStateNormal];
        [_nextButton setTitleColor:AUIFoundationColor(@"text_ultraweak") forState:UIControlStateDisabled];
        _nextButton.layer.cornerRadius = 12.0;
        _nextButton.layer.masksToBounds = YES;
        [_nextButton addTarget:self action:@selector(onNextButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_nextButton];
        
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flowLayout];
        self.collectionView.backgroundColor = [UIColor clearColor];
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
        self.collectionView.bounces = YES;
        self.collectionView.scrollsToTop = NO;
        self.collectionView.alwaysBounceHorizontal = NO;
        self.collectionView.delaysContentTouches = YES;
        self.collectionView.showsHorizontalScrollIndicator = NO;
        [self.collectionView registerClass:AUIPhotoAssetSelectedCell.class forCellWithReuseIdentifier:AVCollectionViewCellIdentifier];

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

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.topLineView.frame = CGRectMake(0, 0, self.av_width, 1);
    
    [self.durationView sizeToFit];
    self.durationView.frame = CGRectMake(20, 16, self.durationView.av_width, 18);
    
    [self.nextButton sizeToFit];
    self.nextButton.frame = CGRectMake(self.av_width - 60 - 20, 16, 60, 24);
    
    self.collectionView.frame = CGRectMake(0, 54.0, self.collectionView.av_width, 60.0);
}

- (void)reloadSelectedList {
    self.durationView.attributedText = self.attributeText;
    [self.durationView sizeToFit];
    
    [self.collectionView reloadData];
    
    BOOL canNext = self.selectedList.count > 0;
    if (canNext) {
        __block BOOL isEmpty = NO;
        [self.selectedList enumerateObjectsUsingBlock:^(AUIPhotoAssetSelectedItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (!obj.asset) {
                isEmpty = YES;
                *stop = YES;
            }
        }];
        canNext = !isEmpty;
    }
    if (!canNext) {
        [self.nextButton setTitle:AUIUgsvGetString(@"下一步") forState:UIControlStateNormal];
        self.nextButton.backgroundColor = [UIColor clearColor];
        self.nextButton.enabled = NO;
    }
    else {
        [self.nextButton setTitle:[NSString stringWithFormat:@"%@ %tu", AUIUgsvGetString(@"下一步"), self.selectedList.count] forState:UIControlStateNormal];
        self.nextButton.backgroundColor = AUIFoundationColor(@"colourful_fill_strong");
        self.nextButton.enabled = YES;
    }
    
    if (self.selectedList.count == 0) {
        self.collectionView.hidden = YES;
        CGFloat height = AVSafeBottom + 50;
        self.frame = CGRectMake(self.av_left, self.av_bottom - height, self.av_width, height);
    }
    else {
        self.collectionView.hidden = NO;
        CGFloat height = AVSafeBottom + 130;
        self.frame = CGRectMake(self.av_left, self.av_bottom - height, self.av_width, height);
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.selectedList.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    AUIPhotoAssetSelectedCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:AVCollectionViewCellIdentifier forIndexPath:indexPath];
    AUIPhotoAssetSelectedItem *item = self.selectedList[indexPath.row];
    [cell updateItem:item];
    
    __weak typeof(self) weakSelf = self;
    cell.willRemoveBlock = ^(AUIPhotoAssetSelectedItem * _Nonnull item) {
        if (weakSelf.willRemoveBlock) {
            weakSelf.willRemoveBlock(item);
        }
    };
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(60.0, 60.0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 8.0f;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 20, 0, 20);
}

- (void)onNextButtonClicked:(UIButton *)sender {
    
    if (self.completedBlock) {
        self.completedBlock();
    }
    
}

@end
