//
//  AUIVideoEditorBaseEffectView.m
//  AlivcUgsvDemo
//
//  Created by coder.pi on 2022/6/23.
//

#import "AUIVideoEditorBaseEffectView.h"
#import "AUIUgsvMacro.h"
#import "Masonry.h"

@interface AUIVideoEditorBaseEffectCell : UICollectionViewCell
@property (nonatomic, strong) id<AUIVideoEditorBaseEffectInfo> info;
@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *flagView;
@end
#define kCellIdentifier @"AUIVideoBaseEffectCell"

@interface AUIVideoEditorBaseEffectView ()<UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong) UICollectionView *collectionView;
@end

@implementation AUIVideoEditorBaseEffectView

// MARK: - Model
- (void)setInfos:(NSArray<id<AUIVideoEditorBaseEffectInfo>> *)infos {
    _infos = infos.copy;
    [_collectionView reloadData];
}

- (BOOL)selectWithType:(NSInteger)type {
    for (int i = 0; i < self.infos.count; ++i) {
        if (self.infos[i].effectType == type) {
            NSInteger originType = self.current.effectType;
            self.current = self.infos[i];
            if (originType != type || self.collectionView.indexPathsForSelectedItems.count == 0) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                [self.collectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionLeft];
            }
            return YES;
        }
    }
    return NO;
}

// MARK: - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self setCurrent:self.infos[indexPath.row] needNotify:YES];
}

- (void)setCurrent:(id<AUIVideoEditorBaseEffectInfo> _Nonnull)current needNotify:(BOOL)needNotify {
    if (_current == current || _current.effectType == current.effectType) {
        return;
    }
    _current = current;
    if (self.onSelectDidChanged && needNotify) {
        self.onSelectDidChanged(_current);
    }
}

- (void)setCurrent:(id<AUIVideoEditorBaseEffectInfo> _Nonnull)current {
    [self setCurrent:current needNotify:NO];
}

// MARK: - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.infos.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AUIVideoEditorBaseEffectCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentifier forIndexPath:indexPath];
    cell.info = self.infos[indexPath.row];
    return cell;
}

- (UIEdgeInsets)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0); // top, left, bottom, right
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
}

// MARK: - UI
- (void)setup {
    // clear
    [_collectionView removeFromSuperview];
    
    // create
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.itemSize = CGSizeMake(52, 64);
    layout.sectionInset = UIEdgeInsetsZero;
    layout.minimumInteritemSpacing = 0.0;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.showsVerticalScrollIndicator = NO;
    _collectionView.backgroundColor = UIColor.clearColor;
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [_collectionView registerClass:AUIVideoEditorBaseEffectCell.class
        forCellWithReuseIdentifier:kCellIdentifier];
    [self addSubview:_collectionView];
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    // update
    self.backgroundColor = UIColor.clearColor;
    [_collectionView reloadData];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

@end

// MARK: -Cell
@implementation AUIVideoEditorBaseEffectCell

- (void)setInfo:(id<AUIVideoEditorBaseEffectInfo>)info {
    _info = info;
    [self updateUI];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    [self updateSelection];
}

- (void)setup {
    // clear
    [_iconView removeFromSuperview];
    [_titleLabel removeFromSuperview];
    [_flagView removeFromSuperview];
    
    // create
    _iconView = [UIImageView new];
    [self.contentView addSubview:_iconView];
    [_iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(24.0);
        make.centerX.equalTo(self.contentView);
        make.top.equalTo(self.contentView);
    }];
    
    _titleLabel = [UILabel new];
    _titleLabel.font = AVGetRegularFont(12.0);
    _titleLabel.numberOfLines = 0;
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.textColor = AUIFoundationColor(@"text_strong");
    [self.contentView addSubview:_titleLabel];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.contentView);
        make.centerX.equalTo(self.contentView);
        make.top.equalTo(_iconView.mas_bottom);
        make.bottom.equalTo(self.contentView);
    }];
    
    _flagView = [UIView new];
    _flagView.layer.cornerRadius = 2.0;
    _flagView.layer.masksToBounds = YES;
    [self.contentView addSubview:_flagView];
    [_flagView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(4.0);
        make.centerX.equalTo(self.contentView);
        make.top.equalTo(_titleLabel.mas_bottom).inset(6.0);
    }];

    // update
    self.backgroundColor = UIColor.clearColor;
    [self updateUI];
}

- (void)updateSelection {
    BOOL hasModify = NO;
    if ([_info respondsToSelector:@selector(flagModify)]) {
        hasModify = _info.flagModify;
    }
    _flagView.hidden = (!self.isSelected && !hasModify);
    if (self.isSelected) {
        _flagView.backgroundColor = AUIFoundationColor(@"colourful_fill_strong");
    }
    else {
        _flagView.backgroundColor = AUIFoundationColor(@"fill_strong");
    }
}

- (void)updateUI {
    _iconView.image = _info.icon;
    _titleLabel.text = _info.title;
    [self updateSelection];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

@end
