//
//  AUIVideoFunctionPlayCell.h
//  AliyunPlayerSampleDemo
//
//  Created by ISS013602000846 on 2022/11/9.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol AUIVideoFunctionPlayCellDelegate <NSObject>

/**
 执行下一条预加载方法的回调
 @param player 播放器实例
 */
- (void)startPreloadNextPlayAtPlayer:(AliPlayer *)player;
/**
 播放器实时进度回调
 @param position 当前位置
 @param player 播放器实例
*/
- (void)updateCurrentPosition:(int64_t)position atPlayer:(AliPlayer *)player;

@end

@interface AUIVideoFunctionPlayCell : UITableViewCell

@property (nonatomic, strong) AliPlayer *player;
/// player的当前播放状态
@property (nonatomic, assign) AVPStatus playStatus;
@property (nonatomic, weak) id<AUIVideoFunctionPlayCellDelegate> delegate;

/**
 设置播放源url
 @param url 播放源url
*/
- (void)setSource:(NSString *)url;

@end

NS_ASSUME_NONNULL_END
