//
//  AUIVideoListPlayerViewController.m
//  AliPlayerDemo
//
//  Created by zzy on 2022/3/22.
//  Copyright © 2022 com.alibaba. All rights reserved.
//

#import "AUIVideoListPlayerViewController.h"
#import <AliyunPlayer/AliyunPlayer.h>
#import "AVTheme.h"
#import "AUIVideoListPlayScrollView.h"
#import "AUIVideoListManager.h"

#define PRELOAD_CACHE_DURATION (5 * 1000)

typedef NS_ENUM(NSInteger, AUIVideoListScrollType) {
    // 没有移动
    AUIVideoListScrollTypeNoMoto = 0,
    // 移动到下一个
    AUIVideoListScrollTypeMotoNext,
    // 移动到上一个
    AUIVideoListScrollTypeMotoPre,
    // 向下移动超过一个
    AUIVideoListScrollTypeMotoNextMoreOne,
    // 向上移动超过一个
    AUIVideoListScrollTypeMotoPreMoreOne,
};

#pragma mark -- AUIVideoListPlayerViewController
@interface AUIVideoListPlayerViewController ()<AUIVideoListPlayScrollViewDelegate, AVPDelegate, AliMediaLoaderStatusDelegate>

/**
 当前播放model
 */
@property (nonatomic,strong)AUIVideoListModel *currentModel;

/**
 数据源
 */
@property (nonatomic,strong)NSMutableArray<AUIVideoListModel *> *dataArray;

/**
 播放器
 */
@property (nonatomic,strong)AliPlayer *aliPlayer;

/**
 播放器1
 */
@property (nonatomic,strong)AliPlayer *aliPlayer1;

/**
 没有更多数据回调
 */
@property (nonatomic, strong) void(^isAllDataCallback)(void);

/**
 是否全部服务器数据都被加载完了
 */
@property (nonatomic,assign)BOOL isAllData;

/**
 滚动视图容器
 */
@property (nonatomic,strong)AUIVideoListPlayScrollView *scrollView;

/**
 播放器当前状态
 */
@property (nonatomic,assign)AVPStatus playerStatus;

/**
 是否正在请求，变量控制重复请求
 */
@property (nonatomic,assign)BOOL isAtRequest;

/**
 最大数据量
 */
@property (nonatomic,strong) NSMutableArray<AUIVideoListModel *> *preLoadUrlArr;

@property (nonatomic,assign)BOOL isLastScrollMovePre;
@property (nonatomic,assign)BOOL isCurrentAliPlayer1;

@property (nonatomic,assign)BOOL isFirstOpen;

@end

@implementation AUIVideoListPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.hiddenMenuButton = YES;
    
    self.isFirstOpen = YES;
    
    [[AUIVideoListManager manager] showBottomMoreTip];

    self.dataArray = [AUIVideoListManager convertSourceData].mutableCopy;
    self.currentModel = self.dataArray.firstObject;
    
    self.scrollView = [[AUIVideoListPlayScrollView alloc]initWithFrame:self.view.bounds dataArray:self.dataArray];
    self.scrollView.accessibilityIdentifier = AUIVideoListAccessibilityStr(@"scrollView");
    self.scrollView.delegate = self;
    self.scrollView.currentIndex = self.currentModel.index;
    [self.view addSubview:self.scrollView];
    
    [self.view bringSubviewToFront:self.headerView];
    
    [self initPlayer];
    self.aliPlayer.playerView = self.scrollView.playView;
    
    [self initPreload];
    
    [self playCurrentModel:AUIVideoListScrollTypeNoMoto];
   
    // 添加检测app进入后台的观察者
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationEnterBackground) name: UIApplicationWillResignActiveNotification object:nil];
    // app从后台进入前台都会调用这个方法
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive) name: UIApplicationDidBecomeActiveNotification object:nil];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.isFirstOpen) {
        self.isFirstOpen = NO;
    } else {
        [self startPlay];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self pausePlay];
}

- (void)initPlayer {
    self.aliPlayer = [[AliPlayer alloc]init];
    self.aliPlayer.enableHardwareDecoder = YES;
    self.aliPlayer.loop = YES;
    self.aliPlayer.scalingMode = AVP_SCALINGMODE_SCALEASPECTFIT;
    [self.aliPlayer setFastStart:YES];
    self.aliPlayer.delegate = self;
}

- (void)initPlayer1 {
    self.aliPlayer1 = [[AliPlayer alloc]init];
    self.aliPlayer1.enableHardwareDecoder = YES;
    self.aliPlayer1.loop = YES;
    self.aliPlayer1.scalingMode = AVP_SCALINGMODE_SCALEASPECTFIT;
    [self.aliPlayer1 setFastStart:YES];
    self.aliPlayer1.delegate = self;
}

- (void)distroyPlayer{
    if (self.aliPlayer) {
        [self.aliPlayer stop];
        [self.aliPlayer destroy];
        self.aliPlayer.playerView = nil;
        self.aliPlayer = nil;
    }
}

- (void)distroyPlayer1 {
    if (self.aliPlayer1) {
        [self.aliPlayer1 stop];
        [self.aliPlayer1 destroy];
        self.aliPlayer1.playerView = nil;
        self.aliPlayer1 = nil;
    }
}

- (void)pausePlay {
    if (self.isCurrentAliPlayer1) {
        [self.aliPlayer1 pause];
    } else {
        [self.aliPlayer pause];
    }
}

- (void)startPlay {
    if (self.isCurrentAliPlayer1) {
        [self.aliPlayer1 start];
    } else {
        [self.aliPlayer start];
    }
}

- (void)initPreload {
    [[AliMediaLoader shareInstance] setAliMediaLoaderStatusDelegate:self];
}

- (void)startPreLoad {
    __weak typeof(self) weakSelf = self;
    // 异步加载
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(self) strongSelf = weakSelf;
        
        if (strongSelf.currentModel.index == 0 ||
            strongSelf.currentModel.index % 5 == 4) {
            if (strongSelf.preLoadUrlArr.count > 0) {
                [strongSelf.preLoadUrlArr removeAllObjects];
            }
            
            long originIndex = strongSelf.currentModel.index + (strongSelf.currentModel.index == 0 ? 0 : 1);
            for (long i = originIndex; i < strongSelf.currentModel.index + 5; i++) {
                if (i < strongSelf.dataArray.count) {
                    AUIVideoListModel *model = [strongSelf.dataArray objectAtIndex:i];
                    [strongSelf.preLoadUrlArr addObject:model];
                    
                    // 预加载当前页后5个流
                    [[AliMediaLoader shareInstance] load:model.url duration:PRELOAD_CACHE_DURATION];
                }
            }
        }
        
    });
}

-(AUIVideoListModel*)findPreloadObj:(AUIVideoListModel*)model{
    for (AUIVideoListModel *obj in _preLoadUrlArr) {
        if (obj.url == model.url) {
            return obj;
        }
    }
    return nil;
}

- (void)playCurrentModel:(AUIVideoListScrollType)scrollType {
    [self startPreLoad];

    if (scrollType == AUIVideoListScrollTypeNoMoto) { // 第一个index时
        [self playAliPlayerWithScrollType:scrollType distroyLastPlayer:NO];
        [self prepareAliPlayerWithScrollType:AUIVideoListScrollTypeMotoNext];
    } else if (scrollType == AUIVideoListScrollTypeMotoNext ||
               scrollType == AUIVideoListScrollTypeMotoPre ||
               scrollType == AUIVideoListScrollTypeMotoNextMoreOne ||
               scrollType == AUIVideoListScrollTypeMotoPreMoreOne) {
        [self playAliPlayerWithScrollType:scrollType distroyLastPlayer:YES];
        [self prepareAliPlayerWithScrollType:scrollType];
    } else {
        [self playAliPlayerWithScrollType:scrollType distroyLastPlayer:NO];
    }
}

- (void)playAliPlayerWithScrollType:(AUIVideoListScrollType)scrollType distroyLastPlayer:(BOOL)distroyLastPlayer {
    if (self.isCurrentAliPlayer1) {
        if (distroyLastPlayer) {
            [self distroyPlayer];
        }
        if (scrollType == AUIVideoListScrollTypeNoMoto ||
            scrollType == AUIVideoListScrollTypeMotoNextMoreOne ||
            scrollType == AUIVideoListScrollTypeMotoPreMoreOne ||
            (scrollType == AUIVideoListScrollTypeMotoNext && self.isLastScrollMovePre) ||
                (scrollType == AUIVideoListScrollTypeMotoPre && !(self.isLastScrollMovePre))) {
            [self.aliPlayer1 stop];
            self.aliPlayer1.playerView = self.scrollView.playView;
            AVPUrlSource *source = [[AVPUrlSource alloc] urlWithString:self.currentModel.url];
            [self.aliPlayer1 setUrlSource:source];
            [self.aliPlayer1 prepare];
        } else {
            self.aliPlayer1.playerView = self.scrollView.playView;
            [self.aliPlayer1 start];
        }
        
    } else {
        if (distroyLastPlayer) {
            [self distroyPlayer1];
        }
        if (scrollType == AUIVideoListScrollTypeNoMoto ||
            scrollType == AUIVideoListScrollTypeMotoNextMoreOne ||
            scrollType == AUIVideoListScrollTypeMotoPreMoreOne ||
            (scrollType == AUIVideoListScrollTypeMotoNext && self.isLastScrollMovePre) ||
                (scrollType == AUIVideoListScrollTypeMotoPre && !(self.isLastScrollMovePre))) {
            [self.aliPlayer stop];
            self.aliPlayer.playerView = self.scrollView.playView;
            AVPUrlSource *source = [[AVPUrlSource alloc] urlWithString:self.currentModel.url];
            [self.aliPlayer setUrlSource:source];
            [self.aliPlayer prepare];
        } else {
            self.aliPlayer.playerView = self.scrollView.playView;
            [self.aliPlayer start];
        }
    }
}

- (void)prepareAliPlayerWithScrollType:(AUIVideoListScrollType)scrollType {
    if (self.isCurrentAliPlayer1) {
        [self initPlayer];
        NSString *url = (scrollType == AUIVideoListScrollTypeMotoNext ? [self getNextModel].url : [self getPreModel].url);
        AVPUrlSource *source = [[AVPUrlSource alloc] urlWithString:url];
        [self.aliPlayer setUrlSource:source];
        [self.aliPlayer prepare];
    } else {
        [self initPlayer1];
        NSString *url = (scrollType == AUIVideoListScrollTypeMotoNext ? [self getNextModel].url : [self getPreModel].url);
        AVPUrlSource *source = [[AVPUrlSource alloc] urlWithString:url];
        [self.aliPlayer1 setUrlSource:source];
        [self.aliPlayer1 prepare];
    }
}

- (AUIVideoListModel *)getNextModel {
    if (self.currentModel.index < self.dataArray.count - 1) {
        return self.dataArray[self.currentModel.index+1];
    } else {
        return self.dataArray.firstObject;
    }
}

- (AUIVideoListModel *)getPreModel {
    if (self.currentModel.index == 0) {
        return self.dataArray.lastObject;
    } else {
        return self.dataArray[self.currentModel.index-1];
    }
}

- (void)applicationEnterBackground {
    [self pausePlay];
}

- (void)applicationDidBecomeActive {
    [self startPlay];
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

#pragma mark AUIVideoListPlayScrollViewDelegate
/**
 全屏点击事件
 
 @param playScrollView playScrollView
 */
- (void)AUIVideoListPlayScrollViewTapGestureAction:(AUIVideoListPlayScrollView *)playScrollView {
    if (self.playerStatus == AVPStatusStarted) {
        if (self.isCurrentAliPlayer1) {
            [self.aliPlayer1 pause];
        } else {
            [self.aliPlayer pause];
        }
        self.scrollView.showPlayImage = YES;
    }else if (self.playerStatus == AVPStatusPaused) {
        if (self.isCurrentAliPlayer1) {
            [self.aliPlayer1 start];
        } else {
            [self.aliPlayer start];
        }
        self.scrollView.showPlayImage = NO;
    }
}

/**
 滚动事件,移动位置超过一个
 
 @param scrollView scrollView
 @param index 移动到第几个
 @param motoNext 是否是向下移动
 */
- (void)AUIVideoListPlayScrollView:(AUIVideoListPlayScrollView *)scrollView scrollViewDidEndDeceleratingAtIndex:(NSInteger)index motoNext:(BOOL)motoNext {
    AUIVideoListModel *model = [self findModelFromIndex:index];
    if (self.playerStatus == AVPStatusPaused && index == self.currentModel.index) {
        [self.scrollView showPlayView];
        if (self.isCurrentAliPlayer1) {
            [self.aliPlayer1 start];
        } else {
            [self.aliPlayer start];
        }
    }else {
        self.currentModel = model;
        //self.isCurrentAliPlayer1 = !_isCurrentAliPlayer1;
        if (motoNext) {
            [self playCurrentModel:AUIVideoListScrollTypeMotoNextMoreOne];
        } else {
            [self playCurrentModel:AUIVideoListScrollTypeMotoPreMoreOne];
        }
    }
    NSLog(@"播放第%ld个",(long)index);
}

/**
 移动到下一个
 
 @param scrollView scrollView
 @param index 第几个
 */
- (void)AUIVideoListPlayScrollView:(AUIVideoListPlayScrollView *)scrollView motoNextAtIndex:(NSInteger)index {
    AUIVideoListModel *model = [self findModelFromIndex:index];
    if (model && self.currentModel != model) {
        self.currentModel = model;
        if (!self.isLastScrollMovePre) {
            self.isCurrentAliPlayer1 = !_isCurrentAliPlayer1;
        }
        [self playCurrentModel:AUIVideoListScrollTypeMotoNext];
        self.isLastScrollMovePre = NO;
        NSLog(@"播放第%ld个",(long)index);
    }
}

/**
 移动到上一个
 
 @param scrollView scrollView
 @param index 第几个
 */
- (void)AUIVideoListPlayScrollView:(AUIVideoListPlayScrollView *)scrollView motoPreAtIndex:(NSInteger)index {
    AUIVideoListModel *model = [self findModelFromIndex:index];
    if (model && self.currentModel != model) {
        self.currentModel = model;
        if (self.isLastScrollMovePre) {
            self.isCurrentAliPlayer1 = !_isCurrentAliPlayer1;
        }
        [self playCurrentModel:AUIVideoListScrollTypeMotoPre];
        self.isLastScrollMovePre = YES;
        NSLog(@"播放第%ld个",(long)index);
    }
}

- (AUIVideoListModel *)findModelFromIndex:(NSInteger)index {
    for (AUIVideoListModel *model in self.dataArray) {
        if (model.index == index) {
            return model;
        }
    }
    return nil;
}

/**
 当前播放视图移除屏幕
 
 @param scrollView scrollView
 */
- (void)AUIVideoListPlayScrollViewScrollOut:(AUIVideoListPlayScrollView *)scrollView {
    if (self.isCurrentAliPlayer1) {
        [self.aliPlayer1 stop];
    } else {
        [self.aliPlayer stop];
    }
}

#pragma mark AVPDelegate

/**
 @brief 错误代理回调
 @param player 播放器player指针
 @param errorModel 播放器错误描述，参考AliVcPlayerErrorModel
 */
- (void)onError:(AliPlayer*)player errorModel:(AVPErrorModel *)errorModel {
    NSLog(@"error:%@", errorModel.message);
}

/**
 @brief 播放器事件回调
 @param player 播放器player指针
 @param eventType 播放器事件类型，@see AVPEventType
 */
-(void)onPlayerEvent:(AliPlayer*)player eventType:(AVPEventType)eventType {
    switch (eventType) {
        case AVPEventPrepareDone: {
            if (self.isCurrentAliPlayer1) {
                [self.aliPlayer1 start];
            } else {
                [self.aliPlayer start];
            }
        }
            break;
        case AVPEventFirstRenderedStart: {
            [self.scrollView showPlayView];
        }
            break;
        default:
            break;
    }
}

/**
 @brief 播放器状态改变回调
 @param player 播放器player指针
 @param oldStatus 老的播放器状态 参考AVPStatus
 @param newStatus 新的播放器状态 参考AVPStatus
 */
- (void)onPlayerStatusChanged:(AliPlayer*)player oldStatus:(AVPStatus)oldStatus newStatus:(AVPStatus)newStatus {
    if (self.isCurrentAliPlayer1) {
        if (player == self.aliPlayer1) {
            self.playerStatus = newStatus;
        }
    } else {
        if (player == self.aliPlayer) {
            self.playerStatus = newStatus;
        }
    }
    switch (newStatus) {
        case AVPStatusStarted: {
        }
            break;
        case AVPStatusPaused: {
        }
            break;
        default:
            break;
    }
}

/**
 @brief 视频当前播放位置回调
 @param player 播放器player指针
 @param position 视频当前播放位置
 */
- (void)onCurrentPositionUpdate:(AliPlayer*)player position:(int64_t)position {
    [self.scrollView updateProgress:position duration:player.duration];
}

#pragma --AliMediaLoaderStatusDelegate
/**
 @brief 错误回调
 @param url 加载url
 @param code 错误码
 @param msg 错误描述
 */
- (void)onError:(NSString *)url code:(int64_t)code msg:(NSString *)msg{
    NSLog(@"preload==>onError--url:%@,code:%lli,msg:%@",url,code,msg);
}

/**
 @brief 完成回调
 @param url 加载url
 */
- (void)onCompleted:(NSString *)url {
    NSLog(@"preload==>onCompleted--url:%@",url);
}

/**
 @brief 取消回调
 @param url 加载url
 */
- (void)onCanceled:(NSString *)url{
    NSLog(@"preload==>onCanceled--url:%@",url);
}

- (void)didMoveToParentViewController:(UIViewController *)parent {
    [super didMoveToParentViewController:parent];
    if (!parent) {
        [[AliMediaLoader shareInstance] cancel:nil];
        [self distroyPlayer];
        [self distroyPlayer1];
    }
}

@end
