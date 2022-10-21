//
//  AUIVideoFlowCardCell.h
//  ApsaraVideo
//
//  Created by Bingo on 2021/7/4.
//

#import <UIKit/UIKit.h>
#import "AlivcPlayerVideo.h"

NS_ASSUME_NONNULL_BEGIN

@class AUIVideoFlowCardCell;
@protocol AUIVideoFlowCardCellDelegate <NSObject>

- (void)homeCardCellDetailClick:(AUIVideoFlowCardCell *)cell;

- (void)homeCardCellPlayButtonClick:(AUIVideoFlowCardCell *)cell;

- (void)homeCardCellDidClickCommentButton:(AUIVideoFlowCardCell *)cell;



@end

@interface AUIVideoFlowCardCell : UICollectionViewCell

@property (nonatomic, strong) AlivcPlayerVideo *item;
@property (nonatomic, weak) id<AUIVideoFlowCardCellDelegate> delegate;
@property (nonatomic, strong, readonly) UIView *videoContainer;

@end

NS_ASSUME_NONNULL_END
