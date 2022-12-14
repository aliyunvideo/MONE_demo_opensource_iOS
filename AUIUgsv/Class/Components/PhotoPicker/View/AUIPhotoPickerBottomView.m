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

@property (nonatomic, assign) NSUInteger maxPIckingCount;
@property (nonatomic, assign) BOOL allowPickingImage;
@property (nonatomic, assign) BOOL allowPickingVideo;

@property (nonatomic, copy) NSArray<AUIPhotoAssetCellItem *> *selectedList;
@property (nonatomic, copy) void(^willRemoveBlock)(AUIPhotoAssetCellItem *item);
@property (nonatomic, copy) void(^completedBlock)(void);

@end

@implementation AUIPhotoPickerBottomView

- (instancetype)initWithFrame:(CGRect)frame
          withMaxPickingCount:(NSUInteger)maxPickingCount
        withAllowPickingImage:(BOOL)allowPickingImage
        withAllowPickingVideo:(BOOL)allowPickingVideo
           withAlbumModelList:(NSArray<AUIPhotoAssetCellItem *> *)selectedList
          withWillRemoveBlock:(void(^)(AUIPhotoAssetCellItem *item))willRemoveBlock
           withCompletedBlock:(void(^)(void))completedBlock {
    self = [super initWithFrame:frame];
    if (self) {
        _maxPIckingCount = maxPickingCount;
        _allowPickingImage = allowPickingImage;
        _allowPickingVideo = allowPickingVideo;
        _selectedList = selectedList;
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
        _nextButton.backgroundColor = AUIFoundationColor(@"colourful_fg_strong");
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

- (NSAttributedString *)attributeStringForNoneSelected {
    
    NSMutableAttributedString *as = [[NSMutableAttributedString alloc] init];
    
    if (self.maxPIckingCount == 0) {
        [as appendAttributedString:[[NSAttributedString alloc] initWithString:AUIUgsvGetString(@"?????????????????????")]];
    }
    else {
        [as appendAttributedString:[[NSAttributedString alloc] initWithString:AUIUgsvGetString(@"????????????")]];
        NSAttributedString *countString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %tu ", self.maxPIckingCount] attributes:@{NSForegroundColorAttributeName:AUIFoundationColor(@"colourful_text_strong")}];
        [as appendAttributedString:countString];
    }
    
    if (self.allowPickingVideo && self.allowPickingImage) {
        [as appendAttributedString:[[NSAttributedString alloc] initWithString:AUIUgsvGetString(@"??????????????????")]];
    }
    else if (self.allowPickingImage) {
        [as appendAttributedString:[[NSAttributedString alloc] initWithString:AUIUgsvGetString(@"?????????")]];
    }
    else if (self.allowPickingVideo) {
        [as appendAttributedString:[[NSAttributedString alloc] initWithString:AUIUgsvGetString(@"?????????")]];
    }
    
    return as;
}

- (void)reloadSelectedList {
    [self.collectionView reloadData];
    if (self.selectedList.count == 0) {
        
        self.durationView.attributedText = [self attributeStringForNoneSelected];
        [self.durationView sizeToFit];
        
        [self.nextButton setTitle:AUIUgsvGetString(@"?????????") forState:UIControlStateNormal];
        self.nextButton.backgroundColor = [UIColor clearColor];
        self.nextButton.enabled = NO;
        
        self.collectionView.hidden = YES;
        CGFloat height = AVSafeBottom + 50;
        self.frame = CGRectMake(self.av_left, self.av_bottom - height, self.av_width, height);
    }
    else {
        
        __block NSTimeInterval duration = 0;
        [self.selectedList enumerateObjectsUsingBlock:^(AUIPhotoAssetCellItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            duration += obj.assetModel.assetDuration;
        }];
        self.durationView.attributedText =[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", AUIUgsvGetString(@"?????????"), [AVStringFormat formatWithDuration:duration]]];
        [self.durationView sizeToFit];
        
        [self.nextButton setTitle:[NSString stringWithFormat:@"%@ %tu", AUIUgsvGetString(@"?????????"), self.selectedList.count] forState:UIControlStateNormal];
        self.nextButton.backgroundColor = AUIFoundationColor(@"colourful_fg_strong");
        self.nextButton.enabled = YES;
        
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
    [cell updateItem:self.selectedList[indexPath.row]];
    cell.willRemoveBlock = self.willRemoveBlock;
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
