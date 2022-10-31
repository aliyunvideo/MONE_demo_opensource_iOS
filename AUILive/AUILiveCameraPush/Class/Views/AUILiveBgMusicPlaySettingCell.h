//
//  AUILiveBgMusicPlaySettingCell.h
//  AlivcLiveDemo
//
//  Created by ISS013602000846 on 2022/7/6.
//

#import <UIKit/UIKit.h>
#import "AlivcLiveMusicInfoModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, AUILiveBgMusicPlayStatus) {
    AUILiveBgMusicPlayStatusNone = 0,
    AUILiveBgMusicPlayStatusStart,
    AUILiveBgMusicPlayStatusPause,
    AUILiveBgMusicPlayStatusResume,
    AUILiveBgMusicPlayStatusStop,
};

@interface AUILiveBgMusicPlaySettingCell : UITableViewCell

@property (nonatomic, copy) void(^switchMuteAction)(BOOL open);
@property (nonatomic, copy) void(^switchPlayAction)(AUILiveBgMusicPlayStatus status, NSString *playPath);
@property (nonatomic, copy) void(^switchLoopAction)(BOOL open);
@property (nonatomic, copy) void(^accompanimentChangeAction)(int value);
@property (nonatomic, copy) void(^humanVoiceChangeAction)(int value);

- (void)startPlayWithModel:(AlivcLiveMusicInfoModel *)model;
- (void)updatePlayProgressTime:(long)progressTime durationTime:(long)durationTime;
- (void)resetPlayStatusWithError;

@end

NS_ASSUME_NONNULL_END
