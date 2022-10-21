//
//  AUIEditorActionManager.m
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/5/31.
//

#import "AUIEditorActionManager.h"
#import "AUIEditorActionItem.h"

@interface AUIEditorActionManager ()

@property (nonatomic, strong) NSHashTable<id<AUIEditorActionObserver>> *observerTable;
@property (nonatomic, strong) NSMutableArray<AUIEditorActionItem *> *itemList;

@end

@implementation AUIEditorActionManager

- (instancetype)init {
    self = [super init];
    if (self) {
        _itemList = [NSMutableArray array];
    }
    return self;
}

// MARK: observer

- (NSHashTable<id<AUIEditorActionObserver>> *)observerTable {
    if (!_observerTable) {
        _observerTable = [NSHashTable weakObjectsHashTable];
    }
    return _observerTable;
}

- (void)addObserver:(id<AUIEditorActionObserver>)observer {
    if ([self.observerTable containsObject:observer])
    {
        return;
    }
    [self.observerTable addObject:observer];
}

- (void)removeObserver:(id<AUIEditorActionObserver>)observer {
    [self.observerTable removeObject:observer];
}

- (void)raiseActionResult:(AUIEditorActionItem *)sender error:(NSError *)error retObject:(id)retObject {
    NSEnumerator<id<AUIEditorActionObserver>>* enumerator = [self.observerTable objectEnumerator];
    id<AUIEditorActionObserver> observer = nil;
    while ((observer = [enumerator nextObject]))
    {
        if ([observer respondsToSelector:@selector(actionItem:doActionResult:retObject:)])
        {
            [observer actionItem:sender doActionResult:error retObject:retObject];
        }
    }
    [self.itemList removeObject:sender];
}

- (BOOL)doAction:(AUIEditorActionItem *)item {
    item.currentOperator = self.currentOperator;
    [self.itemList addObject:item];
    __weak typeof(self) weakSelf = self;
    return [item doAction:^(AUIEditorActionItem *sender, NSError *error, id retObject) {
        if (!error) {
            [weakSelf.currentOperator markEditorProjectChanged];
        }
        [weakSelf raiseActionResult:sender error:error retObject:retObject];
    }];
}

@end
