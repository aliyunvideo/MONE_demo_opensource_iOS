//
//  AUIVideoTemplateEditBar.m
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/9/22.
//

#import "AUIVideoTemplateEditBar.h"
#import "AUIVideoTemplateEditItem.h"
#import "AUIVideoTemplateEditCell.h"
#import "AUIVideoTemplateEditMenuItem.h"
#import "AUIVideoTemplatePopMenuItem.h"
#import "AUIVideoTemplateEditTextInput.h"

#import "AUIFoundation.h"
#import "AUIUgsvMacro.h"
#import "AUIPhotoPicker.h"
#import "AUIMusicPicker.h"
#import "AUIVideoCropManager.h"
#import "AUIUgsvPath.h"

@interface AUIVideoTemplateEditBar () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, copy) NSArray<AUIVideoTemplateEditItemProtocol> *items;
@property (nonatomic, copy) NSArray<NSArray<AUIVideoTemplateEditItemProtocol> *> *allItems;
@property (nonatomic, strong) id<AUIVideoTemplateEditItemProtocol> currentItem;

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) AUIVideoTemplateEditMenuBar *menuBar;

@end

@implementation AUIVideoTemplateEditBar


- (instancetype)initWithFrame:(CGRect)frame editItems:(NSArray<NSArray<AUIVideoTemplateEditItemProtocol> *> *)editItems {
    self = [super initWithFrame:frame];
    if (self) {
        _allItems = editItems;

        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.backgroundColor = AUIFoundationColor(@"bg_weak");
    
    __weak typeof(self) weakSelf = self;
    self.menuBar = [[AUIVideoTemplateEditMenuBar alloc] initWithFrame:CGRectMake(0, self.av_height - AVSafeBottom - 58, self.av_width, 58) itemTypes:@[@(AUIVideoTemplateEditMenuTypeMedia),@(AUIVideoTemplateEditMenuTypeText),@(AUIVideoTemplateEditMenuTypeMusic)] selectedBlock:^(AUIVideoTemplateEditMenuType type) {
        [weakSelf reset];
    }];
    [self addSubview:self.menuBar];
        
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), self.menuBar.av_top) collectionViewLayout:layout];
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self addSubview:self.collectionView];
    [self.collectionView registerClass:[AUIVideoTemplateEditCell class] forCellWithReuseIdentifier:@"AUIVideoTemplateEditCell"];
    
    [self reset];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.menuBar.selectedType == AUIVideoTemplateEditMenuTypeMusic) {
        return CGSizeMake(74, 74);
    }
    return CGSizeMake(52, 52);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    if (self.menuBar.selectedType == AUIVideoTemplateEditMenuTypeMusic) {
        return 1;
    }
    return 17;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    if (self.menuBar.selectedType == AUIVideoTemplateEditMenuTypeMusic) {
        CGFloat left = (self.collectionView.av_width - 74 * 3 - 1 * 2) / 2;
        return UIEdgeInsetsMake(42, left, 20, 20);
    }
    return UIEdgeInsetsMake(42, 20, 42, 20);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.items.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AUIVideoTemplateEditCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AUIVideoTemplateEditCell" forIndexPath:indexPath];
    id<AUIVideoTemplateEditItemProtocol> item = [self.items objectAtIndex:indexPath.row];
    [cell updateItem:item];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    id<AUIVideoTemplateEditItemProtocol> item = [self.items objectAtIndex:indexPath.row];
    
    if (item.itemMusic) {
        [self onSelectedMusicItem:item.itemMusic];
        return;
    }
    
    if (item.itemMedia) {
        if (item != self.currentItem) {
            self.currentItem.selected = NO;
            self.currentItem = item;
            self.currentItem.selected = YES;
            if (self.selectedAssetBlock) {
                self.selectedAssetBlock(item);
            }
        }
        [self onSelectMediaItem:self.currentItem.itemMedia onView:[self.collectionView cellForItemAtIndexPath:indexPath]];
        return;
    }
    if (item.itemText) {
        if (item != self.currentItem) {
            self.currentItem.selected = NO;
            self.currentItem = item;
            self.currentItem.selected = YES;
            if (self.selectedAssetBlock) {
                self.selectedAssetBlock(item);
            }
        }
        else {
            [self onEditTextItem:item.itemText];
        }
    }
}

- (void)reset {
    [self clearSelectedNode];
    if (self.menuBar.selectedType == AUIVideoTemplateEditMenuTypeMedia) {
        self.items = [self.allItems objectAtIndex:0];
    }
    else if (self.menuBar.selectedType == AUIVideoTemplateEditMenuTypeText) {
        self.items = [self.allItems objectAtIndex:1];
    }
    else {
        self.items = [self.allItems objectAtIndex:2];
    }
    [self.collectionView reloadData];
}

- (void)clearSelectedNode {
    self.currentItem.selected = NO;
    self.currentItem = nil;
    if (self.selectedAssetBlock) {
        self.selectedAssetBlock(nil);
    }
}

- (void)onSelectMediaItem:(AUIVideoTemplateEditItemMedia *)item onView:(UIView *)onView {
    if (!item) {
        return;
    }
    
    __weak typeof(self) weakSelf =self;
    [AUIVideoTemplatePopMenuBar show:onView canCrop:item.isReplaced canDelete:item.isReplaced clickItemBlock:^(AUIVideoTemplateEditMenuType menuType) {
        
        if (menuType == AUIVideoTemplateEditMenuTypePopReplace) {
            AUIPhotoPicker *picker = [[AUIPhotoPicker alloc] initWithMaxPickingCount:1 withAllowPickingImage:YES withAllowPickingVideo:YES withTimeRange:kCMTimeRangeZero];
            [picker onSelectionCompleted:^(AUIPhotoPicker * _Nonnull sender, NSArray<AUIPhotoPickerResult *> * _Nonnull results) {
                AUIPhotoPickerResult *pickerResult = results.firstObject;
                if (pickerResult && pickerResult.filePath.length > 0) {
                    [sender dismissViewControllerAnimated:NO completion:^{
                        item.pickerResult = pickerResult;
                        [weakSelf onCropMediaItem:item updateWithoutCrop:YES];
                    }];
                }
                else {
                    [AVAlertController show:AUIUgsvGetString(@"选择的视频出错了或无权限") vc:sender];
                }
            } withOutputDir:[AUIUgsvPath cacheDir]];
            [UIViewController.av_topViewController av_presentFullScreenViewController:picker animated:YES completion:nil];
            return;
        }
        
        if (menuType == AUIVideoTemplateEditMenuTypePopCrop) {
            [weakSelf onCropMediaItem:item updateWithoutCrop:NO];
            return;
        }
        
        if (menuType == AUIVideoTemplateEditMenuTypePopDelete) {
            [AVAlertController showWithTitle:AUIUgsvGetString(@"是否删除当前已替换的素材？") message:@"" needCancel:YES onCompleted:^(BOOL isCanced) {
                if (!isCanced) {
                    [item updateClip:nil cover:nil];
                    if (weakSelf.editAssetBlock) {
                        weakSelf.editAssetBlock(item);
                    }
                }
            }];
            return;
        }
    }];
}

- (void)onCropMediaItem:(AUIVideoTemplateEditItemMedia *)item updateWithoutCrop:(BOOL)updateWithoutCrop {
    if (!item || !item.pickerResult) {
        return;
    }
    
    AUIVideoCutterParam *param = [AUIVideoCutterParam new];
    param.inputPath = item.pickerResult.filePath;
    param.isImage = item.pickerResult.model.type == AUIPhotoAssetTypePhoto;
    param.outputAspectRatio = item.asset.editRect.size;
    param.outputDuration = MIN(item.pickerResult.model.assetDuration, item.duration);
    
    __weak typeof(self) weakSelf =self;
    [AUIVideoCropManager cropOnCutter:param cancelBlock:^{
        if (updateWithoutCrop) {
            [item updateClip:item.pickerResult.filePath cover:item.pickerResult.model.thumbnailImage];
            if (weakSelf.editAssetBlock) {
                weakSelf.editAssetBlock(item);
            }
        }
    } completedBlock:^(NSString * _Nonnull outputPath) {
        [item updateClip:outputPath cover:item.pickerResult.model.thumbnailImage];
        if (weakSelf.editAssetBlock) {
            weakSelf.editAssetBlock(item);
        }
    }];
}

- (void)onEditTextItem:(AUIVideoTemplateEditItemText *)item {
    if (!item) {
        return;
    }
    __weak typeof(self) weakSelf =self;
    [AUIVideoTemplateEditTextInput show:item.text completed:^(NSString * _Nonnull inputText) {
        [item updateText:inputText];
        if (weakSelf.editAssetBlock) {
            weakSelf.editAssetBlock(item);
        }
    }];
}

- (void)onSelectedMusicItem:(AUIVideoTemplateEditItemMusic *)item {
    if (!item) {
        return;
    }
    if (item.selected && item.musicType != AUIVideoTemplateEditMusicTypeCustom) {
        return;
    }
    
    __weak typeof(self) weakSelf =self;
    [self.player pause];
    if (item.musicType == AUIVideoTemplateEditMusicTypeNone) {
        [AVAlertController showWithTitle:AUIUgsvGetString(@"确定是否 不设置音乐？") message:@"" needCancel:YES onCompleted:^(BOOL isCanced) {
            if (!isCanced) {
                if (weakSelf.selectedMusicBlock) {
                    weakSelf.selectedMusicBlock(@"");
                    [weakSelf updateMusicCustomSelectedModel:nil];
                    [weakSelf updateMusicSelected:AUIVideoTemplateEditMusicTypeNone];
                }
            }
        }];
    }
    else if (item.musicType == AUIVideoTemplateEditMusicTypeTemplate) {
        [AVAlertController showWithTitle:AUIUgsvGetString(@"确定使用模板音乐？") message:@"" needCancel:YES onCompleted:^(BOOL isCanced) {
            if (!isCanced) {
                if (weakSelf.selectedMusicBlock) {
                    weakSelf.selectedMusicBlock(nil);
                    [weakSelf updateMusicCustomSelectedModel:nil];
                    [weakSelf updateMusicSelected:AUIVideoTemplateEditMusicTypeTemplate];
                }
            }
        }];
    }
    else {
        UIViewController *vc = UIViewController.av_topViewController;
        AUIMusicPicker *musicPicker = [AUIMusicPicker present:vc.view
                                               selectedModel:item.selectedModel
                                               limitDuration:self.player.duration
                                                showCropView:NO
                                            onSelectedChange:nil onShowChanged:nil];
        [musicPicker.menuButton setImage:AUIUgsvTemplateImage(@"ic_music_picker") forState:UIControlStateNormal];
        musicPicker.showMenuButton = YES;
        musicPicker.onMenuClicked = ^(AUIMusicPicker * _Nonnull picker) {
            [picker hide];
            AUIMusicSelectedModel *model = picker.currentSelected;
            if (model && weakSelf.selectedMusicBlock) {
                weakSelf.selectedMusicBlock(model.localPath);
                [weakSelf updateMusicCustomSelectedModel:model];
                [weakSelf updateMusicSelected:AUIVideoTemplateEditMusicTypeCustom];
            }
        };
    }
}

- (void)updateMusicCustomSelectedModel:(AUIMusicSelectedModel *)model {
    NSArray<AUIVideoTemplateEditItemMusic *> *musicItems = [self.allItems objectAtIndex:2];
    AUIVideoTemplateEditItemMusic *customItem = [musicItems objectAtIndex:AUIVideoTemplateEditMusicTypeCustom];
    [customItem updateMusicCustomSelectedModel:model];
}

- (void)updateMusicSelected:(AUIVideoTemplateEditMusicType)musicType {
    NSArray<AUIVideoTemplateEditItemMusic *> *musicItems = [self.allItems objectAtIndex:2];
    [musicItems enumerateObjectsUsingBlock:^(AUIVideoTemplateEditItemMusic * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.selected = obj.musicType == musicType;
    }];
}

@end
