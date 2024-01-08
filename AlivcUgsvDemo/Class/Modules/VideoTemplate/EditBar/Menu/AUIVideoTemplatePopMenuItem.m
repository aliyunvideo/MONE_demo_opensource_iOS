//
//  AUIVideoTemplatePopMenuItem.m
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/12/22.
//

#import "AUIVideoTemplatePopMenuItem.h"
#import "AUIFoundation.h"
#import "AUIUgsvMacro.h"

@interface AUIVideoTemplatePopMenuItem ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *iconView;

@end

@implementation AUIVideoTemplatePopMenuItem

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        titleLabel.font = AVGetRegularFont(8.0);
        titleLabel.textColor = AUIFoundationColor(@"text_medium");
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:titleLabel];
        _titleLabel = titleLabel;
        
        UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:iconView];
        _iconView = iconView;
        
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)]];
    }
    return self;
}

- (void)setData:(AUIVideoTemplateEditMenuData *)data {
    _data = data;
    [self updateData];
}

- (void)updateData {
    self.titleLabel.text = self.data.text;
    self.titleLabel.textColor = self.data.selected ? AUIFoundationColor(@"text_medium") : AUIFoundationColor(@"text_weak");
    self.iconView.image = self.data.selected ? self.data.selectedIcon : self.data.normalIcon;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.iconView.frame = CGRectMake((self.av_width - 16) / 2.0, 0, 16, 16);
    self.titleLabel.frame = CGRectMake(0, self.av_height - 12, self.av_width, 12);
}

- (void)onTap:(UITapGestureRecognizer *)recognizer {
    if (self.data.onClickBlock) {
        self.data.onClickBlock(self.data);
    }
}

@end


@interface AUIVideoTemplatePopMenuBar ()

@property (nonatomic, strong) UIView *menuContainer;
@property (nonatomic, copy) void(^clickItemBlock)(AUIVideoTemplateEditMenuType type);

@end

@implementation AUIVideoTemplatePopMenuBar

- (instancetype)initWithFrame:(CGRect)frame canCrop:(BOOL)canCrop canDelete:(BOOL)canDelete {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = UIColor.clearColor;
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)]];
        
        CGFloat w = 36;
        CGFloat h = 32;
        CGFloat left = 6;
        CGFloat top = 8;
        UIView *menuContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, w * 3 + left * 2, h + top * 2)];
        menuContainer.backgroundColor = AUIFoundationColor(@"fill_medium");
        menuContainer.layer.cornerRadius = 4.0;
        menuContainer.layer.masksToBounds = YES;
        [self addSubview:menuContainer];
        self.menuContainer = menuContainer;
        
        __weak typeof(self)weakSelf =self;
        AUIVideoTemplateEditMenuData *replaceData = [AUIVideoTemplateEditMenuData new];
        replaceData.type = AUIVideoTemplateEditMenuTypePopReplace;
        replaceData.selected = YES;
        replaceData.text = AUIUgsvGetString(@"替换");
        replaceData.selectedIcon = AUIUgsvTemplateImage(@"ic_pop_replace");
        replaceData.onClickBlock = ^(AUIVideoTemplateEditMenuData * _Nonnull sender) {
            if (!sender.selected) {
                return;
            }
            if (weakSelf.clickItemBlock) {
                weakSelf.clickItemBlock(sender.type);
            }
            [weakSelf removeFromSuperview];
        };
        AUIVideoTemplatePopMenuItem *pickerMenu = [[AUIVideoTemplatePopMenuItem  alloc] initWithFrame:CGRectMake(left, top, w, h)];
        pickerMenu.data = replaceData;
        [pickerMenu updateData];
        [menuContainer addSubview:pickerMenu];
        
        AUIVideoTemplateEditMenuData *cropData = [AUIVideoTemplateEditMenuData new];
        cropData.type = AUIVideoTemplateEditMenuTypePopCrop;
        cropData.selected = canCrop;
        cropData.text = AUIUgsvGetString(@"裁剪");
        cropData.normalIcon = AUIUgsvTemplateImage(@"ic_pop_crop_disable");
        cropData.selectedIcon = AUIUgsvTemplateImage(@"ic_pop_crop");
        cropData.onClickBlock = ^(AUIVideoTemplateEditMenuData * _Nonnull sender) {
            if (!sender.selected) {
                return;
            }
            if (weakSelf.clickItemBlock) {
                weakSelf.clickItemBlock(sender.type);
            }
            [weakSelf removeFromSuperview];
        };
        AUIVideoTemplatePopMenuItem *cropMenu = [[AUIVideoTemplatePopMenuItem  alloc] initWithFrame:CGRectMake(left+w, top, w, h)];
        cropMenu.data = cropData;
        [cropMenu updateData];
        [menuContainer addSubview:cropMenu];
        
        AUIVideoTemplateEditMenuData *deleteData = [AUIVideoTemplateEditMenuData new];
        deleteData.type = AUIVideoTemplateEditMenuTypePopDelete;
        deleteData.selected = canDelete;
        deleteData.text = AUIUgsvGetString(@"删除");
        deleteData.normalIcon = AUIUgsvTemplateImage(@"ic_pop_delete_disable");
        deleteData.selectedIcon = AUIUgsvTemplateImage(@"ic_pop_delete");
        deleteData.onClickBlock = ^(AUIVideoTemplateEditMenuData * _Nonnull sender) {
            if (!sender.selected) {
                return;
            }
            if (weakSelf.clickItemBlock) {
                weakSelf.clickItemBlock(sender.type);
            }
            [weakSelf removeFromSuperview];
        };
        AUIVideoTemplatePopMenuItem *deleteMenu = [[AUIVideoTemplatePopMenuItem  alloc] initWithFrame:CGRectMake(left+w*2, top, w, h)];
        deleteMenu.data = deleteData;
        [deleteMenu updateData];
        [menuContainer addSubview:deleteMenu];
    }
    return self;
}

- (void)onTap:(UITapGestureRecognizer *)recognizer {
    [self removeFromSuperview];
}

+ (void)show:(UIView *)aboveView canCrop:(BOOL)canCrop canDelete:(BOOL)canDelete clickItemBlock:(void (^)(AUIVideoTemplateEditMenuType))clickItemblock {
    
    UIView *parentView = UIViewController.av_topViewController.view;
    AUIVideoTemplatePopMenuBar *menuBar = [[AUIVideoTemplatePopMenuBar alloc] initWithFrame:parentView.bounds canCrop:canCrop canDelete:canDelete];
    menuBar.clickItemBlock = clickItemblock;
    
    CGPoint center = [aboveView convertPoint:CGPointMake(aboveView.av_width / 2.0, 0) toView:parentView];
    center.x = MAX(center.x, menuBar.menuContainer.av_width / 2);
    center.x = MIN(center.x, parentView.av_width - menuBar.menuContainer.av_width / 2);
    center.y = center.y - 4 - menuBar.menuContainer.av_height / 2.0;
    menuBar.menuContainer.center = center;
    
    [parentView addSubview:menuBar];
}

@end
