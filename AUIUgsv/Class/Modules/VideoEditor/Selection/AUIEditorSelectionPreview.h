//
//  AUIEditorSelectionPreview.h
//  AliyunVideo
//
//  Created by Vienta on 2017/3/7.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AliyunRenderBaseController;
@class AUIEditorActionManager;
@class AUIEditorSelectionManager;

@interface AUIEditorSelectionPreview : UIView

@property (nonatomic, weak) AUIEditorActionManager *actionManager;
@property (nonatomic, weak) AUIEditorSelectionManager *selectionManager;

@property (nonatomic, assign) BOOL enableEdit;
@property (nonatomic, copy) void(^onEditBlock)(void);

- (instancetype)initWithRenderBaseController:(AliyunRenderBaseController *)stickerController;

- (void)updateLayout;

@end
