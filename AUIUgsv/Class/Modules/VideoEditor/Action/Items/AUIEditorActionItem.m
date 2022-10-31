//
//  AUIEditorActionItem.m
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/5/31.
//

#import "AUIEditorActionItem.h"

@implementation AUIEditorActionItem

- (AliyunEditor *)currentEditor {
    return self.currentOperator.currentEditor;
}

- (AUIEditorPlay *)currentPlayer {
    return self.currentOperator.currentPlayer;
}

AUI_ACTION_METHOD_DESC(nil)
AUI_ACTION_METHOD_NAME(nil)

- (BOOL)doAction:(void(^)(AUIEditorActionItem *sender, NSError *error, id retObject))completed {
    if (completed) {
        completed(self, [[NSError alloc] initWithDomain:@"" code:-1 userInfo:nil], nil);
    }
    return NO;
}

@end

@implementation AUIEditorActionItem (InputHelper)

- (NSDictionary *)inputDict {
    if ([self.input isKindOfClass:NSDictionary.class]) {
        return self.input;
    }
    return self.input;
}

- (void)setInputObject:(id)obj forKey:(NSString *)key {
    if ([self.input isKindOfClass:NSMutableDictionary.class]) {
        [(NSMutableDictionary *)self.input setObject:obj forKey:key];
    }
    else {
        self.input = [NSMutableDictionary dictionary];
        [self setInputObject:obj forKey:key];
    }
}

- (id)objectForKey:(NSString *)key {
    return [self.inputDict objectForKey:key];
}

@end
