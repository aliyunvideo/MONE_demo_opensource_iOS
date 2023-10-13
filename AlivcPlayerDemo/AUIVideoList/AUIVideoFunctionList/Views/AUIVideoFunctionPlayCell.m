//
//  AUIVideoFunctionPlayCell.m
//  AUIVideoList
//
//  Created by ISS013602000846 on 2022/11/9.
//

#import "AUIVideoFunctionPlayCell.h"
#define SCREEN [UIScreen mainScreen].bounds.size

@interface AUIVideoFunctionPlayCell ()<AVPDelegate>

@property (nonatomic, strong) UIView *playerView;
@property (nonatomic, assign) BOOL allowPreloadNextPlay;

@end

@implementation AUIVideoFunctionPlayCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.playerView.backgroundColor = [UIColor blackColor];
        [self addSubview:self.playerView];
        self.player.playerView = self.playerView;
    }
    return self;
}

- (void)setSource:(NSString *)url {
    AVPUrlSource *urlSource = [[AVPUrlSource alloc] urlWithString:url];
    [self.player setUrlSource:urlSource];
}

#pragma mark -- AVPDelegate
- (void)onPlayerStatusChanged:(AliPlayer *)player oldStatus:(AVPStatus)oldStatus newStatus:(AVPStatus)newStatus {
    self.playStatus = newStatus;
    if (newStatus == AVPStatusPrepared) {
        self.allowPreloadNextPlay = YES;
    }
}

- (void)onBufferedPositionUpdate:(AliPlayer *)player position:(int64_t)position {
    if (self.allowPreloadNextPlay && position >= 5 * 1000) {
        if ([self.delegate respondsToSelector:@selector(startPreloadNextPlayAtPlayer:)]) {
            [self.delegate startPreloadNextPlayAtPlayer:player];
        }
        self.allowPreloadNextPlay = NO;
    }
}

// 视频当前播放位置回调
- (void)onCurrentPositionUpdate:(AliPlayer *)player position:(int64_t)position {
    if ([self.delegate respondsToSelector:@selector(updateCurrentPosition:atPlayer:)]) {
        [self.delegate updateCurrentPosition:position atPlayer:player];
    }
}


#pragma mark -- lazy load
- (UIView *)playerView {
    if (!_playerView) {
        _playerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN.width, SCREEN.height)];
    }
    return _playerView;
}

- (AliPlayer *)player {
    if (!_player) {
        _player = [[AliPlayer alloc] init];
        _player.loop = YES;
        _player.autoPlay = YES;
        _player.delegate = self;
        
        AVPConfig *config = [_player getConfig];
        config.clearShowWhenStop = YES;
        [_player setConfig:config];
    }
    return _player;
}

@end
