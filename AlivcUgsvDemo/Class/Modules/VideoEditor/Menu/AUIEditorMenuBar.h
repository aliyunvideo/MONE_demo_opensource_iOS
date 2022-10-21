//
//  AUIEditorMenuBar.h
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/5/30.
//

#import <UIKit/UIKit.h>
#import "AUIEditorActionDef.h"
#import "AUIEditorSelectionManager.h"

@interface AUIEditorMenuBar : UIView

@property (nonatomic, weak) AUIEditorActionManager *actionManager;
@property (nonatomic, weak) AUIEditorSelectionManager *selectionManager;

@end
