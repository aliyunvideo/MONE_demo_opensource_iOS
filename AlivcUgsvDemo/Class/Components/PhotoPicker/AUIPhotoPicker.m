//
//  AUIPhotoPicker.m
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/5/25.
//

#import "AUIPhotoPicker.h"
#import "AUIPhotoAssetCell.h"
#import "AUIPhotoPickerTitleView.h"
#import "AUIPhotoAlbumListView.h"
#import "AUIPhotoPickerTabView.h"
#import "AUIPhotoPickerBottomView.h"
#import "AUIUgsvMacro.h"

@implementation AUIPhotoPickerInputItem

- (instancetype)init {
    self = [super init];
    if (self) {
        _allowPickingImage = YES;
        _allowPickingVideo = YES;
    }
    return self;
}

@end

@implementation AUIPhotoPickerResult

- (instancetype)init:(NSString *)filePath model:(AUIPhotoAssetModel *)model inputItem:(AUIPhotoPickerInputItem *)inputItem {
    self = [super init];
    if (self) {
        _filePath = filePath;
        _model = model;
        _inputItem = inputItem;
    }
    return self;
}

+ (AUIPhotoPickerResult *)result:(NSString *)filePath model:(AUIPhotoAssetModel *)model inputItem:(AUIPhotoPickerInputItem *)inputItem {
    AUIPhotoPickerResult *result = [[AUIPhotoPickerResult alloc] init:filePath model:model inputItem:inputItem];
    return result;
}

@end

@interface AUIPhotoPicker ()

@property (nonatomic, assign) NSUInteger maxPickingCount;
@property (nonatomic, assign) BOOL allowPickingImage;
@property (nonatomic, assign) BOOL allowPickingVideo;
@property (nonatomic, assign) CMTimeRange timeRange; //kCMTimeRangeZero则为不限时长

@property (nonatomic, copy) NSArray<AUIPhotoPickerInputItem *> *inputItems;

@property (nonatomic, strong) AUIPhotoPickerTitleView *pickerTitleView;
@property (nonatomic, strong) AUIPhotoAlbumListView *albumListView;
@property (nonatomic, strong) AUIPhotoPickerBottomView *pickerBottomView;

@property (nonatomic, strong) NSArray<AUIPhotoAlbumModel *> *photoAlbumArray;
@property (nonatomic, strong) AUIPhotoAlbumModel *currentAlbum;

@property (nonatomic, strong) NSArray<AUIPhotoAssetCellItem *> *allAssetArray;
@property (nonatomic, strong) NSArray<AUIPhotoAssetCellItem *> *videoAssetArray;
@property (nonatomic, strong) NSArray<AUIPhotoAssetCellItem *> *imageAssetArray;
@property (nonatomic, assign) AUIPhotoPickerTabType currentTabType;

@property (nonatomic, strong) NSMutableArray<AUIPhotoAssetSelectedItem *> *selectedAssetArray;
@property (nonatomic, assign) NSUInteger currentSelectedItemIndex;

@property (nonatomic, copy) void(^modelsCompletedBlock)(AUIPhotoPicker *sender, NSArray<AUIPhotoAssetModel *> *models);
@property (nonatomic, copy) void(^resultsCompletedBlock)(AUIPhotoPicker *sender, NSArray<AUIPhotoPickerResult *> *results);
@property (nonatomic, copy) NSString *outputDir;

@end

@implementation AUIPhotoPicker

- (instancetype)init {
    return [self initWithMaxPickingCount:0 withAllowPickingImage:YES withAllowPickingVideo:YES withTimeRange:kCMTimeRangeZero];
}

- (instancetype)initWithMaxPickingCount:(NSUInteger)maxPickingCount
                  withAllowPickingImage:(BOOL)allowPickingImage
                  withAllowPickingVideo:(BOOL)allowPickingVideo
                          withTimeRange:(CMTimeRange)timeRange {
    self = [super init];
    if (self) {
        _maxPickingCount = maxPickingCount == 0 ? NSUIntegerMax : maxPickingCount;
        _allowPickingImage = allowPickingImage;
        _allowPickingVideo = allowPickingVideo;
        _timeRange = timeRange;
    }
    return self;
}

- (instancetype)initWithInputItems:(NSArray<AUIPhotoPickerInputItem *> *)items {
    self = [super init];
    if (self) {
        _inputItems = items;
        _maxPickingCount = [_inputItems count];
        _allowPickingImage = YES;
        _allowPickingVideo = YES;
        __block CMTime minDuration = kCMTimePositiveInfinity;
        [_inputItems enumerateObjectsUsingBlock:^(AUIPhotoPickerInputItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (CMTIME_IS_POSITIVE_INFINITY(minDuration)) {
                minDuration = obj.duration;
            }
            else {
                minDuration = CMTimeMinimum(minDuration, obj.duration);
            }
        }];
        if (CMTIME_IS_POSITIVE_INFINITY(minDuration)) {
            minDuration = kCMTimeZero;
        }
        _timeRange = CMTimeRangeMake(minDuration, kCMTimePositiveInfinity);
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = AUIFoundationColor(@"bg_medium");

    self.headerLineView.hidden = NO;
    self.hiddenMenuButton = YES;
    [self.backButton setImage:AUIFoundationImage(@"ic_close") forState:UIControlStateNormal];
    
    __weak typeof(self) weakSelf = self;

    CGFloat y = 0;
    if (self.allowPickingImage && self.allowPickingVideo) {
        AUIPhotoPickerTabView *tabView = [[AUIPhotoPickerTabView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.av_width, 42) withTabChangedBlock:^(AUIPhotoPickerTabType type) {
            [weakSelf onTabChanged:type];
        }];
        [self.contentView addSubview:tabView];
        y = tabView.av_bottom;
        self.currentTabType = tabView.tabType;
    }
    else {
        self.currentTabType = AUIPhotoPickerTabTypeAll;
    }
    
    if (self.maxPickingCount != 1 || self.inputItems) {
        CGFloat bottomHeight = 50 + AVSafeBottom;
        self.pickerBottomView = [[AUIPhotoPickerBottomView alloc] initWithFrame:CGRectMake(0, self.contentView.av_height - bottomHeight, self.contentView.av_width, bottomHeight) withWillRemoveBlock:^(AUIPhotoAssetSelectedItem * _Nonnull item) {
            [weakSelf removeCellItem:item.asset];
        } withCompletedBlock:^{
            [weakSelf raiseSelectionCompleted];
        }];
        [self.contentView addSubview:self.pickerBottomView];
        [self refreshBottomView];
    }
    
    self.collectionView.frame = CGRectMake(0, y, self.contentView.av_width, self.contentView.av_height - y);
    [self.collectionView registerClass:[AUIPhotoAssetCell class] forCellWithReuseIdentifier:AVCollectionViewCellIdentifier];
    
    self.pickerTitleView = [[AUIPhotoPickerTitleView alloc]  initWithSelectChangedBlock:^(BOOL selected) {
        if (selected) {
            [weakSelf openAlbumListView];
        }
        else {
            [weakSelf closeAlbumListView];
        }
    }];
    self.pickerTitleView.hidden = YES;
    [self.headerView addSubview:self.pickerTitleView];

    [self fetchPhotoData];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self currentCellItems].count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    AUIPhotoAssetCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:AVCollectionViewCellIdentifier forIndexPath:indexPath];
    [cell updateItem:[self currentCellItems][indexPath.row] singleSelect:self.pickerBottomView == nil];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width = (self.collectionView.av_width - 3 * 2) / 3.0;
    return CGSizeMake(width, width);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 3.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 3.0f;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(3, 0, self.pickerBottomView ? self.pickerBottomView.av_height : AVSafeBottom, 0);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    AUIPhotoAssetCellItem *item = [self currentCellItems][indexPath.row];
    if (item.disableSelection) {
        return;;
    }
    
    if (item.selectedIndex > 0) {
        [self removeCellItem:item];
    }
    else {
        [self addCellItem:item];
    }
    
    if (self.pickerBottomView == nil) {
        [self raiseSelectionCompleted];
    }
}

#pragma mark - selection completed


- (void)onSelectionCompleted:(void (^)(AUIPhotoPicker * _Nonnull, NSArray<AUIPhotoAssetModel *> * _Nonnull))completedBlock {
    self.modelsCompletedBlock = completedBlock;
}

- (void)onSelectionCompleted:(void (^)(AUIPhotoPicker * _Nonnull, NSArray<AUIPhotoPickerResult *> * _Nonnull))completedBlock withOutputDir:(NSString *)outputDir {
    self.resultsCompletedBlock = completedBlock;
    self.outputDir = outputDir;
}

- (void)raiseSelectionCompleted {
    
    if (self.modelsCompletedBlock) {
        NSMutableArray<AUIPhotoAssetModel *> *models = [NSMutableArray array];
        [self.selectedAssetArray enumerateObjectsUsingBlock:^(AUIPhotoAssetSelectedItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.asset) {
                [models addObject:obj.asset.assetModel];
            }
        }];
        self.modelsCompletedBlock(self, models);
    }
    
    if (self.resultsCompletedBlock) {
        
        AVProgressHUD *loading = [AVProgressHUD ShowHUDAddedTo:self.view animated:YES];
        loading.labelText = AUIUgsvGetString(@"处理中");
        
        __weak typeof(self) weakSelf =self;
        NSMutableDictionary *infos = [NSMutableDictionary dictionary];
        void (^fetchCompleted)(void) = ^(void) {
            
            __block BOOL isCompleted = YES;
            [infos.allValues enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj isEqualToString:@""]) {
                    isCompleted = NO;
                    *stop = YES;
                }
            }];
            if (isCompleted) {
                NSMutableArray<AUIPhotoPickerResult *> *results = [NSMutableArray array];
                [weakSelf.selectedAssetArray enumerateObjectsUsingBlock:^(AUIPhotoAssetSelectedItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    NSString *path = [infos objectForKey:@(idx)];
                    AUIPhotoPickerInputItem *inputItem = nil;
                    if (idx < weakSelf.inputItems.count) {
                        inputItem = [weakSelf.inputItems objectAtIndex:idx];
                    }
                    [results addObject:[AUIPhotoPickerResult result:path model:obj.asset.assetModel inputItem:inputItem]];
                }];
                weakSelf.resultsCompletedBlock(weakSelf, results);
                [loading hideAnimated:YES];
            }
        };
        
        [self.selectedAssetArray enumerateObjectsUsingBlock:^(AUIPhotoAssetSelectedItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [infos setObject:@"" forKey:@(idx)];
        }];
        
        [self.selectedAssetArray enumerateObjectsUsingBlock:^(AUIPhotoAssetSelectedItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (!obj.asset) {
                [infos removeObjectForKey:@(idx)];
                fetchCompleted();
                return;
            }
            [self fetchFilePath:obj.asset.assetModel completion:^(NSString *filePath, NSError *error) {
                NSLog(@"Picker selected asset completed result:%@  error: %@", filePath, error);
                if (filePath.length > 0) {
                    [infos setObject:filePath forKey:@(idx)];
                    fetchCompleted();
                }
                else {
                    [infos removeObjectForKey:@(idx)];
                    fetchCompleted();
                }
            }];
        }];
    }
}

#pragma mark - selection

- (NSMutableArray<AUIPhotoAssetSelectedItem *> *)selectedAssetArray {
    if (!_selectedAssetArray) {
        _selectedAssetArray = [NSMutableArray array];
        [self.inputItems enumerateObjectsUsingBlock:^(AUIPhotoPickerInputItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            AUIPhotoAssetSelectedItem *item = [AUIPhotoAssetSelectedItem new];
            item.assetDuration = CMTimeGetSeconds(obj.duration);
            item.durationMode = YES;
            item.selected = idx == 0;
            [_selectedAssetArray addObject:item];
        }];
        self.currentSelectedItemIndex = 0;
    }
    return _selectedAssetArray;
}

- (void)refreshDisableSelection {
    __block BOOL disableSelection = self.selectedAssetArray.count >= self.maxPickingCount || self.maxPickingCount == 0;
    if (disableSelection) {
        [self.selectedAssetArray enumerateObjectsUsingBlock:^(AUIPhotoAssetSelectedItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (!obj.asset) {
                disableSelection = NO;
                *stop = YES;
            }
        }];
    }
    
    AUIPhotoPickerInputItem *willSelectItem = nil;
    if (self.currentSelectedItemIndex < self.selectedAssetArray.count) {
        willSelectItem = [self.inputItems objectAtIndex:self.currentSelectedItemIndex];
    }
    
    [self.allAssetArray enumerateObjectsUsingBlock:^(AUIPhotoAssetCellItem * _Nonnull cellItem, NSUInteger idx, BOOL * _Nonnull stop) {
        
        __block AUIPhotoAssetSelectedItem *find = nil;
        [self.selectedAssetArray enumerateObjectsUsingBlock:^(AUIPhotoAssetSelectedItem * _Nonnull selectedItem, NSUInteger idx, BOOL * _Nonnull stop) {
            if (selectedItem.asset == cellItem) {
                find = selectedItem;
            }
        }];
        if (!find) {
            BOOL shouldDisable = disableSelection;
            if (willSelectItem) {
                if (!shouldDisable) {
                    if (cellItem.assetModel.type == AUIPhotoAssetTypePhoto && !willSelectItem.allowPickingImage) {
                        shouldDisable = YES;
                    }
                }
                if (!shouldDisable) {
                    if (cellItem.assetModel.type == AUIPhotoAssetTypeVideo && !willSelectItem.allowPickingVideo) {
                        shouldDisable = YES;
                    }
                }
                if (!shouldDisable) {
                    if (cellItem.assetModel.type == AUIPhotoAssetTypeVideo && willSelectItem.filterByDuration && CMTimeGetSeconds(willSelectItem.duration) > cellItem.assetModel.assetDuration ) {
                        shouldDisable = YES;
                    }
                }
            }
            cellItem.disableSelection = shouldDisable;
        }
        else {
            cellItem.disableSelection = NO;
        }
    }];
}

- (void)refreshCollectionView {
    [[self.collectionView visibleCells] enumerateObjectsUsingBlock:^(__kindof AUIPhotoAssetCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj refreshSelectionState];
    }];
    [self.collectionView.collectionViewLayout invalidateLayout];
}

- (void)refreshBottomView {
    
    NSMutableAttributedString *as = [[NSMutableAttributedString alloc] init];
    if (self.inputItems) {
        [as appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:AUIUgsvGetString(@"选择 %tu 个素材效果最佳"), self.inputItems.count]]];
    }
    else {
        if (self.selectedAssetArray.count == 0) {
            if (self.maxPickingCount == NSUIntegerMax) {
                [as appendAttributedString:[[NSAttributedString alloc] initWithString:AUIUgsvGetString(@"请选择至少一")]];
            }
            else {
                [as appendAttributedString:[[NSAttributedString alloc] initWithString:AUIUgsvGetString(@"最多能选")]];
                NSAttributedString *countString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %tu ", self.maxPickingCount] attributes:@{NSForegroundColorAttributeName:AUIFoundationColor(@"colourful_text_strong")}];
                [as appendAttributedString:countString];
            }
            
            if (self.allowPickingVideo && self.allowPickingImage) {
                [as appendAttributedString:[[NSAttributedString alloc] initWithString:AUIUgsvGetString(@"个视频或图片")]];
            }
            else if (self.allowPickingImage) {
                [as appendAttributedString:[[NSAttributedString alloc] initWithString:AUIUgsvGetString(@"个图片")]];
            }
            else if (self.allowPickingVideo) {
                [as appendAttributedString:[[NSAttributedString alloc] initWithString:AUIUgsvGetString(@"个视频")]];
            }
        }
        else {
            __block NSTimeInterval duration = 0;
            [self.selectedAssetArray enumerateObjectsUsingBlock:^(AUIPhotoAssetSelectedItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                duration += obj.assetDuration;
            }];
            [as appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", AUIUgsvGetString(@"总时长"), [AVStringFormat formatWithDuration:duration]]]];
        }
    }
    
    self.pickerBottomView.attributeText = as;
    self.pickerBottomView.selectedList = self.selectedAssetArray;
    [self.pickerBottomView reloadSelectedList];
}

- (void)addCellItem:(AUIPhotoAssetCellItem *)cellItem {
    if (self.maxPickingCount == 0 || self.currentSelectedItemIndex >= self.maxPickingCount) {
        return;
    }
    
    if (self.currentSelectedItemIndex < self.selectedAssetArray.count) {
        cellItem.selectedIndex = self.currentSelectedItemIndex + 1;
        AUIPhotoAssetSelectedItem *selectedItem = [self.selectedAssetArray objectAtIndex:self.currentSelectedItemIndex];
        selectedItem.selected = NO;
        selectedItem.asset = cellItem;
    }
    else {
        AUIPhotoAssetSelectedItem *selectedItem = [AUIPhotoAssetSelectedItem new];
        selectedItem.asset = cellItem;
        [self.selectedAssetArray addObject:selectedItem];
        cellItem.selectedIndex = self.selectedAssetArray.count;
    }
    
    __block NSUInteger next = NSUIntegerMax;
    [self.selectedAssetArray enumerateObjectsUsingBlock:^(AUIPhotoAssetSelectedItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (!obj.asset) {
            next = idx;
            obj.selected = YES;
            *stop = YES;
        }
    }];
    if (next == NSUIntegerMax) {
        next = self.selectedAssetArray.count;
    }
    self.currentSelectedItemIndex = next;
    NSLog(@"Picker add cell item updated currentSelectedItemIndex:%tu", self.currentSelectedItemIndex);
    
    [self refreshDisableSelection];
    [self refreshCollectionView];
    [self refreshBottomView];
}

- (void)removeCellItem:(AUIPhotoAssetCellItem *)cellItem {
    __block AUIPhotoAssetSelectedItem *find = nil;
    [self.selectedAssetArray enumerateObjectsUsingBlock:^(AUIPhotoAssetSelectedItem * _Nonnull selectedItem, NSUInteger idx, BOOL * _Nonnull stop) {
        if (selectedItem.asset == cellItem) {
            find = selectedItem;
        }
    }];
    if (!find) {
        return;
    }
    
    if (self.currentSelectedItemIndex < self.selectedAssetArray.count) {
        AUIPhotoAssetSelectedItem *selectedItem = [self.selectedAssetArray objectAtIndex:self.currentSelectedItemIndex];
        selectedItem.selected = NO;
    }
    
    cellItem.selectedIndex = 0;
    if (self.inputItems) {
        find.asset = nil;
        find.selected = YES;
        self.currentSelectedItemIndex = [self.selectedAssetArray indexOfObject:find];
    }
    else {
        [self.selectedAssetArray removeObject:find];
        self.currentSelectedItemIndex = self.selectedAssetArray.count;
    }
    NSLog(@"Picker remove cell item updated currentSelectedItemIndex:%tu", self.currentSelectedItemIndex);
    
    [self.selectedAssetArray enumerateObjectsUsingBlock:^(AUIPhotoAssetSelectedItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.asset.selectedIndex = idx + 1;
    }];
    
    [self refreshDisableSelection];
    [self refreshCollectionView];
    [self refreshBottomView];
}

#pragma mark - Data

- (NSArray<AUIPhotoAssetCellItem *> *)currentCellItems {
    if (self.currentTabType == AUIPhotoPickerTabTypeImage) {
        return self.imageAssetArray;
    }
    else if (self.currentTabType == AUIPhotoPickerTabTypeVideo) {
        return self.videoAssetArray;
    }
    else {
        return self.allAssetArray;
    }
}

- (void)fetchPhotoData {
    __weak typeof(self) weakSelf =self;
    [AUIPhotoLibraryManager requestAuthorization:^(BOOL authorization) {
        if (authorization) {
            
            [AUIPhotoLibraryManager getAllAlbumsAllowPickingVideo:weakSelf.allowPickingVideo allowPickingImage:weakSelf.allowPickingImage sortAscendingByModificationDate:NO durationRange:weakSelf.timeRange completion:^(NSArray<AUIPhotoAlbumModel *> * _Nonnull models) {
                if (models.count == 0) {
                    [AUIPhotoLibraryManager getCameraRollAlbumAllowPickingVideo:weakSelf.allowPickingVideo allowPickingImage:weakSelf.allowPickingImage sortAscendingByModificationDate:NO durationRange:kCMTimeRangeZero completion:^(AUIPhotoAlbumModel * _Nonnull model) {
                        model.assetsCount = 0;
                        [weakSelf onFetchAllAlbumsCompleted:model ?  @[model] : @[]];
                    }];
                }
                else {
                    [weakSelf onFetchAllAlbumsCompleted:models];
                }
            }];
        }
        else {
        }
    }];
}

- (void)onFetchAllAlbumsCompleted:(NSArray<AUIPhotoAlbumModel *> *)models {
    self.photoAlbumArray = models;
    [self fetchAlbumAssets:models.firstObject];
}

- (void)fetchAlbumAssets:(AUIPhotoAlbumModel *)albumModel {
    self.currentAlbum = albumModel;
    self.pickerTitleView.hidden = NO;
    [self.pickerTitleView updateTitle:self.currentAlbum.albumName];
    self.pickerTitleView.center = self.titleView.center;
        
    __weak typeof(self)weakSelf =self;
    [AUIPhotoLibraryManager getAssetsFromFetchResult:self.currentAlbum.fetchResult allowPickingVideo:weakSelf.allowPickingVideo allowPickingImage:weakSelf.allowPickingImage completion:^(NSArray<AUIPhotoAssetModel *> * _Nonnull models) {
        
        [weakSelf onFetchAssetsCompleted:models];
        
    }];
}

- (void)onFetchAssetsCompleted:(NSArray<AUIPhotoAssetModel *> *)models {
    
    NSMutableArray<AUIPhotoAssetCellItem *> *allAssetArray = [NSMutableArray array];
    NSMutableArray<AUIPhotoAssetCellItem *> *videoAssetArray = [NSMutableArray array];
    NSMutableArray<AUIPhotoAssetCellItem *> *imageAssetArray = [NSMutableArray array];
    
    [models enumerateObjectsUsingBlock:^(AUIPhotoAssetModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        __block AUIPhotoAssetCellItem *item = nil;
        [self.selectedAssetArray enumerateObjectsUsingBlock:^(AUIPhotoAssetSelectedItem * _Nonnull selectedItem, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([selectedItem.asset.assetModel.asset.localIdentifier isEqualToString:obj.asset.localIdentifier]) {
                item = selectedItem.asset;
                *stop = YES;
            }
        }];
        if (!item) {
            item = [[AUIPhotoAssetCellItem alloc] initWithAssetModel:obj];
        }
        [allAssetArray addObject:item];
        if (obj.type == AUIPhotoAssetTypePhoto) {
            [imageAssetArray addObject:item];
        }
        else if (obj.type == AUIPhotoAssetTypeVideo) {
            [videoAssetArray addObject:item];
        }
    }];
    
    self.allAssetArray = allAssetArray;
    self.videoAssetArray = videoAssetArray;
    self.imageAssetArray = imageAssetArray;
    
    [self refreshDisableSelection];
    [self.collectionView reloadData];
}

- (void)fetchFilePath:(AUIPhotoAssetModel *)assetModel completion:(void (^)(NSString *filePath, NSError *error))completion{
    if (assetModel.type == AUIPhotoAssetTypePhoto) {
        [AUIPhotoLibraryManager getPhotoPathWithAsset:assetModel.asset withOutputDir:self.outputDir completion:completion];
    }
    else if (assetModel.type == AUIPhotoAssetTypeVideo) {
        [AUIPhotoLibraryManager getVideoPathWithAsset:assetModel.asset withOutputDir:self.outputDir completion:completion];
    }
}

#pragma mark - Album

- (void)openAlbumListView {
    __weak typeof(self)weakSelf =self;

    AUIPhotoAlbumListView *albumListView = [[AUIPhotoAlbumListView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.av_width, self.contentView.av_height) withAlbumModelList:self.photoAlbumArray withSelectedBlock:^(AUIPhotoAlbumModel * _Nonnull selectedModel) {
        [weakSelf fetchAlbumAssets:selectedModel];
        [weakSelf.pickerTitleView setSelected:NO];
    }];
    self.albumListView = albumListView;
    [self.contentView addSubview:self.albumListView];

    self.pickerTitleView.userInteractionEnabled = NO;
    [self.albumListView appear:^{
        weakSelf.pickerTitleView.userInteractionEnabled = YES;
    }];
}

- (void)closeAlbumListView {
    
    __weak typeof(self)weakSelf =self;
    self.pickerTitleView.userInteractionEnabled = NO;
    [self.albumListView disappear:^{
        [weakSelf.albumListView removeFromSuperview];
        weakSelf.albumListView = nil;
        weakSelf.pickerTitleView.userInteractionEnabled = YES;
    }];
}

#pragma mark - Tab

- (void)onTabChanged:(AUIPhotoPickerTabType)tabType {
    
    self.currentTabType = tabType;
    [self.collectionView reloadData];
}

@end
