//
//  AUIVideoTemplateEditMenuItem.m
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/12/21.
//

#import "AUIVideoTemplateEditMenuItem.h"
#import "AUIFoundation.h"
#import "AUIUgsvMacro.h"


@interface AUIVideoTemplateEditMenuItem ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *iconView;

@end

@implementation AUIVideoTemplateEditMenuItem

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        titleLabel.font = AVGetRegularFont(12.0);
        titleLabel.textColor = AUIFoundationColor(@"text_weak");
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
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.iconView.frame = CGRectMake((self.av_width - 24) / 2.0, 0, 24, 24);
    
    [self.titleLabel sizeToFit];
    CGFloat titleWidth = MAX(self.av_width, self.titleLabel.av_width);
    self.titleLabel.frame = CGRectMake((self.av_width - titleWidth) / 2.0, self.av_height - 18, titleWidth, 18);
}

- (void)onTap:(UITapGestureRecognizer *)recognizer {
    if (self.data.onClickBlock) {
        self.data.onClickBlock(self.data);
    }
}

@end



@interface AUIVideoTemplateEditMenuBar ()

@property (nonatomic, strong) NSMutableArray<AUIVideoTemplateEditMenuItem *> *menuItems;
@property (nonatomic, copy) void(^onSelectedBlock)(AUIVideoTemplateEditMenuType type);

@end

@implementation AUIVideoTemplateEditMenuBar

- (instancetype)initWithFrame:(CGRect)frame itemTypes:(NSArray<NSNumber *> *)types selectedBlock:(void(^)(AUIVideoTemplateEditMenuType type))selectedBlock  {
    self = [super initWithFrame:frame];
    if (self) {
        __weak typeof(self) weakSelf = self;
        
        CGFloat itemHeight = 42;
        CGFloat itemWidth = 58;
        CGFloat itemTop = (self.av_height - itemHeight) / 2.0;
        CGFloat margin = 65;
        NSInteger count = types.count;
        CGFloat itemMargin = (self.av_width - margin * 2 - count * itemWidth) / (count - 1);
        __block CGFloat itemLeft = margin;
        
        _menuItems = [NSMutableArray array];
        [types enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            AUIVideoTemplateEditMenuType type = obj.integerValue;
            if (type == AUIVideoTemplateEditMenuTypeMedia) {
                AUIVideoTemplateEditMenuData *menuData = [AUIVideoTemplateEditMenuData new];
                menuData.type = type;
                menuData.text = AUIUgsvGetString(@"视频");
                menuData.normalIcon = AUIUgsvTemplateImage(@"ic_menu_clip");
                menuData.selectedIcon = AUIUgsvTemplateImage(@"ic_menu_clip_selected");
                menuData.onClickBlock = ^(AUIVideoTemplateEditMenuData *sender) {
                    if (sender.selected) {
                        return;
                    }
                    [weakSelf updateEditorMenuSelected:sender];
                };
                AUIVideoTemplateEditMenuItem *menuItem = [[AUIVideoTemplateEditMenuItem alloc] initWithFrame:CGRectMake(itemLeft, itemTop, itemWidth, itemHeight)];
                menuItem.data = menuData;
                [self addSubview:menuItem];
                
                [_menuItems addObject:menuItem];
                itemLeft = menuItem.av_right + itemMargin;
                return;
            }
            if (type == AUIVideoTemplateEditMenuTypeText) {
                AUIVideoTemplateEditMenuData *menuData = [AUIVideoTemplateEditMenuData new];
                menuData.type = type;
                menuData.text = AUIUgsvGetString(@"文字");
                menuData.normalIcon = AUIUgsvTemplateImage(@"ic_menu_text");
                menuData.selectedIcon = AUIUgsvTemplateImage(@"ic_menu_text_selected");
                menuData.onClickBlock = ^(AUIVideoTemplateEditMenuData *sender) {
                    if (sender.selected) {
                        return;
                    }
                    [weakSelf updateEditorMenuSelected:sender];
                };
                AUIVideoTemplateEditMenuItem *menuItem = [[AUIVideoTemplateEditMenuItem alloc] initWithFrame:CGRectMake(itemLeft, itemTop, itemWidth, itemHeight)];
                menuItem.data = menuData;
                [self addSubview:menuItem];
                
                [_menuItems addObject:menuItem];
                itemLeft = menuItem.av_right + itemMargin;
                return;
            }
            if (type == AUIVideoTemplateEditMenuTypeMusic) {
                AUIVideoTemplateEditMenuData *menuData = [AUIVideoTemplateEditMenuData new];
                menuData.type = type;
                menuData.text = AUIUgsvGetString(@"音乐");
                menuData.normalIcon = AUIUgsvTemplateImage(@"ic_menu_music");
                menuData.selectedIcon = AUIUgsvTemplateImage(@"ic_menu_music_selected");
                menuData.onClickBlock = ^(AUIVideoTemplateEditMenuData *sender) {
                    if (sender.selected) {
                        return;
                    }
                    [weakSelf updateEditorMenuSelected:sender];
                };
                AUIVideoTemplateEditMenuItem *menuItem = [[AUIVideoTemplateEditMenuItem alloc] initWithFrame:CGRectMake(itemLeft, itemTop, itemWidth, itemHeight)];
                menuItem.data = menuData;
                [self addSubview:menuItem];
                
                [_menuItems addObject:menuItem];
                itemLeft = menuItem.av_right + itemMargin;
                return;
            }
        }];
        
        if (_menuItems.firstObject) {
            [self updateEditorMenuSelected:_menuItems.firstObject.data];
        }
        _onSelectedBlock = selectedBlock;
    }
    return self;
}

- (void)updateEditorMenuSelected:(AUIVideoTemplateEditMenuData *)selected {
    [_menuItems enumerateObjectsUsingBlock:^(AUIVideoTemplateEditMenuItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.data.selected = obj.data == selected;
        [obj updateData];
    }];
    
    _selectedType = selected.type;
    if (_onSelectedBlock) {
        _onSelectedBlock(selected.type);
    }
}

@end
