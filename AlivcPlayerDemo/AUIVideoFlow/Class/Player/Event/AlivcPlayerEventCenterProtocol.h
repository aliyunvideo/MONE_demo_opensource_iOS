//
//  AlivcPlayerEventCenterProtocol.h
//  ApsaraVideo
//
//  Created by mengyehao on 2021/7/8.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSUInteger, AlivcPlayerEventCenterTypeOrientation) {
    AlivcPlayerEventCenterTypeOrientationPortrait,
    AlivcPlayerEventCenterTypeOrientationLandsacpeLeft,
    AlivcPlayerEventCenterTypeOrientationLandsacpeRight,
};

typedef NS_ENUM(NSUInteger, AlivcPlayerPageEventFrom) {
    AlivcPlayerPageEventFromHomePage,
    AlivcPlayerPageEventFromFlowPage,
    AlivcPlayerPageEventFromDetailPage,
    AlivcPlayerPageEventFromFullScreenPlayPage,
};

typedef NS_ENUM(NSUInteger, AlivcPlayerPageEventJump) {
    AlivcPlayerPageEventJumpNone,
    AlivcPlayerPageEventJumpFlowToDetailPage,
    AlivcPlayerPageEventJumpFullScreenToDetailPage,
};

typedef NS_ENUM(NSInteger, ApScreenMirrorType)
{
    ApScreenMirrorTypeNone,
    ApScreenMirrorTypeAirplay,
    ApScreenMirrorTypeDLNA,
};

typedef NS_ENUM(NSInteger, ApPlayerScene)
{
    ApPlayerSceneInFeed,
    ApPlayerSceneInDetail,
    ApPlayerSceneInFullScreen,
};

typedef NS_ENUM(NSInteger, ApBarragePositionType)
{
    ApBarragePositionTypeTop,
    ApBarragePositionTypeBottom,
    ApBarragePositionTypeALL,
};

typedef NS_ENUM(NSUInteger, AlivcPlayerEventCenterType) {
    
    AlivcPlayerEventCenterTypePlayerEventType, //播放器事件
    AlivcPlayerEventCenterTypePlayerEventTypeWithString, //播放器事件描述
    AlivcPlayerEventCenterTypePlayerEventAVPStatus, //播放器状态
    AlivcPlayerEventCenterTypePlayerPlayProgress, //播放器进度
    AlivcPlayerEventCenterTypePlayerBufferedProgress, //播放器缓冲
    AlivcPlayerEventCenterTypePlayerOnAVPError, //播放器错误
    
    
    AlivcPlayerEventCenterTypeOrientationChanged, //播放器方向改变
    AlivcPlayerEventCenterTypeLockChanged, //锁状态改变
    AlivcPlayerEventCenterTypeControlToolHiddenChanged, //上下操作栏状态
    
    AlivcPlayerEventCenterTypePlayerDisableVideoChanged, //视频流是否开启
    
    AlivcPlayerEventCenterTypePlayerBackModeEnabledChanged, //后台播放是否开启
    
    AlivcPlayerEventCenterTypeSliderChangedAction, //滑动进度条
    
    AlivcPlayerEventCenterTypeSliderDragAction, //按住滑动进度条
    
    AlivcPlayerEventCenterTypeSliderTouchEndAction, //离开滑动进度条
    
    AlivcPlayerEventCenterTypeInputAction, //点击输入
    
    AlivcPlayerEventCenterTypeBarrageSend, //发送弹幕
    
    AlivcPlayerEventCenterPlaySceneChanged, //播放场景改变

    
    AlivcPlayerEventCenterTypePlayListSourceDidChanged, //
    
    AlivcPlayerEventCenterTypeSpeedTipShowAction,
    
    AlivcPlayerEventCenterTypeFullScreenPlayToDetailPage,
};

@protocol AlivcPlayerPluginEventProtocol;

@protocol AlivcPlayerEventCenterProtocol <NSObject>

- (void)addEventObserver:(id<AlivcPlayerPluginEventProtocol>)observer;

- (void)removeEventObserver:(id<AlivcPlayerPluginEventProtocol>)observer;

- (void)dispatchEvent:(AlivcPlayerEventCenterType)eventType userInfo:(NSDictionary *)userInfo;

@end


