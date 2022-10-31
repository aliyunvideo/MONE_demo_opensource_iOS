//
//  AUIEditorSelectionObject.h
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/5/30.
//

#import <Foundation/Foundation.h>
#import "AlivcUgsvSDKHeader.h"

typedef NS_ENUM(NSInteger, AUIEditorSelectionObjectType) {
    AUIEditorSelectionObjectTypeNone = 0,
    AUIEditorSelectionObjectTypeText,
    AUIEditorSelectionObjectTypeSticker,
};

@interface AUIEditorSelectionObject : NSObject

@property (nonatomic, assign, readonly) AUIEditorSelectionObjectType type;
@property (nonatomic, strong) id aepObject;

- (AliyunRenderBaseController *)renderController;

+ (AUIEditorSelectionObject *)selectionObject:(id)aepObject;

@end
