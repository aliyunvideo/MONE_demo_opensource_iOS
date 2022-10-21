//
//  AUIEditorEditBar.m
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/6/9.
//

#import "AUIEditorEditBar.h"

@interface AUIEditorEditBar ()

@end

@implementation AUIEditorEditBar

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = AUIFoundationColor(@"bg_weak");
        
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.av_width, 46)];
        [self addSubview:headerView];
        _headerView = headerView;
        
        CGFloat contentHeight = [self.class contentHeight];
        if (![self.class isMenuViewHidden]) {
            contentHeight = contentHeight - 54;
            UIView *menuView = [[UIView alloc] initWithFrame:CGRectMake(0, contentHeight, self.av_width, 54)];
            [self addSubview:menuView];
            _menuView = menuView;
            
            UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, menuView.av_width, 1)];
            lineView.backgroundColor = AUIFoundationColor(@"border_infrared");
            [menuView addSubview:lineView];
        }
        
        UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, headerView.av_bottom, self.av_width, contentHeight - headerView.av_bottom)];
        [self addSubview:contentView];
        _contentView = contentView;
        

        
        UIView *headerLineView = [[UIView alloc] initWithFrame:CGRectMake(0, self.headerView.av_height - 1, self.headerView.av_width, 1)];
        headerLineView.backgroundColor = AUIFoundationColor(@"fg_strong");
        [self.headerView addSubview:headerLineView];
        _headerLineView = headerLineView;
        
        UILabel *titleView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.headerView.av_width, self.headerView.av_height)];
        titleView.font = AVGetRegularFont(14);
        titleView.textAlignment = NSTextAlignmentCenter;
        titleView.textColor = AUIFoundationColor(@"text_strong");
        titleView.text = [self.class title];
        [self.headerView addSubview:titleView];
        _titleView = titleView;
    }
    return self;
}

- (void)barWillAppear {
    _isAppear = YES;
    
    // implementation by sub class
}

- (void)barWillDisappear {
    _isAppear = NO;
    
    // implementation by sub class
}

- (void)refreshPlayTime {
    
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
        [_actionManager.currentOperator.currentPlayer removeObserver:self];
        _actionManager = nil;
    }
    if (actionManager) {
        _actionManager = actionManager;
        [_actionManager addObserver:self];
        [_actionManager.currentOperator.currentPlayer addObserver:self];
    }
}

- (void)actionItem:(AUIEditorActionItem *)item doActionResult:(NSError *)error retObject:(id)retObject {
    if (error) {
        return;
    }
}


+ (BOOL)isMenuViewHidden {
    return NO;
}

+ (NSString *)title {
    return @"";
}

+ (CGFloat)contentHeight {
    return 240;
}

@end


@implementation AUIEditorEditBar (Helper)

+ (UIButton *)createAddButton:(NSString *)title {
    UIButton *addBtn = [[UIButton alloc] initWithFrame:CGRectZero];
    addBtn.titleLabel.font = AVGetRegularFont(12.0);
    [addBtn setTitleColor:AUIFoundationColor(@"text_strong") forState:UIControlStateNormal];
    [addBtn setTitle:title forState:UIControlStateNormal];
    [addBtn av_setLayerBorderColor:AUIFoundationColor(@"border_medium") borderWidth:1];
    addBtn.layer.cornerRadius = 12.0;
    addBtn.layer.masksToBounds = YES;
    [addBtn sizeToFit];
    addBtn.frame = CGRectMake(0, 0, MAX(addBtn.av_width, 62), 24);
    return addBtn;
}

+ (UIButton *)createRemoveButton {
    UIButton *removeBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 22, 22)];
    [removeBtn setImage:AUIUgsvEditorImage(@"ic_menu_remove") forState:UIControlStateNormal];
    return removeBtn;
}

+ (AVBaseButton *)createMenuButton:(NSString *)title image:(UIImage *)image {
    AVBaseButton *btn = [AVBaseButton ImageTextWithTitlePos:AVBaseButtonTitlePosBottom];
    btn.font = AVGetRegularFont(12.0);
    btn.title = title;
    btn.color = AUIFoundationColor(@"text_strong");
    btn.image = image;
    return btn;
}

@end
