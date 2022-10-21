//
//  AUIUgsvParamsView.m
//  AlivcUgsvDemo
//
//  Created by coder.pi on 2022/6/13.
//

#import "AUIUgsvParamsView.h"
#import "Masonry.h"
#import "AUIUgsvMacro.h"
#import "AUIFoundation.h"
#import "AUIUgsvParamCell.h"

#import "AUIUgsvParamBuilder.h"

#define kTextFieldCellIdentifier    @"TextFieldCellIdentifier"
#define kSwitchCellIdentifier       @"SwitchCellIdentifier"
#define kRadioCellIdentifier        @"RadioCellIdentifier"
#define kSectionHeaderIdentifier    @"SectionHeaderIdentifier"

@interface __UgsvParamSectionHeaderView : UITableViewHeaderFooterView
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UILabel *label;
@end

@implementation __UgsvParamSectionHeaderView
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
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

- (void)setup {
    [_label removeFromSuperview];
    
    self.backgroundView = [UIView new];
    self.backgroundView.backgroundColor = AUIFoundationColor(@"bg_medium");
    self.userInteractionEnabled = NO;
    _label = [UILabel new];
    _label.font = AVGetRegularFont(12.0);
    _label.textColor = [UIColor av_colorWithHexString:@"#888888FF"];
    [self addSubview:_label];
    [_label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).inset(20.0);
        make.centerY.equalTo(self);
    }];
}

- (void)setTitle:(NSString *)title {
    _title = title;
    _label.text = title;
}
@end

@interface AUIUgsvParamsView()<UITableViewDelegate, UITableViewDataSource, AUIUgsvParamTextFieldCellDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSArray<AUIUgsvParamGroup *> *paramGroups;

@property (nonatomic, weak) UITextField *currentTextField;
@end

@implementation AUIUgsvParamsView

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

- (void)setParamWrapper:(AUIUgsvParamWrapper *)paramWrapper {
    if (_paramWrapper == paramWrapper) {
        return;
    }
    _paramWrapper.onShowingParamsDidChanged = nil;
    _paramWrapper = paramWrapper;
    
    __weak typeof(self) weakSelf = self;
    _paramWrapper.onShowingParamsDidChanged = ^(NSArray<AUIUgsvParamGroup *> *showing) {
        weakSelf.paramGroups = showing;
    };
    self.paramGroups = _paramWrapper.showingParams;
}

- (void)setParamGroups:(NSArray<AUIUgsvParamGroup *> *)paramGroups {
    if (_paramGroups == paramGroups) {
        return;
    }
    _paramGroups = paramGroups;
    [self.tableView reloadData];
}

- (void)setup {
    // clear
    [_tableView removeFromSuperview];
    
    // create
    _tableView = [UITableView new];
    _tableView.backgroundColor = AUIFoundationColor(@"bg_weak");
    _tableView.backgroundView = nil;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView registerClass:AUIUgsvParamTextFieldCell.class forCellReuseIdentifier:kTextFieldCellIdentifier];
    [_tableView registerClass:AUIUgsvParamSwitchCell.class forCellReuseIdentifier:kSwitchCellIdentifier];
    [_tableView registerClass:AUIUgsvParamRadioCell.class forCellReuseIdentifier:kRadioCellIdentifier];
    [_tableView registerClass:__UgsvParamSectionHeaderView.class forHeaderFooterViewReuseIdentifier:kSectionHeaderIdentifier];

    [self addSubview:_tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

// MARK: - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.paramGroups.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.paramGroups[section].items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    AUIUgsvParamItemModel *model = self.paramGroups[section].items[indexPath.row];
    AUIUgsvParamCell *cell = nil;
    if (model.type == AUIUgsvParamItemTypeTextField) {
        cell = (AUIUgsvParamTextFieldCell *)[tableView dequeueReusableCellWithIdentifier:kTextFieldCellIdentifier];
        ((AUIUgsvParamTextFieldCell *)cell).textFieldDelegate = self;
    }
    else if (model.type == AUIUgsvParamItemTypeRadio) {
        cell = (AUIUgsvParamRadioCell *)[tableView dequeueReusableCellWithIdentifier:kRadioCellIdentifier];
    }
    else if (model.type == AUIUgsvParamItemTypeSwitch) {
        cell = (AUIUgsvParamSwitchCell *)[tableView dequeueReusableCellWithIdentifier:kSwitchCellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.model = model;
    return cell;
}

// MARK: - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.0;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    __UgsvParamSectionHeaderView *header = (__UgsvParamSectionHeaderView *)[tableView dequeueReusableHeaderFooterViewWithIdentifier:kSectionHeaderIdentifier];
    header.title = self.paramGroups[section].label;
    return header;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}

// MARK: - AUIUgsvParamTextFieldCellDelegate
- (void) onAUIUgsvParamTextFieldCell:(AUIUgsvParamTextFieldCell *)cell
                becomeFirstResponder:(UITextField *)textField {
    _currentTextField = textField;
    CGPoint offset = cell.frame.origin;
    CGFloat center = _tableView.bounds.size.height * 0.5;
    if (offset.y > center) {
        offset.y -= center;
        [_tableView setContentOffset:offset animated:YES];
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    if (!_currentTextField) {
        return view;
    }
    
    if (_currentTextField == view || [view isDescendantOfView:_currentTextField]) {
        return view;
    }
    
    if (_tableView.contentSize.height <= _tableView.bounds.size.height && _tableView.contentOffset.y > 0) {
        [_tableView reloadData];
    }
    [_currentTextField resignFirstResponder];
    _currentTextField = nil;
    return view;
}

@end
