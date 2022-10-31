//
//  AUIUgsvParamBuilder.h
//  AlivcUgsvDemo
//
//  Created by coder.pi on 2022/6/14.
//

#import <Foundation/Foundation.h>
#import "AUIUgsvParamModel.h"

NS_ASSUME_NONNULL_BEGIN

@class AUIUgsvParamGroupBuilder;
@class AUIUgsvParamTextFieldBuilder;
@class AUIUgsvParamSwitchBuilder;
@class AUIUgsvParamRadioBuilder;
@class AUIUgsvParamOptionBuilder;

@interface AUIUgsvParamBuilder : NSObject
@property (nonatomic, readonly) AUIUgsvParamWrapper *paramWrapper;
@property (nonatomic, readonly) NSDictionary<NSString *, id> *paramValues;
@property (nonatomic, readonly) AUIUgsvParamGroupBuilder*(^group)(NSString *name, NSString *label);
@property (nonatomic, readonly) AUIUgsvParamGroupBuilder *lastGroup;
@property (nonatomic, readonly) AUIUgsvParamTextFieldBuilder *lastTextField;
@property (nonatomic, readonly) AUIUgsvParamSwitchBuilder *lastSwitch;
@property (nonatomic, readonly) AUIUgsvParamRadioBuilder *lastRadio;
@property (nonatomic, readonly) AUIUgsvParamOptionBuilder *lastOption;
- (AUIUgsvParamItemModel *)findParamItemWithName:(NSString *)name;
@end

@interface AUIUgsvParamGroupBuilder : AUIUgsvParamBuilder
@property (nonatomic, readonly) AUIUgsvParamTextFieldBuilder*(^textFieldItem)(NSString *name, NSString *label);
@property (nonatomic, readonly) AUIUgsvParamSwitchBuilder*(^switchItem)(NSString *name, NSString *label);
@property (nonatomic, readonly) AUIUgsvParamRadioBuilder*(^radioItem)(NSString *name, NSString *label);
@property (nonatomic, readonly) AUIUgsvParamGroupBuilder*(^isHiddenGroup)(void);
@end

@interface AUIUgsvParamTextFieldBuilder : AUIUgsvParamGroupBuilder
@property (nonatomic, readonly) AUIUgsvParamTextFieldBuilder*(^placeHolder)(NSString *);
@property (nonatomic, readonly) AUIUgsvParamTextFieldBuilder*(^unit)(NSString *);
@property (nonatomic, readonly) AUIUgsvParamTextFieldBuilder*(^defaultValue)(NSString *);
@property (nonatomic, readonly) AUIUgsvParamTextFieldBuilder*(^editabled)(BOOL);
@property (nonatomic, readonly) AUIUgsvParamTextFieldBuilder*(^isHidden)(void);
@property (nonatomic, readonly) AUIUgsvParamTextFieldBuilder*(^onValueDidChange)(OnAUIUgsvParamValueDidChanged);
@property (nonatomic, readonly) AUIUgsvParamTextFieldBuilder*(^KVC)(NSObject *target, NSString *path);
@property (nonatomic, readonly) AUIUgsvParamTextFieldBuilder*(^isInt)(void);
@property (nonatomic, readonly) AUIUgsvParamTextFieldBuilder*(^isFloat)(void);
@property (nonatomic, readonly) AUIUgsvParamTextFieldBuilder*(^isString)(void);
@property (nonatomic, readonly) AUIUgsvParamTextFieldBuilder*(^converter)(id<AUIUgsvParamItemValueConverter>);
@end

@interface AUIUgsvParamSwitchBuilder : AUIUgsvParamGroupBuilder
@property (nonatomic, readonly) AUIUgsvParamSwitchBuilder*(^defaultValue)(BOOL);
@property (nonatomic, readonly) AUIUgsvParamSwitchBuilder*(^editabled)(BOOL);
@property (nonatomic, readonly) AUIUgsvParamSwitchBuilder*(^isHidden)(void);
@property (nonatomic, readonly) AUIUgsvParamSwitchBuilder*(^showParams)(NSArray<NSString *> *);
@property (nonatomic, readonly) AUIUgsvParamSwitchBuilder*(^hideParams)(NSArray<NSString *> *);
@property (nonatomic, readonly) AUIUgsvParamSwitchBuilder*(^onValueDidChange)(OnAUIUgsvParamValueDidChanged);
@property (nonatomic, readonly) AUIUgsvParamSwitchBuilder*(^KVC)(NSObject *target, NSString *path);
@property (nonatomic, readonly) AUIUgsvParamSwitchBuilder*(^converter)(id<AUIUgsvParamItemValueConverter>);
@end

@interface AUIUgsvParamRadioBuilder : AUIUgsvParamGroupBuilder
@property (nonatomic, readonly) AUIUgsvParamOptionBuilder*(^option)(NSString *label, id value);
@property (nonatomic, readonly) AUIUgsvParamRadioBuilder*(^defaultValue)(id);
@property (nonatomic, readonly) AUIUgsvParamRadioBuilder*(^editabled)(BOOL);
@property (nonatomic, readonly) AUIUgsvParamRadioBuilder*(^isHidden)(void);
@property (nonatomic, readonly) AUIUgsvParamRadioBuilder*(^onValueDidChange)(OnAUIUgsvParamValueDidChanged);
@property (nonatomic, readonly) AUIUgsvParamRadioBuilder*(^KVC)(NSObject *target, NSString *path);
@property (nonatomic, readonly) AUIUgsvParamRadioBuilder*(^converter)(id<AUIUgsvParamItemValueConverter>);
@end

@interface AUIUgsvParamOptionBuilder : AUIUgsvParamRadioBuilder
@property (nonatomic, readonly) AUIUgsvParamOptionBuilder*(^showParams)(NSArray<NSString *> *);
@property (nonatomic, readonly) AUIUgsvParamOptionBuilder*(^hideParams)(NSArray<NSString *> *);
@end

NS_ASSUME_NONNULL_END
