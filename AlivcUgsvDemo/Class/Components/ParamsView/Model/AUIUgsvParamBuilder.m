//
//  AUIUgsvParamBuilder.m
//  AlivcUgsvDemo
//
//  Created by coder.pi on 2022/6/14.
//

#import "AUIUgsvParamBuilder.h"
#import "AUIUgsvParamModel_Inner.h"

// MARK: - InnerObj
@interface __BuilderInnerObject : NSObject
{
    NSMutableArray<AUIUgsvParamGroup *> *_groups;
}
@property (nonatomic, strong) NSMutableDictionary<NSString *, id> *paramValues;
@property (nonatomic, readonly) AUIUgsvParamWrapper *paramWrapper;
@property (nonatomic, strong) AUIUgsvParamGroup *currentGroup;
@property (nonatomic, strong) AUIUgsvParamItemModel *currentItem;
@property (nonatomic, strong) AUIUgsvParamItemOption *currentOption;
@end

@implementation __BuilderInnerObject

- (instancetype)init {
    self = [super init];
    if (self) {
        _paramValues = @{}.mutableCopy;
        _groups = @[].mutableCopy;
    }
    return self;
}

- (AUIUgsvParamWrapper *)paramWrapper {
    return [[AUIUgsvParamWrapper alloc] initWithParams:_groups];
}

- (void)setCurrentGroupWithName:(NSString *)name {
    __block AUIUgsvParamGroup *group = nil;
     [_groups enumerateObjectsUsingBlock:^(AUIUgsvParamGroup * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
         if ([obj.name isEqualToString:name]) {
             group = obj;
             return;
         }
     }];
    if (group) {
        [self setCurrentGroup:group];
    }
}

- (void)setCurrentGroup:(AUIUgsvParamGroup *)currentGroup {
    if (_currentGroup == currentGroup) {
        return;
    }
    _currentGroup = currentGroup;
    if (_currentGroup && ![_groups containsObject:_currentGroup]) {
        [_groups addObject:_currentGroup];
    }
}

- (void)setCurrentItem:(AUIUgsvParamItemModel *)currentItem {
    if (_currentItem == currentItem) {
        return;
    }
    _currentItem = currentItem;
    
    NSString *name = _currentItem.name;
    NSMutableDictionary<NSString *, id> *values = _paramValues;
    _currentItem.onValueDidChanged = ^(id  _Nullable oldValue, id  _Nullable curValue) {
        values[name] = curValue;
    };
    
    NSAssert(_currentGroup, @"No Group to add item!");
    [_currentGroup addItem:_currentItem];
}

- (void)setCurrentOption:(AUIUgsvParamItemOption *)currentOption {
    if (_currentOption == currentOption) {
        return;
    }
    _currentOption = currentOption;
    AUIUgsvParamItemRadio *radio = (AUIUgsvParamItemRadio *)_currentItem;
    NSAssert([radio isKindOfClass:AUIUgsvParamItemRadio.class], @"current item is not radio, can not add option!");
    [radio addOption:currentOption];
}

@end

// MARK: - AUIUgsvParamBuilder
@interface AUIUgsvParamBuilder()
@property (nonatomic, strong) __BuilderInnerObject *innerObj;
- (instancetype)initWithObj:(__BuilderInnerObject *)obj;
@end

// MARK: - Helper
typedef id(^EditabledSetter)(BOOL);
typedef id(^IsHiddenDefaultSetter)(void);
typedef id(^OnValueDidChangeSetter)(OnAUIUgsvParamValueDidChanged);
typedef id(^KVCSetter)(NSObject *, NSString *);
typedef void(^DefaultValueSetter)(id value);
typedef id(^TextfiledTypeFormatterSetter)(void);
typedef id(^ParamValueConverterSetter)(id<AUIUgsvParamItemValueConverter>);

static EditabledSetter s_editabledSetter(__weak AUIUgsvParamBuilder *builder) {
    return ^(BOOL enabled) {
        builder.innerObj.currentItem.editabled = enabled;
        return builder;
    };
}

static IsHiddenDefaultSetter s_isHiddenDefaultSetter(__weak AUIUgsvParamBuilder *builder) {
    return ^(void) {
        builder.innerObj.currentItem.isHiddenDefault = YES;
        return builder;
    };
}

static OnValueDidChangeSetter s_onValueDidChangeSetter(__weak AUIUgsvParamBuilder *builder) {
    return ^(OnAUIUgsvParamValueDidChanged onChange) {
        NSCAssert(onChange, @"Please set onChange if you call the setter");
        OnAUIUgsvParamValueDidChanged oldChanged = builder.innerObj.currentItem.onValueDidChanged;
        if (oldChanged) {
            builder.innerObj.currentItem.onValueDidChanged = ^(id oldValue, id curValue) {
                oldChanged(oldValue, curValue);
                onChange(oldValue, curValue);
            };
        }
        else {
            builder.innerObj.currentItem.onValueDidChanged = onChange;
        }
        return builder;
    };
}

static KVCSetter s_kvcSetter(OnValueDidChangeSetter onValueChange, DefaultValueSetter defaultValueSetter) {
    return ^(NSObject *target, NSString *path) {
        defaultValueSetter([target valueForKeyPath:path]);
        return onValueChange(^(id _Nullable oldValue, id _Nullable curValue){
            [target setValue:curValue forKeyPath:path];
        });
    };
}

static TextfiledTypeFormatterSetter s_typeFormatterSetter(__weak AUIUgsvParamBuilder *builder, AUIUgsvParamItemValueType type) {
    return ^{
        AUIUgsvParamItemTextField *model = (AUIUgsvParamItemTextField *)builder.innerObj.currentItem;
        NSCAssert([model isKindOfClass:AUIUgsvParamItemTextField.class], @"配置错误！当前不是TextFiled类型");
        model.formatter = [AUIUgsvParamItemValueDefaultFormatter FormatterWithType:type];
        return builder;
    };
}

static ParamValueConverterSetter s_ParamValueConverterSetter(__weak AUIUgsvParamBuilder *builder) {
    return ^(id<AUIUgsvParamItemValueConverter> converter) {
        builder.innerObj.currentItem.converter = converter;
        return builder;
    };
}

// MARK: - AUIUgsvParamVisibleControl
@implementation AUIUgsvParamVisibleControl
- (void)updateWithShowParams:(NSArray<NSString *> *)showParams hiddenParams:(NSArray<NSString *> *)hiddenParams {
    if (!showParams) {
        showParams = @[];
    }
    if (!hiddenParams) {
        hiddenParams = @[];
    }
    _showParams = showParams.copy;
    _hiddenParams = hiddenParams.copy;
    if (self.onParamVisibleDidChanged) {
        self.onParamVisibleDidChanged(self.showParams, self.hiddenParams);
    }
}
@end

// MARK: - AUIUgsvParamOptionBuilder
@implementation AUIUgsvParamOptionBuilder
- (instancetype)initWithObj:(__BuilderInnerObject *)obj {
    self = [super initWithObj:obj];
    if (self) {
        [self setupOption];
    }
    return self;
}

- (instancetype)initWithObj:(__BuilderInnerObject *)obj label:(NSString *)label value:(id)value {
    self = [super initWithObj:obj];
    if (self) {
        self.innerObj.currentOption = [[AUIUgsvParamItemOption alloc] initWithLabel:label value:value];
        [self setupOption];
    }
    return self;
}

- (void)setupOption {
    __BuilderInnerObject *obj = self.innerObj;
    __weak typeof(self) weakSelf = self;
    _showParams = ^(NSArray<NSString *> *params) {
        [obj.currentOption setShowParams:params];
        return weakSelf;
    };
    _hideParams = ^(NSArray<NSString *> *params) {
        [obj.currentOption setHiddenParams:params];
        return weakSelf;
    };
}
@end

// MARK: - AUIUgsvParamRadioBuilder
@implementation AUIUgsvParamRadioBuilder
- (instancetype)initWithObj:(__BuilderInnerObject *)obj {
    self = [super initWithObj:obj];
    if (self) {
        [self setupRadio];
    }
    return self;
}

- (instancetype)initWithObj:(__BuilderInnerObject *)obj name:(NSString *)name label:(NSString *)label {
    self = [super initWithObj:obj];
    if (self) {
        self.innerObj.currentItem = [[AUIUgsvParamItemRadio alloc] initWithName:name label:label];
        [self setupRadio];
    }
    return self;
}

- (void)setupRadio {
    __BuilderInnerObject *obj = self.innerObj;
    __weak typeof(self) weakSelf = self;
    _option = ^(NSString *label, id value) {
        return [[AUIUgsvParamOptionBuilder alloc] initWithObj:obj label:label value:value];
    };
    _defaultValue = ^(id value) {
        obj.currentItem.defaultValue = value;
        return weakSelf;
    };
    _editabled = s_editabledSetter(weakSelf);
    _isHidden = s_isHiddenDefaultSetter(weakSelf);
    _onValueDidChange = s_onValueDidChangeSetter(weakSelf);
    _KVC = s_kvcSetter(_onValueDidChange, ^(id defaultValue) {
        weakSelf.defaultValue(defaultValue);
    });
    _converter = s_ParamValueConverterSetter(weakSelf);
}
@end

// MARK: - AUIUgsvParamSwitchBuilder
@implementation AUIUgsvParamSwitchBuilder
- (instancetype)initWithObj:(__BuilderInnerObject *)obj {
    self = [super initWithObj:obj];
    if (self) {
        [self setupSwitch];
    }
    return self;
}

- (instancetype)initWithObj:(__BuilderInnerObject *)obj name:(NSString *)name label:(NSString *)label {
    self = [super initWithObj:obj];
    if (self) {
        self.innerObj.currentItem = [[AUIUgsvParamItemSwitch alloc] initWithName:name label:label];
        [self setupSwitch];
    }
    return self;
}

- (void)setupSwitch {
    __BuilderInnerObject *obj = self.innerObj;
    __weak typeof(self) weakSelf = self;
    _defaultValue = ^(BOOL isOn) {
        obj.currentItem.defaultValue = @(isOn);
        return weakSelf;
    };
    _editabled = s_editabledSetter(weakSelf);
    _isHidden = s_isHiddenDefaultSetter(weakSelf);
    _showParams = ^(NSArray<NSString *> *params){
        AUIUgsvParamItemSwitch *model = (AUIUgsvParamItemSwitch *)obj.currentItem;
        NSCAssert([model isKindOfClass:AUIUgsvParamItemSwitch.class], @"参数类型错误");
        [model setShowParams:params];
        return weakSelf;
    };
    _hideParams = ^(NSArray<NSString *> *params){
        AUIUgsvParamItemSwitch *model = (AUIUgsvParamItemSwitch *)obj.currentItem;
        NSCAssert([model isKindOfClass:AUIUgsvParamItemSwitch.class], @"参数类型错误");
        [model setHiddenParams:params];
        return weakSelf;
    };
    _onValueDidChange = s_onValueDidChangeSetter(weakSelf);
    _KVC = s_kvcSetter(_onValueDidChange, ^(id defaultValue){
        weakSelf.defaultValue(((NSNumber *)defaultValue).boolValue);
    });
    _converter = s_ParamValueConverterSetter(weakSelf);
}
@end

// MARK: - AUIUgsvParamTextFieldBuilder
@implementation AUIUgsvParamTextFieldBuilder
- (instancetype)initWithObj:(__BuilderInnerObject *)obj {
    self = [super initWithObj:obj];
    if (self) {
        [self setupTextField];
    }
    return self;
}

- (instancetype)initWithObj:(__BuilderInnerObject *)obj name:(NSString *)name label:(NSString *)label {
    self = [super initWithObj:obj];
    if (self) {
        self.innerObj.currentItem = [[AUIUgsvParamItemTextField alloc] initWithName:name label:label];
        [self setupTextField];
    }
    return self;
}

- (void)setupTextField {
    __BuilderInnerObject *obj = self.innerObj;
    __weak typeof(self) weakSelf = self;
    _placeHolder = ^(NSString *value) {
        AUIUgsvParamItemTextField *model = (AUIUgsvParamItemTextField *)obj.currentItem;
        NSCAssert([model isKindOfClass:AUIUgsvParamItemTextField.class], @"参数类型错误");
        model.placeHolder = value;
        return weakSelf;
    };
    _unit = ^(NSString *value) {
        AUIUgsvParamItemTextField *model = (AUIUgsvParamItemTextField *)obj.currentItem;
        NSCAssert([model isKindOfClass:AUIUgsvParamItemTextField.class], @"参数类型错误");
        model.unit = value;
        return weakSelf;
    };
    _defaultValue = ^(NSString *value) {
        obj.currentItem.defaultValue = value;
        return weakSelf;
    };
    _editabled = s_editabledSetter(weakSelf);
    _isHidden = s_isHiddenDefaultSetter(weakSelf);
    _onValueDidChange = s_onValueDidChangeSetter(weakSelf);
    _KVC = s_kvcSetter(_onValueDidChange, ^(id defaultValue){
        weakSelf.defaultValue((NSString *)defaultValue);
    });
    _isInt = s_typeFormatterSetter(weakSelf, AUIUgsvParamItemValueTypeInt);
    _isFloat = s_typeFormatterSetter(weakSelf, AUIUgsvParamItemValueTypeFloat);
    _isString = s_typeFormatterSetter(weakSelf, AUIUgsvParamItemValueTypeString);
    _converter = s_ParamValueConverterSetter(weakSelf);
}
@end

// MARK: - AUIUgsvParamGroupBuilder
@implementation AUIUgsvParamGroupBuilder
- (instancetype)initWithObj:(__BuilderInnerObject *)obj {
    self = [super initWithObj:obj];
    if (self) {
        [self setupGroup];
    }
    return self;
}

- (instancetype) initWithObj:(__BuilderInnerObject *)obj name:(NSString *)name label:(NSString *)label {
    self = [super initWithObj:obj];
    if (self) {
        self.innerObj.currentGroup = [[AUIUgsvParamGroup alloc] initWithName:name label:label];
        [self setupGroup];
    }
    return self;
}

- (void)setupGroup {
    __BuilderInnerObject *obj = self.innerObj;
    _textFieldItem = ^(NSString *name, NSString *label) {
        return [[AUIUgsvParamTextFieldBuilder alloc] initWithObj:obj name:name label:label];
    };
    _switchItem = ^(NSString *name, NSString *label) {
        return [[AUIUgsvParamSwitchBuilder alloc] initWithObj:obj name:name label:label];
    };
    _radioItem = ^(NSString *name, NSString *label) {
        return [[AUIUgsvParamRadioBuilder alloc] initWithObj:obj name:name label:label];
    };
    __weak typeof(self) weakSelf = self;
    _isHiddenGroup = ^{
        obj.currentGroup.isHiddenDefault = YES;
        return weakSelf;
    };
}
@end

// MARK: - AUIUgsvParamBuilder
@implementation AUIUgsvParamBuilder

- (instancetype)initWithObj:(__BuilderInnerObject *)obj {
    self = [super init];
    if (self) {
        _innerObj = obj;
        _group = ^(NSString *name, NSString *label) {
            return [[AUIUgsvParamGroupBuilder alloc] initWithObj:obj name:name label:label];
        };
    }
    return self;
}

- (instancetype)init {
    return [self initWithObj:[__BuilderInnerObject new]];
}

- (AUIUgsvParamWrapper *)paramWrapper {
    return _innerObj.paramWrapper;
}

- (NSDictionary<NSString *, id> *)paramValues {
    return _innerObj.paramValues;
}

- (AUIUgsvParamItemModel *)findParamItemWithName:(NSString *)name {
    return [_innerObj.paramWrapper findParamItemWithName:name];
}

- (void)changeLastGroupWithName:(NSString *)name {
    [self.innerObj setCurrentGroupWithName:name];
}

- (AUIUgsvParamGroupBuilder *)lastGroup {
    if (self.innerObj.currentGroup) {
        return [[AUIUgsvParamGroupBuilder alloc] initWithObj:self.innerObj];
    }
    return nil;
}

- (AUIUgsvParamTextFieldBuilder *)lastTextField {
    AUIUgsvParamItemTextField *textField = (AUIUgsvParamItemTextField *)self.innerObj.currentItem;
    if ([textField isKindOfClass:AUIUgsvParamItemTextField.class]) {
        return [[AUIUgsvParamTextFieldBuilder alloc] initWithObj:self.innerObj];
    }
    return nil;
}

- (AUIUgsvParamSwitchBuilder *)lastSwitch {
    AUIUgsvParamItemSwitch *switchModel = (AUIUgsvParamItemSwitch *)self.innerObj.currentItem;
    if ([switchModel isKindOfClass:AUIUgsvParamItemSwitch.class]) {
        return [[AUIUgsvParamSwitchBuilder alloc] initWithObj:self.innerObj];
    }
    return nil;
}

- (AUIUgsvParamRadioBuilder *)lastRadio {
    AUIUgsvParamItemRadio *radioModel = (AUIUgsvParamItemRadio *)self.innerObj.currentItem;
    if ([radioModel isKindOfClass:AUIUgsvParamItemRadio.class]) {
        return [[AUIUgsvParamRadioBuilder alloc] initWithObj:self.innerObj];
    }
    return nil;
}

- (AUIUgsvParamOptionBuilder *)lastOption {
    if (self.innerObj.currentOption) {
        return [[AUIUgsvParamOptionBuilder alloc] initWithObj:self.innerObj];
    }
    return nil;
}

@end
