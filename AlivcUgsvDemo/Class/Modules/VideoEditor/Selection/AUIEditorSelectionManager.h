//
//  AUIEditorSelectionManager.h
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/5/30.
//

#import <Foundation/Foundation.h>
#import "AUIEditorSelectionObject.h"
#import "AUIEditorActionDef.h"
#import "AUIEditorSelectionPreview.h"

@class AUIEditorSelectionManager;
@protocol AUIEditorSelectionObserver <NSObject>

@optional
- (void)selectionManager:(AUIEditorSelectionManager *)manger didSelected:(AUIEditorSelectionObject *)selectionObject;
- (void)selectionManagerDidUnselected:(AUIEditorSelectionManager *)manger;


- (void)selectionManager:(AUIEditorSelectionManager *)manger didShowPreview:(AUIEditorSelectionPreview *)preview;
- (void)selectionManager:(AUIEditorSelectionManager *)manger willHidePreview:(AUIEditorSelectionPreview *)preview;

@end

@interface AUIEditorSelectionManager : NSObject

@property (nonatomic, strong, readonly) AUIEditorSelectionObject *selectionObject;

@property (nonatomic, weak) UIView *selectionPreviewSuperView;
@property (nonatomic, assign) BOOL enableSelectionPreview;
@property (nonatomic, strong, readonly) AUIEditorSelectionPreview *currentSelectionPreview;


- (instancetype)initWithActionManager:(AUIEditorActionManager *)actionManager;

- (void)addObserver:(id<AUIEditorSelectionObserver>)observer;
- (void)removeObserver:(id<AUIEditorSelectionObserver>)observer;

- (BOOL)selectFromDisplayViewPosition:(CGPoint)point;
- (BOOL)select:(id)aepObject;
- (BOOL)unselect;

@end
