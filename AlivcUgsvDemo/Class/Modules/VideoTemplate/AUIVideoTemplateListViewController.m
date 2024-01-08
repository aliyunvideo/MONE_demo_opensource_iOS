//
//  AUIVideoTemplateListViewController.m
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/9/22.
//

#import "AUIVideoTemplateListViewController.h"
#import "AUIVideoTemplateItem.h"
#import "AUIVideoTemplatePreview.h"
#import "AUIUgsvMacro.h"
#import <SDWebImage/SDWebImage.h>

@interface AUIVideoTemplateListGroupData : NSObject

@property (nonatomic, copy) NSString *groupId;
@property (nonatomic, copy) NSString *groupName;
@property (nonatomic, copy) NSString *jsonFileName;

@end

@implementation AUIVideoTemplateListGroupData

+ (AUIVideoTemplateListGroupData *)data:(NSString *)groupId name:(NSString *)groupName json:(NSString *)jsonFileName {
    AUIVideoTemplateListGroupData *data = [AUIVideoTemplateListGroupData new];
    data.groupId = groupId;
    data.groupName = groupName;
    data.jsonFileName = jsonFileName;
    return data;
}

@end

@interface AUIVideoTemplateListGroupView : UIView

@property (nonatomic, strong, readonly) UIScrollView *scrollView;

@property (nonatomic, copy) NSArray<AUIVideoTemplateListGroupData *> *groupDatas;
@property (nonatomic, weak, readonly) AUIVideoTemplateListGroupData *selectedGroupData;

@property (nonatomic, strong, readonly) NSMutableArray<UIButton *> *buttonList;
@property (nonatomic, weak, readonly) UIButton *selectedButton;
@property (nonatomic, strong, readonly) UIView *selectLineView;

@property (nonatomic, copy) void (^onSelectedGroupBlock)(AUIVideoTemplateListGroupData *data);

@end

@implementation AUIVideoTemplateListGroupView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _scrollView = [[UIScrollView alloc] initWithFrame:frame];
        _scrollView.showsVerticalScrollIndicator = NO;
        [self addSubview:_scrollView];
        
        _selectLineView = [[UIView alloc] initWithFrame:CGRectMake(0, _scrollView.av_height - 2, 40, 2)];
        _selectLineView.backgroundColor = AUIFoundationColor(@"fill_infrared");
        _selectLineView.hidden = YES;
        [_scrollView addSubview:_selectLineView];
    }
    return self;
}

- (void)setGroupDatas:(NSArray<AUIVideoTemplateListGroupData *> *)groupDatas {
    _groupDatas = groupDatas;
    
    [_buttonList enumerateObjectsUsingBlock:^(UIButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    _buttonList = [NSMutableArray array];
    
    __block CGFloat left = 20;
    [_groupDatas enumerateObjectsUsingBlock:^(AUIVideoTemplateListGroupData * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton *btn = [self groupButton:obj];
        [btn sizeToFit];
        btn.frame = CGRectMake(left, 0, btn.av_width + 16 + 16, _scrollView.av_height);
        [_buttonList addObject:btn];
        [_scrollView addSubview:btn];
        left += btn.av_width;
    }];
    _scrollView.contentSize = CGSizeMake(MAX(left, _scrollView.av_width), _scrollView.av_height);
    [self onButtonClick:_buttonList.firstObject];
}

- (AUIVideoTemplateListGroupData *)selectedGroupData {
    NSUInteger idx = 0;
    if (_selectedButton) {
        idx = [_buttonList indexOfObject:_selectedButton];
    }
    return [_groupDatas objectAtIndex:idx];
}

- (UIButton *)groupButton:(AUIVideoTemplateListGroupData *)data {
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectZero];
    [btn setTitle:data.groupName forState:UIControlStateNormal];
    [btn setTitleColor:AUIFoundationColor(@"text_medium") forState:UIControlStateNormal];
    [btn setTitleColor:AUIFoundationColor(@"text_strong") forState:UIControlStateSelected];
    btn.titleLabel.font = AVGetRegularFont(14);
    [btn addTarget:self action:@selector(onButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

- (void)onButtonClick:(UIButton *)sender {
    if (_selectedButton == sender) {
        return;
    }
    _selectedButton.selected = NO;
    _selectedButton.titleLabel.font = AVGetRegularFont(14);
    _selectedButton = sender;
    _selectedButton.selected = YES;
    _selectedButton.titleLabel.font = AVGetMediumFont(14);
    _selectLineView.hidden = _selectedButton == nil;
    [UIView animateWithDuration:0.25 animations:^{
        self->_selectLineView.av_centerX = self->_selectedButton.av_centerX;
    }];
    if (_onSelectedGroupBlock) {
        _onSelectedGroupBlock(self.selectedGroupData);
    }
}

@end

@interface AUIVideoTemplateItemCell : UICollectionViewCell

@property (nonatomic, strong, readonly) AUIVideoTemplateItem *item;
@property (nonatomic, strong, readonly) UILabel *titleLabel;
@property (nonatomic, strong, readonly) UILabel *infoLabel;

@property (nonatomic, strong, readonly) UIImageView *iconView;
@property (nonatomic, strong, readonly) CAGradientLayer *bottomLayer;
@property (nonatomic, strong, readonly) UILabel *durationLabel;

- (void)updateItem:(AUIVideoTemplateItem *)item;

@end

@implementation AUIVideoTemplateItemCell


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.masksToBounds = YES;

        _iconView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _iconView.backgroundColor = AUIFoundationColor(@"bg_medium");
        _iconView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:_iconView];
        
        _bottomLayer = [CAGradientLayer layer];
        _bottomLayer.colors = @[(id)[UIColor av_colorWithHexString:@"#141416" alpha:0.0].CGColor,(id)[UIColor av_colorWithHexString:@"#141416" alpha:0.7].CGColor];
        _bottomLayer.startPoint = CGPointMake(0.5, 0);
        _bottomLayer.endPoint = CGPointMake(0.5, 1);
        [_iconView.layer addSublayer:_bottomLayer];
        
        _durationLabel = [UILabel new];
        _durationLabel.textColor = AUIFoundationColor(@"text_strong");
        _durationLabel.font = AVGetRegularFont(10);
        [_iconView addSubview:_durationLabel];

        _titleLabel = [UILabel new];
        _titleLabel.textColor = AUIFoundationColor(@"text_strong");
        _titleLabel.font = AVGetRegularFont(14);
        [self.contentView addSubview:_titleLabel];
        
        _infoLabel = [UILabel new];
        _infoLabel.textColor = AUIFoundationColor(@"text_weak");
        _infoLabel.font = AVGetRegularFont(14);
        [self.contentView addSubview:_infoLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.titleLabel.frame = CGRectMake(0, self.contentView.av_height - 20 - 22, self.contentView.av_width, 22);
    self.infoLabel.frame = CGRectMake(0, self.contentView.av_height - 16, self.contentView.av_width, 16);
    self.iconView.frame = CGRectMake(0, 0, self.contentView.av_width, self.titleLabel.av_top - 8);
    self.bottomLayer.frame = CGRectMake(0, self.iconView.av_height - 30, self.iconView.av_width, 30);
    self.durationLabel.frame = CGRectMake(8, self.iconView.av_height - 30, self.iconView.av_width - 8 * 2, 30);
}

- (void)updateItem:(AUIVideoTemplateItem *)item {
    _item = item;
    
    if ([item.cover hasPrefix:@"http"]) {
        [self.iconView sd_setImageWithURL:[NSURL URLWithString:item.cover] placeholderImage:nil];
    }
    else {
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"Template.bundle" ofType:nil];
        NSString *local = [bundlePath stringByAppendingPathComponent:item.cover];
        self.iconView.image = [UIImage imageWithContentsOfFile:local];
    }
    self.titleLabel.text = item.name;
    self.infoLabel.text = item.info;
    self.durationLabel.text = [NSString stringWithFormat:AUIUgsvGetString(@"总时长 %@"),[AVStringFormat formatWithDuration:item.duration]];
}

@end

@interface AUIVideoTemplateListViewController ()

@property (nonatomic, copy, readonly) NSMutableArray<AUIVideoTemplateItem *> *itemList;
@property (nonatomic, strong) AUIVideoTemplateListGroupView *groupView;

@property (nonatomic, strong) AVCircularProgressView *progressView;


@end

@implementation AUIVideoTemplateListViewController

- (instancetype)init {
    
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.hiddenMenuButton = YES;
    self.titleView.text = AUIUgsvGetString(@"模板列表");
    
    AUIVideoTemplateListGroupView *groupView = [[AUIVideoTemplateListGroupView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.av_width, 44)];
    groupView.groupDatas = @[
        [AUIVideoTemplateListGroupData data:@"1" name:AUIUgsvGetString(@"VLOG") json:@"templates_vlog.json"],         // ⚠️警告：json文件里记录的所有模板仅用于阿里云Demo的演示，请勿用于商业化
        [AUIVideoTemplateListGroupData data:@"2" name:AUIUgsvGetString(@"生活美食") json:@"templates_food.json"],      // ⚠️警告：json文件里记录的所有模板仅用于阿里云Demo的演示，请勿用于商业化
        [AUIVideoTemplateListGroupData data:@"3" name:AUIUgsvGetString(@"节日纪念") json:@"templates_festival.json"],  // ⚠️警告：json文件里记录的所有模板仅用于阿里云Demo的演示，请勿用于商业化
        [AUIVideoTemplateListGroupData data:@"0" name:AUIUgsvGetString(@"内置模板测试") json:@"templates_test.json"],   // ⚠️警告：json文件里记录的所有模板仅用于阿里云Demo的演示，请勿用于商业化
    ];
    [self.contentView addSubview:groupView];
    self.groupView = groupView;
    
    self.collectionView.frame = CGRectMake(0, groupView.av_bottom, self.contentView.av_width, self.contentView.av_height - groupView.av_bottom);
    [self.collectionView registerClass:AUIVideoTemplateItemCell.class forCellWithReuseIdentifier:AVCollectionViewCellIdentifier];
    
    [self reloadGroupDatas];
    __weak typeof(self) weakSelf = self;
    self.groupView.onSelectedGroupBlock = ^(AUIVideoTemplateListGroupData *data) {
        [weakSelf reloadGroupDatas];
    };
}

- (void)reloadGroupDatas {
    _itemList = [NSMutableArray array];
    AUIVideoTemplateListGroupData *selected = self.groupView.selectedGroupData;
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"Template.bundle" ofType:nil];
    NSString *jsonString = [bundlePath stringByAppendingPathComponent:selected.jsonFileName];
    NSData *jsonData = [NSData dataWithContentsOfFile:jsonString];
    NSError *parseError = nil;
    NSDictionary *configDic = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&parseError];
    if (!parseError) {
        [[configDic av_dictArrayValueForKey:@"templates"] enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            AUIVideoTemplateItem *item = [[AUIVideoTemplateItem alloc] initWithDict:obj];
            [_itemList addObject:item];
        }];
    }
    [self.collectionView reloadData];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.itemList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    AUIVideoTemplateItemCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:AVCollectionViewCellIdentifier forIndexPath:indexPath];
    [cell updateItem:self.itemList[indexPath.row]];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width = (self.collectionView.av_width - 20 - 20 - 11) / 2.0;
    return CGSizeMake(width, width * 16 / 9.0 + 50);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 11.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 16.0;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(8, 20, 8 + AVSafeBottom, 20);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    AUIVideoTemplateItem *item = self.itemList[indexPath.row];
    AUIVideoTemplatePreview *preview = [[AUIVideoTemplatePreview alloc] initWithTemplateItem:item];
    [self.navigationController pushViewController:preview animated:YES];
}

@end
