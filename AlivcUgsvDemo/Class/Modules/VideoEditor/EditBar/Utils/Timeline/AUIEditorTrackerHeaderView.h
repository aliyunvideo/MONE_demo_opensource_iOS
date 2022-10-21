//
//  AUIEditorTrackerHeaderView.h
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/6/24.
//

#import <UIKit/UIKit.h>
#import <AUIUgsvCom/AUIUgsvCom.h>
#import "AUIUgsvMacro.h"
#import "AUIEditorActionDef.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUIEditorTrackerHeaderView : UIView

@property (nonatomic, strong, readonly) AVBaseButton *volumeBtn;
@property (nonatomic, strong, readonly) AVBaseButton *coverBtn;
@property (nonatomic, weak) AUIEditorActionManager *actionManager;

- (void)refreshVolumeState;
- (void)startCapture;

+ (AUIEditorTrackerHeaderView *)main;

@end

@interface AUIEditorTrackerHeaderViewLoader : AUITrackerHeaderViewLoader

- (instancetype)initWithHeaderView:(AUIEditorTrackerHeaderView *)headerView;

@property (nonatomic, strong, readonly) AUIEditorTrackerHeaderView *headerView;

@end

NS_ASSUME_NONNULL_END
