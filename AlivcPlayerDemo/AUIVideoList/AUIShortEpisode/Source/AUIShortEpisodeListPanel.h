//
//  AUIShortEpisodeListPanel.h
//  AlivcPlayerDemo
//
//  Created by Bingo on 2023/9/17.
//

#import "AUIFoundation.h"
#import "AUIShortEpisodeData.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUIShortEpisodeListPanel : AVBaseCollectionControllPanel

@property (nonatomic, copy) void(^onVideoSelectedBlock)(AUIShortEpisodeListPanel *sender, AUIVideoInfo *videoInfo);
- (instancetype)initWithFrame:(CGRect)frame withEpisodeData:(AUIShortEpisodeData *)episodeData withPlaying:(AUIVideoInfo *)videoInfo;

+ (void)setPanelHeight:(AUIShortEpisodeData *)episodeData max:(CGFloat)max;

@end

NS_ASSUME_NONNULL_END
