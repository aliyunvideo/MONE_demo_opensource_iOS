//
//  AUIEditorFilterActionItem.m
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/5/31.
//

#import "AUIEditorFilterActionItem.h"
#import "AUIFilterModel.h"



@implementation AUIEditorFilterSetActionItem

AUI_ACTION_METHOD_DESC(@"Add a sticker to editor")

- (BOOL)doAction:(void (^)(AUIEditorActionItem *, NSError *, id))completed {
    
    AliyunFilterManager *filterManager = [self.currentEditor getFilterManager];
    if (self.model.isEmpty) {
        [filterManager removeFilter:filterManager.getShaderFilterControllers.firstObject];
        if (completed) {
            completed(self, nil, nil);
        }
        return YES;
    }
    
    NSString *path = self.model.resourcePath;
    AliyunShaderFilterController *filterController = [filterManager applyShadeFilterWithPath:path];
    
    NSError *error = nil;
    if (!filterController) {
        error = [NSError errorWithDomain:@"filter.editor" code:ALIVC_COMMON_RETURN_FAILED userInfo:nil];
    }
    
    if (completed) {
        completed(self, error, filterController);
    }
    return error == nil;
}

AUI_ACTION_METHOD_APPLY_OBJECT(AUIFilterModel, model)

@end
