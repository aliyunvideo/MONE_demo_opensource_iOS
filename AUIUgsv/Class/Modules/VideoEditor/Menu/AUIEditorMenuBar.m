//
//  AUIEditorMenuBar.m
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/5/30.
//

#import "AUIEditorMenuBar.h"
#import "AUIEditorMenuManager.h"
#import "AUIFoundation.h"
#import "AUIUgsvMacro.h"
#import "AUIVolumePanel.h"
#import "AUIMusicPicker.h"

@interface AUIEditorMenuBarCell : UICollectionViewCell

@property (nonatomic, strong) AUIEditorMenuItem *item;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *iconView;


@end


@implementation AUIEditorMenuBarCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        titleLabel.font = AVGetRegularFont(12.0);
        titleLabel.textColor = AUIFoundationColor(@"text_strong");
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:titleLabel];
        _titleLabel = titleLabel;
        
        UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:iconView];
        _iconView = iconView;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.iconView.frame = CGRectMake((self.contentView.av_width - 24) / 2.0, 0, 24, 24);
    
    [self.titleLabel sizeToFit];
    CGFloat titleWidth = MAX(self.contentView.av_width, self.titleLabel.av_width);
    self.titleLabel.frame = CGRectMake((self.contentView.av_width - titleWidth) / 2.0, self.contentView.av_height - 18, titleWidth, 18);
}

- (void)updateItem:(AUIEditorMenuItem *)item {
    self.item = item;
    self.titleLabel.text = self.item.text;
    self.iconView.image = AUIUgsvEditorImage(self.item.icon);
    [self setNeedsLayout];
}

@end

@interface AUIEditorMenuBar () <UICollectionViewDataSource, UICollectionViewDelegate, AUIEditorSelectionObserver, AUIEditorActionObserver>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) AUIEditorMenuManager *manager;
@property (nonatomic, strong, readonly) AUIEditorMenuGroup *group;

@end

@interface AUIEditorMenuBar(Music_Volume)
- (void)showMusicPanel;
@end

@implementation AUIEditorMenuBar

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = AUIFoundationColor(@"bg_weak");
        self.manager = [AUIEditorMenuManager new];
        [self setupUI];
    }
    return self;
}

- (AUIEditorMenuGroup *)group {
    return self.manager.currentGroup;
}

- (void)setupUI {
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.av_width, 1)];
    lineView.backgroundColor = AUIFoundationColor(@"border_infrared");
    [self addSubview:lineView];
    
    NSInteger count = 6;
    CGFloat itemMargin = 10;
    CGFloat margin = 20;
    CGFloat itemHeight = 54;
    CGFloat itemWidth = (self.av_width - margin * 2 - itemMargin * (count - 1)) / count;
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(itemWidth, itemHeight);
    layout.minimumInteritemSpacing = itemMargin;
    layout.sectionInset = UIEdgeInsetsMake(0, margin, 0, margin);
    
    self.collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 30, self.av_width, itemHeight) collectionViewLayout:layout];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self.collectionView registerClass:[AUIEditorMenuBarCell class] forCellWithReuseIdentifier:@"AUIEditorMenuBarCell"];
    self.collectionView.backgroundColor = UIColor.clearColor;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.alwaysBounceHorizontal = NO;
    [self addSubview:self.collectionView];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.group.items.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AUIEditorMenuBarCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AUIEditorMenuBarCell" forIndexPath:indexPath];
    [cell updateItem:[self.group.items objectAtIndex:indexPath.row]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    AUIEditorMenuItem *item = [self.group.items objectAtIndex:indexPath.row];
    
    if (!item.enable) {
        return;
    }
    
    switch (item.type) {
        case AUIEditorMenuItemTypeVideo:
        {
            [self.actionManager.currentOperator enterVideoMode];
        }
            break;
        case AUIEditorMenuItemTypeAudio:
        {
            [self showMusicPanel];
        }
            break;
        case AUIEditorMenuItemTypeCaption:
        {
            [self.actionManager.currentOperator enterCaptionMode];
        }
            break;
        case AUIEditorMenuItemTypeSticker:
        {
            [self.actionManager.currentOperator enterStickerMode];
        }
            break;
        case AUIEditorMenuItemTypeFilter:
        {
            [self.actionManager.currentOperator enterFilterMode];
        }
            break;
        case AUIEditorMenuItemTypeEffect:
        {
            [self.actionManager.currentOperator enterEffectMode];
        }
            break;
        default:
            break;
    }
}

#pragma mark - Selection

- (void)setSelectionManager:(AUIEditorSelectionManager *)selectionManager {
    if (selectionManager != _selectionManager) {
        [_selectionManager removeObserver:self];
        _selectionManager = nil;
    }
    if (selectionManager) {
        _selectionManager = selectionManager;
        [_selectionManager addObserver:self];
    }
}

- (void)selectionManager:(AUIEditorSelectionManager *)manger didSelected:(AUIEditorSelectionObject *)selectionObject {
    //
}

- (void)selectionManagerDidUnselected:(AUIEditorSelectionManager *)manger {
    //
}

#pragma mark - Action

- (void)setActionManager:(AUIEditorActionManager *)actionManager {
    if (actionManager != _actionManager) {
        [_actionManager removeObserver:self];
        _actionManager = nil;
    }
    if (actionManager) {
        _actionManager = actionManager;
        [_actionManager addObserver:self];
    }
}

- (void)actionItem:(AUIEditorActionItem *)item doActionResult:(NSError *)error  retObject:(id)retObject {
    
}

@end

// MARK: - Music & volume
static NSString * const MusicModelAssociatedKey = @"music_selected_model";
@implementation AUIEditorMenuBar(Music_Volume)

- (void)showVolumePanel {
    __weak typeof(self) weakSelf = self;
    AUIVolumePanel *panel = [AUIVolumePanel presentWithActionManager:self.actionManager];
    panel.onShowChanged = ^(AVBaseControllPanel * _Nonnull sender) {
        if (!sender.isShowing) {
            [weakSelf showMusicPanel];
        }
    };
}

- (void)showMusicPanel {
    id<AUIEditorActionOperator> operator = self.actionManager.currentOperator;
    AUIMusicSelectedModel *model = [self.class selectedModel:operator];
    NSTimeInterval duration = operator.currentPlayer.duration;
    
    AUIMusicPicker *picker = [AUIMusicPicker present:operator.currentVC.view selectedModel:model limitDuration:duration onSelectedChange:^(AUIMusicSelectedModel * _Nullable model) {
        
        [self.class onSelectMusicModel:model operator:operator];
        
    } onShowChanged:^(BOOL isShow) {
        if (!isShow) {
            [self.class onClosePicker:operator];
        }
        else {
            [self.class onOpenPicker:operator selectedModel:model];
        }
    }];
    __weak typeof(self) weakSelf = self;
    [picker.menuButton setImage:AUIUgsvEditorImage(@"ic_menu_volume") forState:UIControlStateNormal];
    picker.showMenuButton = YES;
    picker.onMenuClicked = ^(AUIMusicPicker * _Nonnull picker) {
        [picker hide];
        [weakSelf showVolumePanel];
    };
    picker.player = operator.currentPlayer;
}

+ (AUIMusicSelectedModel *)selectedModel:(id<AUIEditorActionOperator>)operator {
    
    return (AUIMusicSelectedModel *)[operator associatedObjectForKey:MusicModelAssociatedKey];
}

+ (void)onSelectMusicModel:(AUIMusicSelectedModel *)model operator:(id<AUIEditorActionOperator>)operator {
    
    [operator.currentPlayer pause];
    [operator.currentEditor removeMusics];
    
    if (model) {
        NSAssert(model.localPath.length > 0, @"Music has not download yet");
        AliyunEffectMusic *music = [[AliyunEffectMusic alloc] initWithFile:model.localPath];
        music.startTime = model.beginTime;
        [operator.currentEditor applyMusic:music];
        
        operator.currentPlayer.rangePlayOffset = -model.beginTime;
    }
    else {
        [operator.currentPlayer play];
    }
    [operator setAssociatedObject:model forKey:MusicModelAssociatedKey];
}

+ (void)onOpenPicker:(id<AUIEditorActionOperator>)operator selectedModel:(AUIMusicSelectedModel *)model {
    operator.currentPlayer.rangePlayOffset = -model.beginTime;
}


+ (void)onClosePicker:(id<AUIEditorActionOperator>)operator {
    operator.currentPlayer.rangePlayOffset = 0;
    [operator.currentPlayer disablePlayInRange];
}
@end
