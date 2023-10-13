//
//  AUIEditorActionItem.h
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/5/31.
//

#import <UIKit/UIKit.h>
#import "AUIFoundation.h"
#import "AlivcUgsvSDKHeader.h"
#import "AUIEditorPlay.h"


@protocol AUIEditorActionOperator <NSObject>

- (AliyunEditor *)currentEditor;
- (AUIEditorPlay *)currentPlayer;
- (UIViewController *)currentVC;

- (id)associatedObjectForKey:(NSString *)key;
- (void)setAssociatedObject:(id)object forKey:(NSString *)key;

- (void)enterVideoMode;
- (void)enterCaptionMode;
- (void)enterStickerMode;
- (void)enterFilterMode;
- (void)enterEffectMode;

- (void)markEditorProjectChanged;
- (void)markEditorNeedUpdatePlayTime;

@end

@interface AUIEditorActionItem : NSObject

@property (nonatomic, copy, readonly) NSString *desc;
@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, strong) id input;

@property (nonatomic, weak) id<AUIEditorActionOperator> currentOperator;
@property (nonatomic, readonly) AliyunEditor *currentEditor;
@property (nonatomic, readonly) AUIEditorPlay *currentPlayer;


- (BOOL)doAction:(void(^)(AUIEditorActionItem *sender, NSError *error, id retObject))completed;

@end

#define AUI_ACTION_METHOD_NAME(NAME) \
- (NSString *)name {      \
    return NAME;          \
}

#define AUI_ACTION_METHOD_DESC(DESC) \
- (NSString *)desc {      \
    return DESC;          \
}

#define AUI_ACTION_METHOD_APPLY_OBJECT(CLASS, NAME)    \
- (CLASS *)NAME {                \
    return (CLASS *)self.input;         \
}

@interface AUIEditorActionItem (InputHelper)

@property (nonatomic, strong, readonly) NSDictionary *inputDict;
- (void)setInputObject:(id)value forKey:(NSString *)key;
- (id)objectForKey:(NSString *)key;

@end
