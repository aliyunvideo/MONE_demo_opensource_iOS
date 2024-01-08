//
//  AUILiveSegmentPanel.m
//  OpensslTest
//
//  Created by ISS013602000846 on 2022/11/8.
//

#import "AUILiveSegmentPanel.h"

#define kItemTagBase 100

#pragma AUILiveSegmentPanelContentCell
@interface AUILiveSegmentPanelContentCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageTopView;
@property (nonatomic, strong) UILabel *titleBottomView;
@property (nonatomic, assign) BOOL haveImage;

@end

@implementation AUILiveSegmentPanelContentCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self.contentView addSubview:self.imageTopView];
        [self.contentView addSubview:self.titleBottomView];
    }
    return self;
}

- (void)setImageStatus:(BOOL)haveImage {
    self.haveImage = haveImage;
    if (haveImage) {
        _imageTopView.frame = CGRectMake((CGRectGetWidth(self.frame) - 32) / 2.0, (60 - 12 - 12 - 32) / 2.0, 32, 32);
        _titleBottomView.frame = CGRectMake(0, 60 - 20, CGRectGetWidth(self.frame), 20);
    } else {
        _imageTopView.frame = CGRectZero;
        _titleBottomView.frame = CGRectMake(0, (CGRectGetHeight(self.frame) - 20) / 2.0, CGRectGetWidth(self.frame), 20);
    }
}

- (void)setImage:(NSString *)name imagePath:(NSString *)imagePath title:(NSString *)title titlePath:(NSString *)titlePath {
    if (self.haveImage) {
        if (imagePath && imagePath.length > 0) {
            NSBundle *bundle = [NSBundle bundleWithPath:imagePath];
            self.imageTopView.image = [[UIImage imageNamed:[NSString stringWithFormat:@"%@", name] inBundle:bundle compatibleWithTraitCollection:nil] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        } else {
            self.imageTopView.image = [[UIImage imageNamed:name] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        }
    }
    
    if (titlePath && titlePath.length > 0) {
        NSBundle *bundle = [NSBundle bundleWithPath:titlePath];
        self.titleBottomView.text = NSLocalizedStringFromTableInBundle(title, nil, bundle, nil);
    } else {
        self.titleBottomView.text = NSLocalizedString(title, nil);
    }
}

- (void)updateStatus:(BOOL)selected {
    if (selected) {
        if (self.haveImage) {
            self.imageTopView.tintColor = AUILiveCommonColor(@"ir_segment_selected");
        }
        self.titleBottomView.textColor = AUILiveCommonColor(@"ir_segment_selected");
    } else {
        if (self.haveImage) {
            self.imageTopView.tintColor = AUIFoundationColor(@"text_weak");
        }
        self.titleBottomView.textColor = AUIFoundationColor(@"text_weak");
    }
}

- (UIImageView *)imageTopView {
    if (!_imageTopView) {
        _imageTopView = [[UIImageView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.frame) - 32) / 2.0, (60 - 12 - 12 - 32) / 2.0, 32, 32)];
    }
    return _imageTopView;
}

- (UILabel *)titleBottomView {
    if (!_titleBottomView) {
        _titleBottomView = [[UILabel alloc] initWithFrame:CGRectMake(0, 60 - 20, CGRectGetWidth(self.frame), 20)];
        _titleBottomView.textColor = AUIFoundationColor(@"text_weak");
        _titleBottomView.font = AVGetRegularFont(10);
        _titleBottomView.textAlignment = NSTextAlignmentCenter;
    }
    return _titleBottomView;
}

@end


#pragma AUILiveSegmentPanel
@interface AUILiveSegmentPanel ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UIView *fatherView;
@property (nonatomic, strong) NSArray<NSString *> *items;
@property (nonatomic, strong) NSMutableArray *contentWidths;
@property (nonatomic, assign) BOOL animation;

@property (nonatomic, strong) UIScrollView *itemScrollView;
@property (nonatomic, strong) UICollectionView *contentCollectionView;
@property (nonatomic, strong) UIView *itemBar;

@property (nonatomic, assign) NSInteger selectedItemIndex;
@property (nonatomic, strong) NSMutableArray *itemSelectedContentIndexs;

@end

@implementation AUILiveSegmentPanel

- (instancetype)initWithView:(UIView *)view items:(NSArray<NSString *> *)items animation:(BOOL)animation {
    if (self = [super init]) {
        self.fatherView = view;
        self.frame = CGRectMake(0, CGRectGetHeight(view.frame), CGRectGetWidth(view.frame), 150);
        [self addSubview:self.itemScrollView];
        [self.itemScrollView addSubview:self.itemBar];
        
        self.items = items;
        
        self.contentWidths = [NSMutableArray array];
        
        self.animation = animation;
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.itemScrollView.frame), CGRectGetWidth(self.frame), 1)];
        line.backgroundColor = AUIFoundationColor(@"border_infrared");
        [self addSubview:line];
        
        [self addSubview:self.contentCollectionView];
        [self.contentCollectionView registerClass:[AUILiveSegmentPanelContentCell class] forCellWithReuseIdentifier:@"AUILiveSegmentPanelContentCell"];
        self.hidden = YES;
        
        [view addSubview:self];
    }
    return self;
}

- (void)show {
    self.hidden = NO;
    if (self.animation) {
        [UIView animateWithDuration:0.1 animations:^{
            CGRect selfFrame = self.frame;
            selfFrame.origin.y = CGRectGetHeight(self.fatherView.frame) - 150;
            self.frame = selfFrame;
        }];
    } else {
        CGRect selfFrame = self.frame;
        selfFrame.origin.y = CGRectGetHeight(self.fatherView.frame) - 150;
        self.frame = selfFrame;
    }
}

- (void)hide {
    if (self.animation) {
        [UIView animateWithDuration:0.1 animations:^{
            CGRect selfFrame = self.frame;
            selfFrame.origin.y = CGRectGetHeight(self.fatherView.frame);
            self.frame = selfFrame;
        }];
    } else {
        CGRect selfFrame = self.frame;
        selfFrame.origin.y = CGRectGetHeight(self.fatherView.frame);
        self.frame = selfFrame;
    }
    self.hidden = YES;
}

- (BOOL)isShow {
    return self.frame.origin.y < CGRectGetHeight(self.fatherView.frame);
}

- (NSArray<NSNumber *> *)getItemSelectedContentIndexs {
    return self.itemSelectedContentIndexs;
}

- (void)pressItem:(UIButton *)sender {
    NSInteger itemIndex = sender.tag - kItemTagBase;
    if (self.selectedItemIndex != itemIndex) {
        UIButton *lastSelectedItem = [self.itemScrollView viewWithTag:kItemTagBase + self.selectedItemIndex];
        [lastSelectedItem setTitleColor:AUIFoundationColor(@"text_strong") forState:UIControlStateNormal];
        
        [sender setTitleColor:AUILiveCommonColor(@"ir_segment_selected") forState:UIControlStateNormal];
        
        self.selectedItemIndex = itemIndex;
        [UIView animateKeyframesWithDuration:0.1
                                       delay:0.0
                                     options:UIViewKeyframeAnimationOptionLayoutSubviews
                                  animations:^{
            CGRect itemBarFrame = self.itemBar.frame;
            itemBarFrame.origin.x = sender.frame.origin.x;
            itemBarFrame.size.width = sender.frame.size.width;
            self.itemBar.frame = itemBarFrame;
        }
                                  completion:nil];
        
        [self.contentCollectionView reloadData];
    }
}

- (void)setItems:(NSArray<NSString *> *)items {
    _items = items;
    
    self.itemSelectedContentIndexs = [NSMutableArray array];
    
    BOOL itemHasScrollStatus = items.count > 4;
    CGFloat itemNotScrollWidth = (CGRectGetWidth(self.frame) - 24 * (items.count + 1)) / items.count;
    CGFloat currentItemWidth = 24;
    for (int i = 0; i < items.count; i++) {
        NSString *title = items[i];
        UIButton *itemButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [itemButton setTitle:title forState:UIControlStateNormal];
        [itemButton setTitleColor:AUIFoundationColor(@"text_strong") forState:UIControlStateNormal];
        itemButton.titleLabel.font = AVGetRegularFont(12);
        [itemButton addTarget:self action:@selector(pressItem:) forControlEvents:UIControlEventTouchUpInside];

        CGFloat itemTextWidth = 0;
        if (!itemHasScrollStatus) {
            itemTextWidth = itemNotScrollWidth;
        } else {
            itemTextWidth = [itemButton sizeThatFits:CGSizeMake(MAXFLOAT, 43)].width;
        }
        itemButton.frame = CGRectMake(currentItemWidth, 0, itemTextWidth, 43);
        itemButton.tag = kItemTagBase + i;
        [self.itemScrollView addSubview:itemButton];
        
        if (i == 0) {
            [itemButton setTitleColor:[UIColor cyanColor] forState:UIControlStateNormal];
            
            CGRect itemBarFrame = self.itemBar.frame;
            itemBarFrame.origin.x = currentItemWidth;
            itemBarFrame.size.width = itemTextWidth;
            self.itemBar.frame = itemBarFrame;
        }
        
        currentItemWidth = currentItemWidth + itemTextWidth + 24;
        if (i == items.count - 1) {
            self.itemScrollView.contentSize = CGSizeMake(currentItemWidth, 45);
        }
        
        [self.itemSelectedContentIndexs addObject:@(0)];
        
    }
}

- (NSString *)displayText:(NSString *)key {
    BOOL haveContentTitlePath = self.contentTitlePath && self.contentTitlePath.length > 0;
    if (haveContentTitlePath) {
        NSBundle *bundle = [NSBundle bundleWithPath:self.contentTitlePath];
        return NSLocalizedStringFromTableInBundle(key, nil, bundle, nil);
    }
    return key;
}

- (void)setContents:(NSArray<NSArray *> *)contents {
    _contents = contents;
    if (contents && contents.count > 0 && contents.count == self.items.count) {
        [self.contentCollectionView reloadData];
    }
    
    self.contentWidths = [NSMutableArray array];
    for (int i = 0; i < contents.count; i++) {
        NSMutableArray *contentWidthArr = [NSMutableArray array];
        for (int j = 0; j < contents[i].count; j++) {
            NSString *title = contents[i][j][@"title"];
            UILabel *label = [[UILabel alloc] init];
            label.text = [self displayText:title];
            label.font = AVGetRegularFont(10);
            CGSize size = [label sizeThatFits:CGSizeMake(MAXFLOAT, 20)];
            CGFloat width = size.width;
            if (size.width < 55) {
                width = 55;
            }
            [contentWidthArr addObject:@(width)];
        }
        [self.contentWidths addObject:contentWidthArr];
    }
}

#pragma mark -- UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.contents[self.selectedItemIndex].count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AUILiveSegmentPanelContentCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AUILiveSegmentPanelContentCell" forIndexPath:indexPath];
    
    NSArray *content = self.contents[self.selectedItemIndex];
    BOOL haveImage = [[content[indexPath.row] allKeys] containsObject:@"image"] && [content[indexPath.row][@"image"] length] > 0;
    [cell setImageStatus:haveImage];
    [cell setImage:content[indexPath.row][@"image"] imagePath:self.contentImagePath title:content[indexPath.row][@"title"] titlePath:self.contentTitlePath];
    [cell updateStatus:indexPath.row == [self.itemSelectedContentIndexs[self.selectedItemIndex] integerValue]];
    
    return cell;
}

#pragma mark -- UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger selectedContentIndex = [self.itemSelectedContentIndexs[self.selectedItemIndex] integerValue];
    if (selectedContentIndex != indexPath.row) {
        self.itemSelectedContentIndexs[self.selectedItemIndex] = @(indexPath.row);
        [self.contentCollectionView reloadData];
        if (self.selectContent) {
            self.selectContent(self.selectedItemIndex, indexPath.row);
        }
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = [self.contentWidths[self.selectedItemIndex][indexPath.item] floatValue];
    return CGSizeMake(width, 60);
}

#pragma mark -- UICollectionViewDelegateFlowLayout
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 15;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 15, 0, 15);
}

- (UIScrollView *)itemScrollView {
    if (!_itemScrollView) {
        _itemScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), 45)];
        _itemScrollView.showsHorizontalScrollIndicator = NO;
        _itemScrollView.directionalLockEnabled = YES;
    }
    return _itemScrollView;
}

- (UIView *)itemBar {
    if (!_itemBar) {
        _itemBar = [[UIView alloc] initWithFrame:CGRectMake(0, 43, 0, 2)];
        _itemBar.backgroundColor = AUILiveCommonColor(@"ir_segment_selected");
    }
    return _itemBar;
}

- (UICollectionView *)contentCollectionView {
    if (!_contentCollectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.headerReferenceSize = CGSizeZero;
        flowLayout.footerReferenceSize = CGSizeZero;
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        _contentCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, self.itemScrollView.av_bottom + 1, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) - (CGRectGetMaxY(self.itemScrollView.frame) + 1)) collectionViewLayout:flowLayout];
        _contentCollectionView.showsHorizontalScrollIndicator = YES;
        _contentCollectionView.dataSource = self;
        _contentCollectionView.delegate = self;
        _contentCollectionView.backgroundColor = self.backgroundColor;
    }
    return _contentCollectionView;
}

@end
