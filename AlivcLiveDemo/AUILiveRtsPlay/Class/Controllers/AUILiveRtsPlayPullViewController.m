//
//  AUILiveRtsPlayPullViewController.m
//  AliLiveSdk-Demo
//
//  Created by BOTAO on 2020/12/17.
//  Copyright © 2020 alilive. All rights reserved.
//

#import "AUILiveRtsPlayPullViewController.h"
#import "AUILiveRtsPlayStatusTipView.h"
#import "AUILiveRtsPlayTraceIDAlert.h"

@interface AUILiveRtsPlayPullViewController ()<AVPDelegate>

@property (nonatomic, strong) AliPlayer *player;
@property (nonatomic, strong) UIView *renderView;
@property (nonatomic, strong) AUILiveRtsPlayStatusTipView *playStatusTipView;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UIButton *stopButton;
@property (nonatomic, strong) UIButton *traceIdButton;
@property (nonatomic, strong) UIScrollView *bottomTipView;

@property (nonatomic, assign) BOOL retryStartPlay;
@property (nonatomic, strong) NSString *traceId;

@end

@implementation AUILiveRtsPlayPullViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleView.text = AUILiveRtsPlayString(@"超低延时直播");
    self.hiddenMenuButton = YES;
    [self setupUI];
    [self setupPlayConfig];
    self.retryStartPlay = YES;
    self.traceId = @"";
    [self onStartPlay];
    [self updatePlayButtonStatus:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self onDestroy];
}

- (void)setupUI {
    [self.contentView addSubview:self.renderView];
    
    [self.contentView bringSubviewToFront:self.playStatusTipView];
    [self.contentView addSubview:self.playStatusTipView];
    
    [self.contentView addSubview:self.playButton];
    [self.contentView addSubview:self.stopButton];
    [self.contentView addSubview:self.traceIdButton];
    [self.contentView addSubview:self.bottomTipView];
    [self setupBottomTipContent];
    self.playStatusTipView.hidden = YES;
}

- (void)setupBottomTipContent {
    UILabel *theme = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, self.bottomTipView.av_width - 20 * 2, 41)];
    theme.text = AUILiveRtsPlayString(@"常见问题");
    theme.font = AVGetMediumFont(14);
    theme.textColor = AUIFoundationColor(@"text_strong");
    [self.bottomTipView addSubview:theme];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(10, theme.av_bottom, self.bottomTipView.av_width - 10 * 2, 1)];
    line.backgroundColor = AUIFoundationColor(@"border_weak");
    [self.bottomTipView addSubview:line];

    UIView *item1TipTheme = [self createBottomTipItemTheme:AUILiveRtsPlayString(@"播放失败") originY:line.av_bottom + 12];
    
    UILabel *item1TipContent = [self createBottomTipItemContent:AUILiveRtsPlayString(@"请前往 视频直播控制台 > 工具箱 > 自助问题排查，输入URL自助定位播放失败问题") textColor:AUIFoundationColor(@"text_weak") originY:item1TipTheme.av_bottom + 8];
    
    UIView *item2TipTheme = [self createBottomTipItemTheme:AUILiveRtsPlayString(@"播放卡顿/延时高") originY:item1TipContent.av_bottom + 24];
    
    UILabel *item2Tip_step1 = [self createBottomTipItemContent:@"step1" textColor:AUIFoundationColor(@"text_medium") originY:item2TipTheme.av_bottom + 8];
    
    UILabel *item2Tip_step1_content = [self createBottomTipItemContent:AUILiveRtsPlayString(@"请前往视频直播控制台 > 流管理 > 流检测，分析您当前的推流网络环境是否良好(帧率或时间戳是否正常)") textColor:AUIFoundationColor(@"text_weak") originY:item2Tip_step1.av_bottom + 4];
    
    UILabel *item2Tip_step2 = [self createBottomTipItemContent:@"step2" textColor:AUIFoundationColor(@"text_medium") originY:item2Tip_step1_content.av_bottom + 8];
    
    UILabel *item2Tip_step1_content2 = [self createBottomTipItemContent:AUILiveRtsPlayString(@"若您的推流网络良好，请点击【TraceID获取】获取相关信息，并提交工单寻求帮助") textColor:AUIFoundationColor(@"text_weak") originY:item2Tip_step2.av_bottom + 4];
    
    if (item2Tip_step1_content2.av_bottom > self.bottomTipView.av_height) {
        self.bottomTipView.contentSize = CGSizeMake(self.bottomTipView.av_width, item2Tip_step1_content2.av_bottom + 40);
    }
}

- (UIView *)createBottomTipItemTheme:(NSString *)name originY:(CGFloat)originY {
    UIView *themeView = [[UIView alloc] initWithFrame:CGRectMake(0, originY, self.bottomTipView.av_width, 14)];
    [self.bottomTipView addSubview:themeView];
    
    UIView *separatedLine = [[UIView alloc] initWithFrame:CGRectMake(20, 0, 1, themeView.av_height)];
    separatedLine.backgroundColor = AUIFoundationColor(@"colourful_fill_strong");
    [themeView addSubview:separatedLine];
    
    UILabel *themNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(separatedLine.av_right + 8, 0, themeView.av_width - (separatedLine.av_right + 8), themeView.av_height)];
    themNameLabel.text = name;
    themNameLabel.textColor = AUIFoundationColor(@"text_strong");
    themNameLabel.font = AVGetMediumFont(12);
    [themeView addSubview:themNameLabel];
    
    return themeView;
}

- (UILabel *)createBottomTipItemContent:(NSString *)content textColor:(UIColor *)textColor originY:(CGFloat)originY {
    UILabel *contentLabel = [[UILabel alloc] init];
    contentLabel.text = content;
    contentLabel.textColor = textColor;
    contentLabel.font = AVGetRegularFont(12);
    contentLabel.numberOfLines = 0;
    
    CGFloat contentHeight = [contentLabel sizeThatFits:CGSizeMake(self.bottomTipView.av_width - 20 * 2, MAXFLOAT)].height;
    contentLabel.frame = CGRectMake(20, originY, self.bottomTipView.av_width - 20 * 2, contentHeight);
    
    [self.bottomTipView addSubview:contentLabel];
    return contentLabel;
}

- (void)updatePlayButtonStatus:(BOOL)started {
    UIColor *selectedBorderColor = AUILiveRtsPlayColor(@"rp_startbtn_select");
    UIColor *unselectBorderColor = AUIFoundationColor(@"border_strong");
    UIColor *selectedTextColor = AUILiveRtsPlayColor(@"rp_startbtn_select");
    UIColor *unselectTextColor = AUIFoundationColor(@"text_strong");
    if (started) {
        self.playButton.layer.borderColor = selectedBorderColor.CGColor;
        [self.playButton setTitleColor:selectedTextColor forState:UIControlStateNormal];
        self.stopButton.layer.borderColor = unselectBorderColor.CGColor;
        [self.stopButton setTitleColor:unselectTextColor forState:UIControlStateNormal];
    } else {
        self.playButton.layer.borderColor = unselectBorderColor.CGColor;
        [self.playButton setTitleColor:unselectTextColor forState:UIControlStateNormal];
        self.stopButton.layer.borderColor = selectedBorderColor.CGColor;
        [self.stopButton setTitleColor:selectedTextColor forState:UIControlStateNormal];
    }
}

- (void)setupPlayConfig {
    AVPConfig *config = [self.player getConfig];
    if ([self.playUrl hasPrefix:@"artc://"]) {
        //设置最大延迟为1000，延迟控制交由RTS控制
        config.maxDelayTime = 1000;
        //设置播放器启播缓存为10ms，数据控制由RTS控制。
        config.highBufferDuration = 10;
        config.startBufferDuration = 10;
        
        [self setLog:YES];
    } else {
        config.maxDelayTime = 10000;
        config.highBufferDuration = 100;
        config.startBufferDuration = 100;
        
        [self setLog:NO];
    }
    [self.player setConfig:config];
    
    AVPUrlSource *source = [[AVPUrlSource alloc] urlWithString:self.playUrl];
    [self.player setUrlSource:source];
}

- (void)setLog:(BOOL)enable {
    // 开启播放器日志
    if (enable) {
        [AliPlayer setEnableLog:YES];
        [AliPlayer setLogCallbackInfo:LOG_LEVEL_DEBUG callbackBlock:nil];
    } else {
        [AliPlayer setEnableLog:NO];
        [AliPlayer setLogCallbackInfo:LOG_LEVEL_NONE callbackBlock:nil];
    }
}

- (void)onStartPlay {
    [self.player prepare];
}

- (void)onStopPlay {
    [self.player stop];
}

- (void)onDestroy {
    if (_player) {
        [self.player stop];
        [self.player destroy];
        _player = nil;
    }
}

- (void)onGetTraceId {
    if (self.traceId && self.traceId.length > 0) {
        __weak typeof(self) weakSelf = self;
        [AUILiveRtsPlayTraceIDAlert show:self.traceId playUrl:self.playUrl view:self.view copyHandle:^{
            __strong typeof(self) strongSelf = weakSelf;
            [AVToastView show:AUILiveRtsPlayString(@"信息已复制") view:strongSelf.view position:AVToastViewPositionMid];
        }];
    } else {
        [AVAlertController show:AUILiveRtsPlayString(@"网络建联不成功，当前未获取到TraceID信息")];
    }
}

#pragma mark -- AVPDelegate
- (void)onPlayerStatusChanged:(AliPlayer *)player oldStatus:(AVPStatus)oldStatus newStatus:(AVPStatus)newStatus {
    if (newStatus == AVPStatusError) {
        [self updatePlayButtonStatus:NO];
        self.playStatusTipView.hidden = NO;
    } else if (newStatus == AVPStatusStarted) {
        [self updatePlayButtonStatus:YES];
        self.playStatusTipView.hidden = YES;
    } else if (newStatus == AVPStatusStopped) {
        [self updatePlayButtonStatus:NO];
    }
}

- (void)onPlayerEvent:(AliPlayer*)player eventWithString:(AVPEventWithString)eventWithString description:(NSString *)description {
    switch (eventWithString) {
        case EVENT_PLAYER_DIRECT_COMPONENT_MSG:
            {
                NSDictionary *descriptionDic = [[description rts_toDictionary] copy];
                NSString *contentStr = [descriptionDic objectForKey:@"content"];
                NSDictionary *kv = [contentStr rts_paramsToDictionaryWithSeparator:@"="];
                NSNumber *type = [kv objectForKey:@"code"];
                switch (type.intValue) {
                case E_DNS_FAIL:
                case E_AUTH_FAIL:
                case E_CONN_TIMEOUT:
                case E_SUB_TIMEOUT:
                case E_SUB_NO_STREAM:
                    {
                        self.playStatusTipView.hidden = NO;
                        self.playStatusTipView.errMsg = [AUILiveRtsPlayString(@"播放失败提示") stringByAppendingString:@"："];
                        if (type.intValue == E_DNS_FAIL) {
                            self.playStatusTipView.errMsg = [self.playStatusTipView.errMsg stringByAppendingFormat:@"%d,E_DNS_FAIL", type.intValue];
                        } else if (type.intValue == E_AUTH_FAIL) {
                            self.playStatusTipView.errMsg = [self.playStatusTipView.errMsg stringByAppendingFormat:@"%d,E_AUTH_FAIL", type.intValue];
                        } else if (type.intValue == E_CONN_TIMEOUT) {
                            self.playStatusTipView.errMsg = [self.playStatusTipView.errMsg stringByAppendingFormat:@"%d,E_CONN_TIMEOUT", type.intValue];
                        } else if (type.intValue == E_SUB_TIMEOUT) {
                            self.playStatusTipView.errMsg = [self.playStatusTipView.errMsg stringByAppendingFormat:@"%d,E_SUB_TIMEOUT", type.intValue];
                        } else if (type.intValue == E_SUB_NO_STREAM) {
                            self.playStatusTipView.errMsg = [self.playStatusTipView.errMsg stringByAppendingFormat:@"%d,E_SUB_NO_STREAM", type.intValue];
                        }
                        [self onStopPlay];
                        
                        self.playStatusTipView.downgradeMsg = AUILiveRtsPlayString(@"降级播放");
                        // 降级播放
                        [self convertArtcToRtmpPlay];
                        [self.playStatusTipView showErrMsg:YES downgradeMsg:YES];
                    }
                        break;
                    case E_STREAM_BROKEN:
                        {
                            self.playStatusTipView.errMsg = [self.playStatusTipView.errMsg stringByAppendingFormat:@"%d,E_STREAM_BROKEN", type.intValue];
                            
                            [self onStopPlay];
                            // 第一次收到RTS媒体超时先重试播放一次，然后如果再次收到就直接降级播放
                            if (self.retryStartPlay) {
                                [self onStartPlay];
                                self.retryStartPlay = NO;
                                [self.playStatusTipView showErrMsg:YES downgradeMsg:NO];
                            } else {
                                self.playStatusTipView.downgradeMsg = AUILiveRtsPlayString(@"降级播放");
                                // 降级播放
                                [self convertArtcToRtmpPlay];
                                [self.playStatusTipView showErrMsg:YES downgradeMsg:YES];
                            }
                        }
                            break;
                case E_RECV_STOP_SIGNAL:
                    {
                        self.playStatusTipView.errMsg = [AUILiveRtsPlayString(@"播放失败提示") stringByAppendingFormat:@"：%d,E_RECV_STOP_SIGNAL", type.intValue];
                        [self onStopPlay];
                        [self.playStatusTipView showErrMsg:YES downgradeMsg:NO];
                    }
                        break;
                case E_HELP_SUPPORT_ID_SUBSCRIBE: // 获取traceId
                    {
                        NSString *desc = [kv objectForKey:@"desc"];
                        if ([desc containsString:@"-sub-"]) {
                            NSString *traceId = [desc componentsSeparatedByString:@"-sub-"].lastObject;
                            self.traceId = traceId;
                        }
                    }
                    break;
                default:
                    break;
                }
            }
                break;
            default:
                break;
    }
}

// 降级播放
- (void)convertArtcToRtmpPlay {
    // 获取当前的播放url，截取url的前缀
    NSArray *urlSeparated = [self.playUrl componentsSeparatedByString:@"://"];
    NSString *urlPrefix = urlSeparated.firstObject;
    // 判断url前缀是否是artc，如果是的话就降级为传统直播
    if ([urlPrefix isEqualToString:@"artc"]) {
        self.playUrl = [@"rtmp://" stringByAppendingString:urlSeparated.lastObject];

      // 重新设置播放源，进行准备播放
      [self setupPlayConfig];
      [self onStartPlay];
    }
}

- (void)onError:(AliPlayer*)player errorModel:(AVPErrorModel *)errorModel {
    NSLog(@"播放报错:%ld,%@", errorModel.code, errorModel.message);
}

#pragma mark -- lazy load
- (AliPlayer *)player {
    if (!_player) {
        _player = [[AliPlayer alloc] init];
        _player.autoPlay = YES;
        _player.delegate = self;
        _player.playerView = self.renderView;
    }
    return _player;
}

- (UIView *)renderView {
    if (!_renderView) {
        CGFloat renderWidth = self.contentView.av_width - 21 * 2;
        CGFloat renderHeight = renderWidth * (9.0 / 16.0);
        _renderView = [[UIView alloc] initWithFrame:CGRectMake(21, 17, self.contentView.av_width - 21 * 2, renderHeight)];
        _renderView.layer.borderColor = AUIFoundationColor(@"border_weak").CGColor;
        _renderView.layer.borderWidth = 1;
        _renderView.layer.cornerRadius = 4;
        _renderView.layer.masksToBounds = YES;
    }
    return _renderView;
}

- (AUILiveRtsPlayStatusTipView *)playStatusTipView {
    if (!_playStatusTipView) {
        _playStatusTipView = [[AUILiveRtsPlayStatusTipView alloc] initWithFrame:self.renderView.frame];
        _playStatusTipView.backgroundColor = AUILiveRtsPlayColor(@"rp_toast_bg");
    }
    return _playStatusTipView;
}

- (UIButton *)playButton {
    if (!_playButton) {
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _playButton.frame = CGRectMake(21, self.renderView.av_bottom + 13, 48, 24);
        _playButton.layer.borderColor = AUIFoundationColor(@"border_strong").CGColor;
        _playButton.layer.borderWidth = 1;
        _playButton.layer.cornerRadius = 12;
        [_playButton setTitle:AUILiveRtsPlayString(@"播放") forState:UIControlStateNormal];
        [_playButton setTitleColor:AUIFoundationColor(@"text_strong") forState:UIControlStateNormal];
        _playButton.titleLabel.font = AVGetRegularFont(12);
        [_playButton addTarget:self action:@selector(onStartPlay) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playButton;
}

- (UIButton *)stopButton {
    if (!_stopButton) {
        _stopButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _stopButton.frame = CGRectMake(self.playButton.av_right + 12, self.renderView.av_bottom + 13, 48, 24);
        _stopButton.layer.borderColor = AUIFoundationColor(@"border_strong").CGColor;
        _stopButton.layer.borderWidth = 1;
        _stopButton.layer.cornerRadius = 12;
        [_stopButton setTitle:AUILiveRtsPlayString(@"停止") forState:UIControlStateNormal];
        [_stopButton setTitleColor:AUIFoundationColor(@"text_strong") forState:UIControlStateNormal];
        _stopButton.titleLabel.font = AVGetRegularFont(12);
        [_stopButton addTarget:self action:@selector(onStopPlay) forControlEvents:UIControlEventTouchUpInside];
    }
    return _stopButton;
}

- (UIButton *)traceIdButton {
    if (!_traceIdButton) {
        _traceIdButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _traceIdButton.frame = CGRectMake(self.contentView.av_width - 20 - 92, self.renderView.av_bottom + 13, 92, 24);
        _traceIdButton.backgroundColor = AUIFoundationColor(@"fill_medium");
        _traceIdButton.layer.cornerRadius = 12;
        [_traceIdButton setTitle:AUILiveRtsPlayString(@"TraceID获取") forState:UIControlStateNormal];
        [_traceIdButton setTitleColor:AUIFoundationColor(@"text_strong") forState:UIControlStateNormal];
        _traceIdButton.titleLabel.font = AVGetRegularFont(12);
        [_traceIdButton addTarget:self action:@selector(onGetTraceId) forControlEvents:UIControlEventTouchUpInside];
    }
    return _traceIdButton;
}

- (UIScrollView *)bottomTipView {
    if (!_bottomTipView) {
        _bottomTipView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.playButton.av_bottom + 20, self.contentView.av_width, self.contentView.av_height - (self.playButton.av_bottom + 20))];
        _bottomTipView.scrollEnabled = YES;
    }
    return _bottomTipView;
}

@end
