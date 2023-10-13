//
//  AUIShortEpisodePlayer.h
//  AlivcPlayerDemo
//
//  Created by Bingo on 2023/9/19.
//

#import <Foundation/Foundation.h>
#import "AUIShortEpisodeData.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUIShortEpisodePlayer : NSObject

@property (nonatomic, copy) void(^onPlayProgressBlock)(CGFloat progress);
@property (nonatomic, copy) void(^onPlayPauseBlock)(BOOL isPause);
@property (nonatomic, copy) void(^onLoadCompletedBlock)(void);

- (void)setupPlayer:(AUIShortEpisodeData *)episodeData;
- (void)destroyPlayer;
- (void)pause:(BOOL)isPause;
- (void)stop;
- (BOOL)play:(AUIVideoInfo *)videoInfo playerView:(UIView * _Nullable)playerView;;
- (void)seek:(CGFloat)progress;
- (BOOL)startPreloadNext:(UIView * _Nullable)playerView;

@end

NS_ASSUME_NONNULL_END
