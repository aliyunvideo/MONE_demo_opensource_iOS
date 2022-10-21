//
//  AUIVideoEditorUtils.h
//  AlivcUgsvDemo
//
//  Created by coder.pi on 2022/6/23.
//

#import <Foundation/Foundation.h>
#import "AUIFoundation.h"
#import "AUIEditorActionItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUIVideoEditorUtils : NSObject
+ (AVBaseButton *) SettingForAllButton;
@end


typedef void(^OnSettingForAllDidChanged)(BOOL isSettingForAll);
@interface AUIVideoEditorHelperSettingForAll : NSObject
@property (nonatomic, readonly) NSString *saveKey;
@property (nonatomic, readonly) AVBaseButton *button;
@property (nonatomic, weak) id<AUIEditorActionOperator> actionOperator;
@property (nonatomic, assign) BOOL isOn;
@property (nonatomic, readonly) BOOL isOnByDefault;
@property (nonatomic, copy) OnSettingForAllDidChanged onChanged;
+ (AUIVideoEditorHelperSettingForAll *) SettingForKey:(NSString *)key onChanged:(OnSettingForAllDidChanged)onChanged;
@end

NS_ASSUME_NONNULL_END
