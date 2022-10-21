//
//  AUIEditorActionManager.h
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/5/31.
//

#import <UIKit/UIKit.h>
#import "AUIEditorActionItem.h"

@protocol AUIEditorActionObserver <NSObject>

@optional
- (void)actionItem:(AUIEditorActionItem *)item doActionResult:(NSError *)error retObject:(id)retObject;

@end

@interface AUIEditorActionManager : NSObject

@property (nonatomic, weak) id<AUIEditorActionOperator> currentOperator;

- (void)addObserver:(id<AUIEditorActionObserver>)observer;
- (void)removeObserver:(id<AUIEditorActionObserver>)observer;

- (BOOL)doAction:(AUIEditorActionItem *)item;

@end
