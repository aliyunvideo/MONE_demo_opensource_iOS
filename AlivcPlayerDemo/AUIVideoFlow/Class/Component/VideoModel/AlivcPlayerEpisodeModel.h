//
//  AlivcPlayerEpisodeModel.h
//  ApsaraVideo
//
//  Created by mengyehao on 2021/7/22.
//

//选集
#import "AlivcPlayerVideo.h"

NS_ASSUME_NONNULL_BEGIN

@interface AlivcPlayerEpisodeModel : AlivcPlayerVideo
@property (nonatomic, assign)  int64_t episodeId;
@property (nonatomic, assign)  int64_t parentVodId;
@property (nonatomic, assign)  NSInteger  episodeNum;

@end

NS_ASSUME_NONNULL_END
