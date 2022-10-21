//
//  OPRSegementView.m
//  AlivcUgsvDemo
//
//  Created by mengyehao on 2022/5/31.
//  
//

#import "AUISegementView.h"
#import "UIView+AVHelper.h"
#import "AUIFoundation.h"


@interface AUISegementView ()

@property (nonatomic, strong) UIView *selectedView;
@property (nonatomic, strong) NSMutableArray<UIButton *> *butttonList;
@property (nonatomic, assign) CGFloat titleHeight;

@end

@implementation AUISegementView



- (instancetype)initWithTitles:(NSArray<NSString *>*)titles
{
    self = [super init];
    if (self)
    {
        _paddingX = 30.f;
        
        self.backgroundColor = AUIFoundationColor(@"bg_weak");
        _butttonList = [NSMutableArray array];
        for (int i = 0; i < titles.count; i++) {
            UIButton *button = [self createButtonWithTitle:titles[i] tag:i];
            if (button) {
                [self addSubview:button];
                [_butttonList addObject:button];
            }
        }
        
        self.selectedView = [[UIView alloc] init];
        self.selectedView.backgroundColor = AUIFoundationColor(@"text_strong");
        [self addSubview:self.selectedView];
        
        [self.butttonList enumerateObjectsUsingBlock:^(UIButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.selected = _selectedType == obj.tag;
        }];
        [self updateSelectedView:NO];
    }
    return self;
}

- (UIButton *)createButtonWithTitle:(NSString *)title tag:(NSUInteger)tag
{
    UIButton *button = [[UIButton alloc] init];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:AUIFoundationColor(@"text_weak")forState:UIControlStateNormal];
    [button setTitleColor:AUIFoundationColor(@"text_strong") forState:UIControlStateSelected];
    button.titleLabel.font = AVGetRegularFont(12.0f);
    [button addTarget:self action:@selector(onBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    button.tag = tag;
    return button;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    __block CGFloat titleWidth  = 0;
    [self.butttonList enumerateObjectsUsingBlock:^(UIButton *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj sizeToFit];
        titleWidth += obj.frame.size.width;
        self.titleHeight = MAX(self.titleHeight, obj.frame.size.height);
    }];
    
    CGFloat padding = self.paddingX;
    CGFloat magrnX = (self.bounds.size.width -
                      titleWidth - (self.butttonList.count - 1) * padding) / 2;
    
    __block CGFloat left = magrnX;
    [self.butttonList enumerateObjectsUsingBlock:^(UIButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGRect frame = obj.frame;
        frame.origin.x = left;
        frame.origin.y = (CGRectGetHeight(self.bounds) - CGRectGetHeight(frame)) / 2;
        obj.frame = frame;
        left = CGRectGetMaxX(frame) + padding;
    }];
    
    self.selectedView.frame = CGRectMake(0, 0, 8, 2.0f);
    self.selectedView.layer.cornerRadius = 1.f;

    [self updateSelectedView:NO];
}


- (void)onBtnClick:(UIButton *)sender
{
    self.selectedType = sender.tag;
}

- (void)setHideSeletedBomline:(BOOL)hideSeletedBomline
{
    _hideSeletedBomline = hideSeletedBomline;
    self.selectedView.hidden = hideSeletedBomline;
}

- (void)setSelectedType:(NSUInteger)selectedType
{
    if (_selectedType != selectedType)
    {
        _selectedType = selectedType;
        
        [self.butttonList enumerateObjectsUsingBlock:^(UIButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.selected = _selectedType == obj.tag;
        }];
        
        [self updateSelectedView:YES];

        if (self.onSelectedChanged)
        {
            self.onSelectedChanged(_selectedType);
        }
        
        
    }
}

- (void)updateSelectedView:(BOOL)ani
{
    __block UIButton *selectBtn;
    [self.butttonList enumerateObjectsUsingBlock:^(UIButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (obj.tag == _selectedType) {
            selectBtn = obj;
            * stop = YES;
        }
    }];
    
    if (!selectBtn) {
        return;
    }
    
    if (ani)
    {
        [UIView animateWithDuration:0.3 animations:^{
            self.selectedView.center = CGPointMake(selectBtn.center.x, selectBtn.center.y + self.titleHeight/2);
        } completion:^(BOOL finished) {
            self.selectedView.center = CGPointMake(selectBtn.center.x, selectBtn.center.y + self.titleHeight/2);
        }];
    }
    else
    {
        self.selectedView.center = CGPointMake(selectBtn.center.x, selectBtn.center.y + self.titleHeight/2);
    }
}

@end
