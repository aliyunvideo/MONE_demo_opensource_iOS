//
//  AUIUgsvParamModel_Inner.h
//  AlivcUgsvDemo
//
//  Created by coder.pi on 2022/6/14.
//

#ifndef AUIUgsvParamModel_Inner_h
#define AUIUgsvParamModel_Inner_h

#import "AUIUgsvParamModel.h"

typedef void(^OnParamVisibleDidChanged)(NSArray<NSString *> *showParams, NSArray<NSString *> *hiddenParams);
@interface AUIUgsvParamVisibleControl : NSObject
@property (nonatomic, readonly) NSArray<NSString *> *showParams;
@property (nonatomic, readonly) NSArray<NSString *> *hiddenParams;
@property (nonatomic, copy) OnParamVisibleDidChanged onParamVisibleDidChanged;
- (void)updateWithShowParams:(NSArray<NSString *> *)showParams hiddenParams:(NSArray<NSString *> *)hiddenParams;
@end

@protocol AUIUgsvParamVisibleControlItem <NSObject>
- (AUIUgsvParamVisibleControl *)paramVisibleControl;
@end

@interface AUIUgsvParamBaseModel (Inner)
- (instancetype)initWithName:(NSString *)name label:(NSString *)label;
- (void)setIsHiddenDefault:(BOOL)isHiddenDefault;
@end

@interface AUIUgsvParamItemModel (Inner)
- (void)setParamValue:(id)paramValue;
- (void)setDefaultValue:(id)defaultValue;
- (void)setConverter:(id<AUIUgsvParamItemValueConverter>)converter;
- (void)onValueDidChangeFrom:(id)oldValue to:(id)curValue;
@end

@interface AUIUgsvParamGroup (Inner)
- (void)addItem:(AUIUgsvParamItemModel *)item;
@end

@interface AUIUgsvParamItemTextField (Inner)
- (void)setPlaceHolder:(NSString *)placeHolder;
- (void)setUnit:(NSString *)unit;
- (void)setFormatter:(id<AUIUgsvParamItemValueFormatter>)formatter;
@end

@interface AUIUgsvParamItemSwitch (Inner)<AUIUgsvParamVisibleControlItem>
- (AUIUgsvParamVisibleControl *)paramVisibleControl;
- (void)setShowParams:(NSArray<NSString *> *)showParams;
- (void)setHiddenParams:(NSArray<NSString *> *)hiddenParams;
@end

@interface AUIUgsvParamItemOption (Inner)
- (void)setShowParams:(NSArray<NSString *> *)showParams;
- (void)setHiddenParams:(NSArray<NSString *> *)hiddenParams;
@end

@interface AUIUgsvParamItemRadio (Inner)<AUIUgsvParamVisibleControlItem>
- (AUIUgsvParamVisibleControl *)paramVisibleControl;
- (void)addOption:(AUIUgsvParamItemOption *)option;
@end

@interface AUIUgsvParamWrapper (Inner)
- (instancetype)initWithParams:(NSArray<AUIUgsvParamGroup *> *)params;
@end

#endif /* AUIUgsvParamModel_Setter_h */
