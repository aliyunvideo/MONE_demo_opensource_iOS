//
//  AUIShortEpisodePlayCell.h
//  AlivcPlayerDemo
//
//  Created by Bingo on 2023/9/14.
//

#import "AUIFoundation.h"
#import "AUIShortEpisodeData.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUIShortEpisodePlayCell : UICollectionViewCell

@property (nonatomic, copy) void(^onBackBtnClickBlock)(AUIShortEpisodePlayCell *cell);
@property (nonatomic, copy) void(^onPlayBtnClickBlock)(AUIShortEpisodePlayCell *cell);
@property (nonatomic, copy) void(^onLikeBtnClickBlock)(AUIShortEpisodePlayCell *cell, AVBaseButton *likeBtn);
@property (nonatomic, copy) void(^onCommentBtnClickBlock)(AUIShortEpisodePlayCell *cell, AVBaseButton *commentBtn);
@property (nonatomic, copy) void(^onShareBtnClickBlock)(AUIShortEpisodePlayCell *cell, AVBaseButton *shareBtn);
@property (nonatomic, copy) void(^onEntranceViewClickBlock)(AUIShortEpisodePlayCell *cell);
@property (nonatomic, copy) void(^onProgressViewDragingBlock)(AUIShortEpisodePlayCell *cell, CGFloat progress);


@property (nonatomic, strong, readonly) UIView *playerView;
@property (nonatomic, strong) AUIVideoInfo* videoInfo;
@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, assign) BOOL isPause;
@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, copy) NSString* episodeTitle;
- (void)refreshUI;

@end

NS_ASSUME_NONNULL_END
