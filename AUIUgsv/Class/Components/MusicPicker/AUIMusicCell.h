//
//  AUIMusicCell.h
//  AlivcUgsvDemo
//
//  Created by coder.pi on 2022/6/8.
//

#import <UIKit/UIKit.h>
#import "AUIMusicStateModel.h"
#import "AUIVideoPlayProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@class AUIMusicCell;
@protocol AUIMusicCellDelegate <NSObject>
- (void) onAUIMusicCell:(AUIMusicCell *)cell stateDidChange:(AUIMusicResourceState)state;
- (void) onAUIMusicCell:(AUIMusicCell *)cell didCropMusic:(AUIMusicSelectedModel *)selectedModel;
@end

@interface AUIMusicCell : UITableViewCell
@property (nonatomic, weak) id<AUIMusicCellDelegate> delegate;
@property (nonatomic, strong) AUIMusicStateModel *model;
@property (nonatomic, assign) BOOL isShowCropView;
@property (nonatomic, weak) id<AUIVideoPlayProtocol> player;
@property (nonatomic, assign) NSTimeInterval limitDuration;
@property (nonatomic, strong, nullable) AUIMusicSelectedModel *selectedModel;
@end

NS_ASSUME_NONNULL_END
