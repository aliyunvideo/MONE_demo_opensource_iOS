//
//  AUITransitionControllPanel.m
//  AlivcUgsvDemo
//
//  Created by mengyehao on 2022/6/23.
//

#import "AUITransitionControllPanel.h"
#import "AUIUgsvMacro.h"
#import "AUITransitionModel.h"
#import "AUIVideoEditorUtils.h"
#import "AUIEditorActionDef.h"
#import "Masonry.h"
#import "AVToastView.h"

static NSString *kAUITransitionViewCell = @"AUITransitionViewCell";

@interface AUITransitionViewCell : UICollectionViewCell
@property (nonatomic ,strong) UILabel *titleLabel;
@property (nonatomic ,strong) UIImageView *iconView;

@end


@implementation AUITransitionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    if (selected) {
        self.contentView.layer.borderColor = AUIFoundationColor(@"colourful_border_strong").CGColor;
        self.contentView.layer.borderWidth = 1.f;
    }
    else {
        self.contentView.layer.borderWidth = 0.f;
    }
}

- (void)setup {
    self.titleLabel.text = AUIUgsvGetString(@"转场");
    [self.contentView addSubview:self.iconView];
    [self.contentView addSubview:self.titleLabel];
}

- (UIImageView *)iconView {
    if (!_iconView) {
        _iconView = [[UIImageView alloc]initWithFrame:CGRectMake((self.contentView.av_width - 24)/2, 2, 24, 24)];
        _iconView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _iconView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.numberOfLines = 1;
        _titleLabel.textColor = AUIFoundationColor(@"text_strong");
        _titleLabel.font = AVGetRegularFont(12);
        _titleLabel.av_left =  0;
        _titleLabel.av_width =  self.contentView.av_width;
        _titleLabel.av_height =  20;
        _titleLabel.av_bottom = self.contentView.av_height;
    }
    return _titleLabel;
}


@end

@interface AUITransitionControllPanel ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray<AUITransitionModel *> *dataList;
@property (nonatomic, assign) NSInteger currentSelectedIndex;

@property (nonatomic, strong) AUIVideoEditorHelperSettingForAll *settingForAll;

@end

@implementation AUITransitionControllPanel

+ (CGFloat)panelHeight {
    return 240 + AVSafeBottom;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.titleView.text = AUIUgsvGetString(@"转场");
        self.showBackButton = YES;
        [self.contentView addSubview:self.collectionView];
        
        __weak typeof(self) weakSelf = self;
        _settingForAll = [AUIVideoEditorHelperSettingForAll SettingForKey:@"Transition_IsSettingForAll" onChanged:^(BOOL isSettingForAll) {
            if (isSettingForAll) {
                [weakSelf onApplyAll];
            }
        }];
        
        [self.contentView addSubview:_settingForAll.button];
        [_settingForAll.button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.contentView);
            make.bottom.equalTo(self.contentView).offset(-(20.0 + AVSafeBottom));
        }];
        
        [self fetchData];
    }
    return self;
}

- (void)setActionManager:(AUIEditorActionManager *)actionManager {
    if (_actionManager == actionManager) {
        return;
    }
    _actionManager = actionManager;
    self.settingForAll.actionOperator = _actionManager.currentOperator;
}

- (void)setCurrentTrackClip:(AEPVideoTrackClip *)currentTrackClip {
    _currentTrackClip = currentTrackClip;
    TransitionType index = [AUITransitionHelper typeWithAepObject:currentTrackClip.transitionEffect];
    [self selectWithIndex:index];
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.minimumInteritemSpacing = 10;
        layout.sectionInset = UIEdgeInsetsMake(0, 12, 0, 0);
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.itemSize = CGSizeMake(48 + 10, 54 + 2);
        
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 20, self.bounds.size.width, 54 + 2) collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        
        [_collectionView registerClass:[AUITransitionViewCell class] forCellWithReuseIdentifier:kAUITransitionViewCell];
    }
    return _collectionView;
}

#pragma mark - CollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AUITransitionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kAUITransitionViewCell forIndexPath:indexPath];
    AUITransitionModel *model = self.dataList[indexPath.row];
    cell.titleLabel.text = model.name;
    
    if (model.isEmpty) {
        cell.iconView.image = AUIUgsvGetImage(@"ic_panel_clear");
    }
    else {
        UIImage *image = AUIUgsvEditorImage(model.iconName);
        cell.iconView.image = image;
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    self.currentSelectedIndex = indexPath.row;
    if (self.settingForAll.isOn) {
        [self onApplyAll];
    }
    else {
        AUITransitionModel *model = self.dataList[self.currentSelectedIndex];
        if (model.type == TransitionTypeNull) {
            AUIEditorTransitionRemoveActionItem *item = [AUIEditorTransitionRemoveActionItem new];
            [item setInputObject:self.currentTrackClip forKey:@"aep"];
            [self.actionManager doAction:item];
        }
        else {
            AliyunTransitionEffect *effct = [AUITransitionHelper transitionEffectWithType:model.type];
            AUIEditorTransitionAddActionItem *item = [AUIEditorTransitionAddActionItem new];
            [item setInputObject:effct forKey:@"transition"];
            [item setInputObject:self.currentTrackClip forKey:@"aep"];
            [self.actionManager doAction:item];
        }
    }
}

#pragma mark - Set

- (void)fetchData {
    self.dataList = [AUITransitionHelper dataList];
    [self.collectionView reloadData];
}
    
- (void)selectWithIndex:(NSUInteger)index {
    if (index >= self.dataList.count) {
        return;
    }
    self.currentSelectedIndex = index;
    NSIndexPath *idxPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.collectionView selectItemAtIndexPath:idxPath animated:YES scrollPosition:UICollectionViewScrollPositionTop];
}


- (void)onApplyAll {
    TransitionType type = [self.dataList objectAtIndex:self.currentSelectedIndex].type;
    AUIEditorTransitionApplyAllActionItem *item = [AUIEditorTransitionApplyAllActionItem new];
    [item setInputObject:@(type) forKey:@"transitionType"];
    [self.actionManager doAction:item];
    
    [AVToastView show:@"已经应用全部" view:self.superview position:AVToastViewPositionMid];
}

+ (AUITrackerClipTransitionData *)transDataNotApply {
    AUITrackerClipTransitionData *data = [[AUITrackerClipTransitionData alloc] initWithIsApply:NO withDuration:1.0 withIcon:AUIUgsvEditorImage(@"ic_transition_none")];
    return data;
}

+ (AUITrackerClipTransitionData *)transDataApplying:(AEPTransitionEffect *)effect speed:(CGFloat)speed {
    if (!effect) {
        return [self transDataNotApply];
    }
    
//    AUITransitionModel *model = [[AUITransitionModel alloc] initWithType:s_defaultIconTypeForEffect(effect)];
//    UIImage *image = AUIUgsvEditorImage(model.iconName);
    UIImage *image = AUIUgsvEditorImage(@"ic_transition_apply");
    AUITrackerClipTransitionData *data = [[AUITrackerClipTransitionData alloc] initWithIsApply:YES withDuration:effect.overlapDuration / speed withIcon:image];
    return data;
}

@end
