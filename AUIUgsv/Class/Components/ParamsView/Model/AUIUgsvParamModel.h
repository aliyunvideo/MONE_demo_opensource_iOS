//
//  AUIUgsvParamModel.h
//  AlivcUgsvDemo
//
//  Created by coder.pi on 2022/6/13.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// MARK: - Base
typedef NS_ENUM(NSUInteger, AUIUgsvParamItemType) {
    AUIUgsvParamItemTypeTextField,
    AUIUgsvParamItemTypeRadio,
    AUIUgsvParamItemTypeSwitch,
};

@interface AUIUgsvParamBaseModel : NSObject
@property (nonatomic, readonly) BOOL isGroup;
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *label;
@property (nonatomic, readonly) BOOL isHiddenDefault;
@end

// MARK: - ValueConvert
typedef NS_ENUM(NSUInteger, AUIUgsvParamItemValueType) {
    AUIUgsvParamItemValueTypeInt,
    AUIUgsvParamItemValueTypeFloat,
    AUIUgsvParamItemValueTypeString,
    AUIUgsvParamItemValueTypeCustom,
};
@protocol AUIUgsvParamItemValueFormatter <NSObject>
- (AUIUgsvParamItemValueType)valueType;
- (NSString *)fromValueToString:(id)value;
- (id)fromStringToValue:(NSString *)text;
@end

@interface AUIUgsvParamItemValueDefaultFormatter : NSObject<AUIUgsvParamItemValueFormatter>
@property (nonatomic, readonly) AUIUgsvParamItemValueType type;
+ (AUIUgsvParamItemValueDefaultFormatter *)FormatterWithType:(AUIUgsvParamItemValueType)type;
@end

@protocol AUIUgsvParamItemValueConverter <NSObject>
- (id)fromParamToValue:(id)param;
- (id)fromValueToParam:(id)value;
@end

// MARK: - ItemBase
@class AUIUgsvParamItemModel;
@protocol AUIUgsvParamItemModelDelegate <NSObject>
- (void) onAUIUgsvParamItemModelDidChange:(AUIUgsvParamItemModel *)model;
@end

typedef void(^OnAUIUgsvParamValueDidChanged)(id _Nullable oldValue, id _Nullable curValue);
@interface AUIUgsvParamItemModel : AUIUgsvParamBaseModel
@property (nonatomic, weak) id<AUIUgsvParamItemModelDelegate> delegate;
@property (nonatomic, readonly) AUIUgsvParamItemType type;
@property (nonatomic, assign) BOOL editabled;
@property (nonatomic, readonly, nullable) id paramValue;
@property (nonatomic, readonly, nullable) id defaultParamValue;
@property (nonatomic, readonly, nullable) NSString *showValue;
@property (nonatomic, copy, nullable) OnAUIUgsvParamValueDidChanged onValueDidChanged;
@property (nonatomic, readonly, nullable) id<AUIUgsvParamItemValueConverter> converter;
- (instancetype)initWithType:(AUIUgsvParamItemType)type
                        name:(NSString *)name
                       label:(NSString *)label;
@end

// MARK: - TextField
@interface AUIUgsvParamItemTextField : AUIUgsvParamItemModel
@property (nonatomic, copy) NSString *text;
@property (nonatomic, readonly, nullable) NSString *placeHolder;
@property (nonatomic, readonly, nullable) NSString *unit;
@property (nonatomic, readonly) id<AUIUgsvParamItemValueFormatter> formatter;
- (instancetype)initWithName:(NSString *)name label:(NSString *)label;
@end

// MARK: - Switch
@interface AUIUgsvParamItemSwitch : AUIUgsvParamItemModel
@property (nonatomic, assign) BOOL isOn;
- (instancetype)initWithName:(NSString *)name label:(NSString *)label;
@end

// MARK: - Radio
@interface AUIUgsvParamItemOption : NSObject
@property (nonatomic, readonly) NSString *label;
@property (nonatomic, readonly) id optionValue;
- (instancetype)initWithLabel:(NSString *)label value:(id)value;
@end

@interface AUIUgsvParamItemRadio : AUIUgsvParamItemModel
@property (nonatomic, readonly) NSArray<AUIUgsvParamItemOption *> *options;
@property (nonatomic, readonly) NSArray<NSString *> *optionsLabel;
@property (nonatomic, readonly) AUIUgsvParamItemOption *selectedOption;
@property (nonatomic, assign) NSUInteger selectedIndex;
- (instancetype)initWithName:(NSString *)name label:(NSString *)label;
@end

// MARK: - ParamWrapper
@interface AUIUgsvParamGroup : AUIUgsvParamBaseModel
@property (nonatomic, readonly) NSArray<AUIUgsvParamItemModel *> *items;
- (instancetype)initWithName:(NSString *)name label:(NSString *)label;
@end

@interface AUIUgsvParamWrapper : NSObject
@property (nonatomic, readonly) NSArray<AUIUgsvParamGroup *> *allParams;
@property (nonatomic, readonly) NSArray<AUIUgsvParamGroup *> *showingParams;
@property (nonatomic, copy, nullable) void(^onShowingParamsDidChanged)(NSArray<AUIUgsvParamGroup *> *showing);
- (AUIUgsvParamItemModel *)findParamItemWithName:(NSString *)name;
@end

NS_ASSUME_NONNULL_END
