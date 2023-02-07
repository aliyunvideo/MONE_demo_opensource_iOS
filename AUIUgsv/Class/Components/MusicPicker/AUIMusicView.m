//
//  AUIMusicView.m
//  AlivcUgsvDemo
//
//  Created by coder.pi on 2022/6/8.
//

#import "AUIMusicView.h"
#import "AUIMusicCell.h"
#import "Masonry.h"
#import "UIView+AVHelper.h"
#import "AUIMusicStateModel.h"
#import "AUIResourceManager.h"
#import "AUIAssetPlay.h"

static NSString *kMusicCellIdentifier = @"MusicCellIdentifier";

@interface AUIMusicView()<UITableViewDelegate, UITableViewDataSource, AUIMusicCellDelegate>
{
    NSInteger _currentSelectedIndex;
}
@property (nonatomic, strong) NSArray<AUIMusicStateModel *> *dataList;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) AUIAssetPlay *selfPlayer;
@property (nonatomic, assign) BOOL showCropView;
@end

@implementation AUIMusicView

@synthesize player = _player;

- (instancetype)initWithLimitDuration:(NSTimeInterval)limitDuration {
    return [self initWithLimitDuration:limitDuration withShowCropView:YES];
}

- (instancetype)initWithLimitDuration:(NSTimeInterval)limitDuration withShowCropView:(BOOL)showCropView {
    self = [super init];
    if (self) {
        [self setup];
        _limitDuration = limitDuration;
        _showCropView = showCropView;
    }
    return self;
}

- (void) fetchData {
    __weak typeof(self) weakSelf = self;
    [AUIResourceManager.manager fetchMusicDataWithCallback:^(NSError *error, NSArray *data) {
        [weakSelf refreshData:data];
    }];
}

- (void) setup {
    // clear
    [_tableView removeFromSuperview];
    
    // create
    _dataList = @[].mutableCopy;
    _tableView = [UITableView new];
    _tableView.backgroundColor = UIColor.clearColor;
    _tableView.backgroundView = nil;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView registerClass:AUIMusicCell.class forCellReuseIdentifier:kMusicCellIdentifier];
    [self addSubview:_tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self);
        make.bottom.equalTo(self).inset(AVSafeBottom);
    }];
    
    [self fetchData];
}

- (NSInteger) findIndexWithMusicId:(NSString *)musicId {
    if (musicId.length == 0) {
        return -1;
    }
    
    for (NSInteger i = 0; i < _dataList.count; ++i) {
        if ([_dataList[i].music.musicId isEqualToString:musicId]) {
            return i;
        }
    }
    
    return -1;
}


- (void) setCurrentSelected:(AUIMusicSelectedModel *)currentSelected {
    NSInteger idx = [self findIndexWithMusicId:currentSelected.music.musicId];
    [self setCurrentSelectedIndex:idx beginTime:currentSelected.beginTime endTime:currentSelected.endTime];
}

- (void)setSelfPlayer:(AUIAssetPlay *)selfPlayer {
    if (_selfPlayer == selfPlayer) {
        return;
    }
    [_selfPlayer stop];
    _selfPlayer = selfPlayer;
}

- (void)setPlayer:(id<AUIVideoPlayProtocol>)player {
    _player = player;
    self.selfPlayer = nil;
}

- (id<AUIVideoPlayProtocol>) player {
    if (_player) {
        return _player;
    }
    
    if (!_isShowing) {
        return nil;
    }
    
    if (self.selfPlayer) {
        return self.selfPlayer;
    }
    NSString *path = self.currentSelected.localPath;
    if (path.length == 0 || ![NSFileManager.defaultManager fileExistsAtPath:path]) {
        return nil;
    }

    AVAsset *asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:path]];
    self.selfPlayer = [[AUIAssetPlay alloc] initWithAsset:asset];
    self.selfPlayer.isLoopPlay = YES;
    return self.selfPlayer;
}

- (void) setIsShowing:(BOOL)isShowing {
    if (_isShowing == isShowing) {
        return;
    }
    _isShowing = isShowing;
    if (_isShowing) {
        [self updateTableSelection];
    }
    else {
        self.player = nil;
    }
}

- (void)updateTableSelection {
    [_tableView reloadData];
    if (_currentSelected) {
        [_tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:_currentSelectedIndex inSection:0]
                                animated:YES
                          scrollPosition:UITableViewScrollPositionTop];
    } else {
        NSIndexPath *idxPath = _tableView.indexPathForSelectedRow;
        if (idxPath) {
            [_tableView deselectRowAtIndexPath:idxPath animated:YES];
        }
    }
}

- (void)setCurrentSelectedIndex:(NSInteger)currentSelectedIndex
                      beginTime:(NSTimeInterval)beginTime
                        endTime:(NSTimeInterval)endTime {
    _currentSelectedIndex = currentSelectedIndex;
    if (0 <= currentSelectedIndex && currentSelectedIndex < _dataList.count) {
        AUIMusicStateModel *model = _dataList[currentSelectedIndex];
        _currentSelected = [AUIMusicSelectedModel new];
        _currentSelected.music = model.music;
        _currentSelected.localPath = model.musicLocalPath;
        _currentSelected.beginTime = beginTime;
        _currentSelected.endTime = endTime;
    } else {
        _currentSelected = nil;
    }
    self.selfPlayer = nil;
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (!weakSelf.showCropView && weakSelf.currentSelected) {
            [weakSelf.player enablePlayInRange:weakSelf.currentSelected.beginTime
                                 rangeDuration:weakSelf.currentSelected.duration];
            [weakSelf.player seek:weakSelf.currentSelected.beginTime];
            [weakSelf.player play];
        }
        else {
            [weakSelf updateTableSelection];
        }
    });
}

- (void)selectWithIdx:(NSInteger)selectedIdx {
    if (_currentSelectedIndex == selectedIdx) {
        return;
    }
    [self setCurrentSelectedIndex:selectedIdx beginTime:0 endTime:_limitDuration];
    if (_onSelectedChanged) {
        _onSelectedChanged(self.currentSelected);
    }
}

- (void) refreshData:(NSArray<AUIMusicModel *> *)dataList {
    if (!dataList) {
        return;
    }
    NSMutableArray *result = @[].mutableCopy;
    for (AUIMusicModel *music in dataList) {
        [result addObject:[[AUIMusicStateModel alloc] initWithMusic:music]];
    }
    _dataList = result;
    AUIMusicSelectedModel *selected = self.currentSelected;
    _currentSelectedIndex = -1;
    [_tableView reloadData];
    self.currentSelected = selected;
}

// MARK: - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AUIMusicCell *musicCell = [tableView dequeueReusableCellWithIdentifier:kMusicCellIdentifier];
    musicCell.delegate = self;
    musicCell.limitDuration = _limitDuration;
    musicCell.model = self.dataList[indexPath.row];
    if (indexPath.row == _currentSelectedIndex) {
        musicCell.player = self.player;
        musicCell.selectedModel = self.currentSelected;
        musicCell.isShowCropView = self.showCropView;
    } else {
        musicCell.player = nil;
        musicCell.selectedModel = nil;
        musicCell.isShowCropView = NO;
    }
    return musicCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == _currentSelectedIndex && self.showCropView) {
        return 140.0;
    }
    return 70.0;
}

// MARK: - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    AUIMusicStateModel *model = self.dataList[indexPath.row];
    if (model.state == AUIMusicResourceStateNetwork) {
        [model download];
        return;
    }
    if (model.state == AUIMusicResourceStateLocal) {
        [self selectWithIdx:indexPath.row];
    }
}

// MARK: - AUIMusicCellDelegate
- (void) onAUIMusicCell:(AUIMusicCell *)cell stateDidChange:(AUIMusicResourceState)state {
    if (cell.selected && state == AUIMusicResourceStateLocal) {
        NSInteger index = [self findIndexWithMusicId:cell.model.music.musicId];
        [self selectWithIdx:index];
    }
}

- (void) onAUIMusicCell:(AUIMusicCell *)cell didCropMusic:(AUIMusicSelectedModel *)selectedModel {
    if (_onSelectedChanged) {
        _onSelectedChanged(selectedModel);
    }
}

@end
