//
//  AUIEditorEditBar.h
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/6/9.
//

#import <UIKit/UIKit.h>
#import "AUIFoundation.h"
#import "AUIUgsvMacro.h"

#import "AUIEditorThumbnailCache.h"

#import "AUIEditorActionDef.h"
#import "AUIEditorSelectionManager.h"

NS_ASSUME_NONNULL_BEGIN


@interface AUIEditorEditBar : UIView <AUIEditorSelectionObserver, AUIEditorActionObserver, AUIVideoPlayObserver>

@property (nonatomic, strong, readonly) UIView *headerView;
@property (nonatomic, strong, readonly) UIView *headerLineView;
@property (nonatomic, strong, readonly) UILabel *titleView;
@property (nonatomic, strong, readonly) UIView *contentView;
@property (nonatomic, strong, readonly) UIView *menuView;

@property (nonatomic, weak) AUIEditorActionManager *actionManager;
@property (nonatomic, weak) AUIEditorSelectionManager *selectionManager;
@property (nonatomic, weak) AUIEditorThumbnailCache *thumbnailCache;

@property (nonatomic, assign, readonly) BOOL isAppear;
- (void)barWillAppear;
- (void)barWillDisappear;
- (void)refreshPlayTime;

+ (CGFloat)contentHeight;

@end

@interface AUIEditorEditBar (Helper)

+ (UIButton *)createAddButton:(NSString *)title;
+ (UIButton *)createRemoveButton;
+ (AVBaseButton *)createMenuButton:(NSString *)title image:(UIImage *)image;

@end

NS_ASSUME_NONNULL_END
