//
//  AUICaptionStyleView.m
//  AlivcUgsvDemo
//
//  Created by mengyehao on 2022/6/1.
//

#import "AUICaptionStyleView.h"
#import "AliyunCaptionStyleTempleteView.h"
#import "AliyunCaptionFontView.h"
#import "UIView+AVHelper.h"
#import "AUIFoundation.h"
#import "AUIUgsvMacro.h"
#import "AlivcUgsvSDKHeader.h"
#import "AUICaptionFontModel.h"
#import "UIColor+AVHelper.h"


@interface AUICaptionStyleColorView : UIView<UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong) NSMutableArray *dataList;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, weak) AliyunStickerController *stickerController;
@end

@implementation AUICaptionStyleColorView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.collectionView];
        [self fetchData];
    }
    return self;
}

- (NSMutableArray *)dataList
{
    if (!_dataList) {
        _dataList = [NSMutableArray array];
    }
    return _dataList;
}

- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.itemSize = CGSizeMake(26, 26);
        layout.sectionInset = UIEdgeInsetsMake(0, 20, 0, 20);
        layout.minimumInteritemSpacing = 10;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        _collectionView = [[UICollectionView alloc]initWithFrame:self.bounds collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsHorizontalScrollIndicator = NO;
        
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"UICollectionViewCell"];
    }
    
    return _collectionView;
}

- (void)fetchData
{
    NSArray *localList = @[
   @"#FFFFFF",
   @"#FE891E",
   @"#D74E47",
   @"#F7F3E2",
   @"#FFE45C",
   @"#FEF49D",
   @"#DCFACF",
   @"#89BF6A",
   @"#2DDB9D",
   @"#8AFDFE",
   @"#9DD623",
   @"#47A0D7",
   @"#316DDB",
   @"#925CFF",
   @"#FE9DE7"];
    
    for (NSString *str in localList) {
        UIColor *color = [UIColor av_colorWithHexString:str];
        if (color) {
            [self.dataList addObject:color];
        }
    }
    
    [self.collectionView reloadData];
}

#pragma mark - CollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.dataList.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    UICollectionViewCell
    *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"UICollectionViewCell" forIndexPath:indexPath];
    cell.contentView.backgroundColor = self.dataList[indexPath.row];
    cell.contentView.layer.cornerRadius = 26/2;
    return cell;
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    AliyunCaptionSticker *model =  self.stickerController.model;
    model.color = self.dataList[indexPath.row];
  
}


@end


@interface AUICaptionStyleView ()
@property (nonatomic, strong) AliyunCaptionFontView *fontView;
@property (nonatomic, strong) AliyunCaptionStyleTempleteView *templeteView;
@property (nonatomic, strong) AUICaptionStyleColorView *colorView;
@property (nonatomic, strong) UILabel *colorLabel;


@end

@implementation AUICaptionStyleView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self addSubview:self.fontView];
        [self addSubview:self.templeteView];
        [self addSubview:self.colorLabel];
        [self addSubview:self.colorView];

    }
    return self;
}

- (UILabel *)colorLabel
{
    if (!_colorLabel) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, self.templeteView.av_bottom, self.av_width - 20 * 2, 44)];
        label.text = AUIUgsvGetString(@"颜色");
        label.textColor = AUIFoundationColor(@"text_strong");
        label.font = AVGetMediumFont(12);
        label.textAlignment = NSTextAlignmentLeft;
        label.numberOfLines = 1;

        _colorLabel = label;
    }
    
    return _colorLabel;
}

- (AUICaptionStyleColorView *)colorView
{
    if (!_colorView) {
        _colorView = [[AUICaptionStyleColorView alloc] initWithFrame:CGRectMake(0, self.colorLabel.av_bottom, self.bounds.size.width, 26)];
    }
    return _colorView;
}

- (AliyunCaptionStyleTempleteView *)templeteView
{
    if (!_templeteView) {
        _templeteView = [[AliyunCaptionStyleTempleteView alloc] initWithFrame:CGRectMake(0, self.fontView.av_bottom, self.bounds.size.width, 28)];
        [_templeteView selectWithIndex:0];
        __weak typeof(self) weakSelf = self;

        _templeteView.onSelectedChanged = ^(AUICaptionStyleTempleteModel * _Nonnull model) {
            AliyunCaptionSticker *caption = weakSelf.stickerController.model;
            if (model.color) {
                caption.color = model.color;
            }
  
            caption.backgroundColor = model.bgColor;
            
            caption.outlineColor = model.outlineColor;
            caption.outlineWidth = caption.outlineWidth;
            
            caption.shadowColor = model.shadowColor;
            caption.shadowOffset = caption.shadowOffset;
        };
    }
    
    return _templeteView;
}

- (AliyunCaptionFontView *)fontView
{
    if (!_fontView) {
        _fontView = [[AliyunCaptionFontView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 54)];
        [_fontView selectWithIndex:0];
        __weak typeof(self) weakSelf = self;

        _fontView.onSelectedChanged = ^(AUICaptionFontModel * _Nonnull model) {
            weakSelf.stickerController.model.fontName = model.fontName;
        };
    }
    
    return _fontView;
}


- (void)setStickerController:(AliyunCaptionStickerController *)stickerController
{
    _stickerController = stickerController;
    
    
    [self.fontView.dataList enumerateObjectsUsingBlock:^(AUICaptionFontModel*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([stickerController.model.fontName isEqualToString:obj.fontName]) {
            [self.fontView selectWithIndex:idx];
            *stop = YES;
        }
    }];
    
    _colorView.stickerController = stickerController;
}

@end
