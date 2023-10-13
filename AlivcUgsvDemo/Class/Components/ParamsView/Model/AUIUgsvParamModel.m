//
//  AUIUgsvParamModel.m
//  AlivcUgsvDemo
//
//  Created by coder.pi on 2022/6/13.
//

#import "AUIUgsvParamModel_Inner.h"

// MARK: - AUIUgsvParamItemValueDefaultFormatter
@implementation AUIUgsvParamItemValueDefaultFormatter
+ (AUIUgsvParamItemValueDefaultFormatter *) FormatterWithType:(AUIUgsvParamItemValueType)type {
    return [[AUIUgsvParamItemValueDefaultFormatter alloc] initWithType:type];
}

- (instancetype)initWithType:(AUIUgsvParamItemValueType)type {
    self = [super init];
    if (self) {
        _type = type;
    }
    return self;
}

- (NSString *)fromValueToString:(id)value {
    if (!value) {
        return nil;
    }
    
    switch (_type) {
        case AUIUgsvParamItemValueTypeInt:
        case AUIUgsvParamItemValueTypeFloat:
        {
            NSNumber *realValue = value;
            NSAssert([realValue isKindOfClass:NSNumber.class], @"参数类型错误");
            return realValue.stringValue;
        }
        case AUIUgsvParamItemValueTypeString:
        {
            NSString *realValue = value;
            NSAssert([realValue isKindOfClass:NSString.class], @"参数类型错误");
            return realValue;
        }
        default:
            NSAssert(NO, @"请编写类型转换");
    }
    return nil;
}

- (id)fromStringToValue:(NSString *)text {
    switch (_type) {
        case AUIUgsvParamItemValueTypeInt:
            return @(text.intValue);
        case AUIUgsvParamItemValueTypeFloat:
            return @(text.floatValue);
        case AUIUgsvParamItemValueTypeString:
            return text;
        default:
            NSAssert(NO, @"请编写类型转换");
    }
    return nil;
}

- (AUIUgsvParamItemValueType)valueType {
    return _type;
}

@end

// MARK: - Base
@implementation AUIUgsvParamBaseModel
- (instancetype)initWithName:(NSString *)name label:(NSString *)label {
    self = [super init];
    if (self) {
        _name = name;
        _label = label;
    }
    return self;
}
- (void)setIsHiddenDefault:(BOOL)isHiddenDefault {
    _isHiddenDefault = isHiddenDefault;
}
@end


@implementation AUIUgsvParamItemModel
@synthesize paramValue = _paramValue;

- (BOOL)isGroup {
    return NO;
}

- (instancetype)initWithType:(AUIUgsvParamItemType)type
                        name:(NSString *)name
                       label:(NSString *)label {
    self = [super initWithName:name label:label];
    if (self) {
        _type = type;
        _editabled = YES;
    }
    return self;
}

- (void)notifyUpdate {
    if ([_delegate respondsToSelector:@selector(onAUIUgsvParamItemModelDidChange:)]) {
        [_delegate onAUIUgsvParamItemModelDidChange:self];
    }
}

- (void)setConverter:(id<AUIUgsvParamItemValueConverter> _Nullable)converter {
    _converter = converter;
}

- (void)onValueDidChangeInner {
    [self notifyUpdate];
}

- (void)checkValueChange:(id)value {
    id curValue = self.paramValue;
    if (value == curValue ||
        (value && curValue && [curValue isEqual:value])) {
        return;
    }

    [self onValueDidChangeInner];
    if (self.onValueDidChanged) {
        if (self.converter) {
            value = [self.converter fromParamToValue:value];
            curValue = [self.converter fromParamToValue:curValue];
        }
        self.onValueDidChanged(value, curValue);
    }
}

- (void)setParamValue:(id)paramValue {
    if (_paramValue == paramValue ||
        (_paramValue && paramValue && [_paramValue isEqual:paramValue])) {
        return;
    }
    
    id oldValue = self.paramValue;
    _paramValue = paramValue;
    [self checkValueChange:oldValue];
}

- (void)setDefaultValue:(id)defaultValue {
    id defaultParamValue = defaultValue;
    if (self.converter) {
        defaultParamValue = [self.converter fromValueToParam:defaultParamValue];
    }

    if (_defaultParamValue == defaultParamValue ||
        (_defaultParamValue && defaultParamValue && [_defaultParamValue isEqual:defaultParamValue])) {
        return;
    }
        
    id oldValue = self.paramValue;
    _defaultParamValue = defaultParamValue;
    [self checkValueChange:oldValue];
}

- (id)realParamValue {
    return _paramValue;
}

- (id)paramValue {
    if (_paramValue) {
        return _paramValue;
    }
    return self.defaultParamValue;
}

- (NSString *)showValue {
    id currentValue = self.paramValue;
    
    if ([currentValue isKindOfClass:NSString.class]) {
        return currentValue;
    }
    
    if ([currentValue isKindOfClass:NSNumber.class]) {
        return ((NSNumber *)currentValue).stringValue;
    }
    
    return @"";
}

- (void)setEditabled:(BOOL)editabled {
    if (_editabled == editabled) {
        return;
    }
    _editabled = editabled;
    [self notifyUpdate];
}
@end

// MARK: - TextField
@implementation AUIUgsvParamItemTextField
- (instancetype)initWithName:(NSString *)name label:(NSString *)label {
    self = [super initWithType:AUIUgsvParamItemTypeTextField name:name label:label];
    if (self) {
        _formatter = [AUIUgsvParamItemValueDefaultFormatter FormatterWithType:AUIUgsvParamItemValueTypeString];
    }
    return self;
}

- (void)setFormatter:(id<AUIUgsvParamItemValueFormatter>)formatter {
    _formatter = formatter;
}

- (NSString *)text {
    return [_formatter fromValueToString:self.realParamValue];
}
- (void)setText:(NSString *)text {
    if (text.length == 0) {
        self.paramValue = nil;
    }
    else {
        self.paramValue = [_formatter fromStringToValue:text];
    }
}

- (void)setPlaceHolder:(NSString *)placeHolder {
    _placeHolder = placeHolder;
}
- (void)setUnit:(NSString *)unit {
    _unit = unit;
}

- (NSString *)showValue {
    return self.text;
}
@end


// MARK: - Switch
@interface AUIUgsvParamItemSwitch ()
@property (nonatomic, strong) AUIUgsvParamVisibleControl *paramVisibleControl;
@property (nonatomic, copy) NSArray<NSString *> *showParams;
@property (nonatomic, copy) NSArray<NSString *> *hiddenParams;
@end

@implementation AUIUgsvParamItemSwitch

- (instancetype)initWithName:(NSString *)name label:(NSString *)label {
    self = [super initWithType:AUIUgsvParamItemTypeSwitch name:name label:label];
    if (self) {
        _showParams = @[];
        _hiddenParams = @[];
        _paramVisibleControl = [AUIUgsvParamVisibleControl new];
    }
    return self;
}

- (void)setShowParams:(NSArray<NSString *> *)showParams {
    if (showParams.count > 0) {
        _showParams = showParams.copy;
    }
    else {
        _showParams = @[];
    }
}
- (void)setHiddenParams:(NSArray<NSString *> *)hiddenParams {
    if (hiddenParams.count > 0) {
        _hiddenParams = hiddenParams.copy;
    }
    else {
        _hiddenParams = @[];
    }
}

- (void)onValueDidChangeInner {
    [super onValueDidChangeInner];
    
    if (self.showParams.count == 0 && self.hiddenParams.count == 0) {
        return;
    }

    if (self.isOn) {
        [self.paramVisibleControl updateWithShowParams:self.showParams hiddenParams:self.hiddenParams];
    }
    else {
        [self.paramVisibleControl updateWithShowParams:@[] hiddenParams:@[]];
    }
}

- (BOOL)isOn {
    return ((NSNumber *)self.paramValue).boolValue;
}
- (void)setIsOn:(BOOL)isOn {
    self.paramValue = @(isOn);
}
@end


// MARK: - Radio
@interface AUIUgsvParamItemOption ()
@property (nonatomic, copy) NSArray<NSString *> *showParams;
@property (nonatomic, copy) NSArray<NSString *> *hiddenParams;
@end

@implementation AUIUgsvParamItemOption
- (instancetype)initWithLabel:(NSString *)label value:(id)value {
    self = [super init];
    if (self) {
        _label = label;
        _optionValue = value;
        _showParams = @[];
        _hiddenParams = @[];
    }
    return self;
}

- (void)setShowParams:(NSArray<NSString *> *)showParams {
    if (!showParams) {
        showParams = @[];
    }
    _showParams = showParams.copy;
}
- (void)setHiddenParams:(NSArray<NSString *> *)hiddenParams {
    if (!hiddenParams) {
        hiddenParams = @[];
    }
    _hiddenParams = hiddenParams.copy;
}
@end

@interface AUIUgsvParamItemRadio ()
@property (nonatomic, strong) NSMutableArray<AUIUgsvParamItemOption *> *innerOptions;
@property (nonatomic, strong) AUIUgsvParamVisibleControl *paramVisibleControl;
@end

@implementation AUIUgsvParamItemRadio
- (instancetype)initWithName:(NSString *)name label:(NSString *)label {
    self = [super initWithType:AUIUgsvParamItemTypeRadio name:name label:label];
    if (self) {
        _innerOptions = @[].mutableCopy;
        _paramVisibleControl = [AUIUgsvParamVisibleControl new];
    }
    return self;
}

- (void)addOption:(AUIUgsvParamItemOption *)option {
    if (![_innerOptions containsObject:option]) {
        [_innerOptions addObject:option];
    }
}

- (NSArray<NSString *> *)optionsLabel {
    NSMutableArray<NSString *> *result = @[].mutableCopy;
    for (AUIUgsvParamItemOption *op in self.options) {
        [result addObject:op.label];
    }
    return result;
}

- (NSArray<AUIUgsvParamItemOption *> *)options {
    return _innerOptions;
}

- (NSUInteger) valueToIndex:(id)value {
    if (!value) {
        return 0;
    }
    
    for (NSUInteger i = 0; i < self.options.count; ++i) {
        if ([self.options[i].optionValue isEqual:value]) {
            return i;
        }
    }
    
    return 0;
}

- (AUIUgsvParamItemOption *)selectedOption {
    return self.options[self.selectedIndex];
}

- (NSUInteger)selectedIndex {
    return [self valueToIndex:self.paramValue];
}
- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    if (selectedIndex >= self.options.count) {
        return;
    }
    self.paramValue = self.options[selectedIndex].optionValue;
}

- (void)onValueDidChangeInner {
    [super onValueDidChangeInner];
    
    [_paramVisibleControl updateWithShowParams:self.selectedOption.showParams
                                  hiddenParams:self.selectedOption.hiddenParams];
}

- (NSString *)showValue {
    return self.selectedOption.label;
}
@end

// MARK: - Group
@interface AUIUgsvParamGroup ()
{
    NSMutableArray<AUIUgsvParamItemModel *> *_innerItems;
}
@end

@implementation AUIUgsvParamGroup
- (BOOL)isGroup {
    return YES;
}

- (instancetype)initWithName:(NSString *)name label:(NSString *)label {
    self = [super initWithName:name label:label];
    if (self) {
        _innerItems = @[].mutableCopy;
    }
    return self;
}

- (NSArray<AUIUgsvParamItemModel *> *) items {
    return _innerItems;
}

- (void)addItem:(AUIUgsvParamItemModel *)item {
    if (![_innerItems containsObject:item]) {
        [_innerItems addObject:item];
    }
}
@end

// MARK: - Wrapper
@interface AUIUgsvParamWrapper ()
@property (nonatomic, readonly) NSSet<NSString *> *showParams;
@property (nonatomic, readonly) NSSet<NSString *> *hideParams;
@property (nonatomic, readonly) NSMutableArray<AUIUgsvParamVisibleControl *> *paramVisibleControls;
@end

@implementation AUIUgsvParamWrapper
- (instancetype)initWithParams:(NSArray<AUIUgsvParamGroup *> *)params {
    self = [super init];
    if (self) {
        _allParams = params.copy;
        _showingParams = @[];
        _paramVisibleControls = @[].mutableCopy;
        [self setup];
        if (![self refreshVisible]) {
            [self refreshShowing];
        }
    }
    return self;
}

- (AUIUgsvParamItemModel *)findParamItemWithName:(NSString *)name {
    for (AUIUgsvParamGroup *group in _allParams) {
        for (AUIUgsvParamItemModel *item in group.items) {
            if ([item.name isEqualToString:name]) {
                return item;
            }
        }
    }
    return nil;
}

static BOOL s_hasChange(NSSet<NSString *> *origin, NSSet<NSString *> *target) {
    if (origin.count == 0 && target.count == 0) {
        return NO;
    }
    if (origin && target && [origin isEqualToSet:target]) {
        return NO;
    }
    return YES;
}

- (BOOL)updateShowParams:(NSSet<NSString *> *)showParams {
    if (!s_hasChange(_showParams, showParams)) {
        return NO;
    }
    _showParams = showParams.copy;
    return YES;
}

- (BOOL)updateHideParams:(NSSet<NSString *> *)hideParams {
    if (!s_hasChange(_hideParams, hideParams)) {
        return NO;
    }
    _hideParams = hideParams.copy;
    return YES;
}

- (BOOL)updateVisibleWithShowParams:(NSSet<NSString *> *)showParams hideParams:(NSSet<NSString *> *)hideParams {
    BOOL hasChange = [self updateShowParams:showParams];
    hasChange = [self updateHideParams:hideParams] || hasChange;
    if (!hasChange) {
        return NO;
    }
    
    [self refreshShowing];
    return YES;
}

- (BOOL)isShowModel:(AUIUgsvParamBaseModel *)model {
    if ([self.hideParams containsObject:model.name]) {
        return NO;
    }
    
    return (!model.isHiddenDefault || [self.showParams containsObject:model.name]);
}

- (void)refreshShowing {
    NSMutableArray<AUIUgsvParamGroup *> *showing = @[].mutableCopy;
    for (AUIUgsvParamGroup *group in _allParams) {
        if (![self isShowModel:group]) {
            continue;
        }

        AUIUgsvParamGroup *tmpGroup = [[AUIUgsvParamGroup alloc] initWithName:group.name label:group.label];
        for (AUIUgsvParamItemModel *item in group.items) {
            if (![self isShowModel:item]) {
                continue;
            }
            [tmpGroup addItem:item];
        }
        [showing addObject:tmpGroup];
    }
    _showingParams = showing;
    if (self.onShowingParamsDidChanged) {
        self.onShowingParamsDidChanged(self.showingParams);
    }
}

- (BOOL)refreshVisible {
    NSMutableSet<NSString *> *showParams = [NSMutableSet set];
    NSMutableSet<NSString *> *hideParams = [NSMutableSet set];
    for (AUIUgsvParamVisibleControl *ctr in _paramVisibleControls) {
        [showParams addObjectsFromArray:ctr.showParams];
        [hideParams addObjectsFromArray:ctr.hiddenParams];
    }
    return [self updateVisibleWithShowParams:showParams hideParams:hideParams];
}

- (void)setup {
    __weak typeof(self) weakSelf = self;
    for (AUIUgsvParamGroup *group in _allParams) {
        for (AUIUgsvParamItemModel *model in group.items) {
            if (![model respondsToSelector:@selector(paramVisibleControl)]) {
                continue;
            }

            id<AUIUgsvParamVisibleControlItem> ctrItem = (id<AUIUgsvParamVisibleControlItem>)model;
            AUIUgsvParamVisibleControl *ctr = [ctrItem paramVisibleControl];
            ctr.onParamVisibleDidChanged = ^(NSArray<NSString *> *showParams, NSArray<NSString *> *hiddenParams) {
                [weakSelf refreshVisible];
            };
            [_paramVisibleControls addObject:ctr];
        }
    }
}
@end
