//
//  AUIShortEpisodeViewController.m
//  AlivcPlayerDemo
//
//  Created by Bingo on 2023/9/14.
//

#import "AUIShortEpisodeViewController.h"
#import "AUIShortEpisodePlayCell.h"
#import "AUIShortEpisodeListPanel.h"
#import "AUIShortEpisodePlayer.h"

@interface AUIShortEpisodeViewController ()

@property (nonatomic, strong) AUIShortEpisodePlayer *episodePlayer;
@property (nonatomic, strong) AUIShortEpisodeData *episodeData;
@property (nonatomic, assign) NSInteger playIndex;
@property (nonatomic, weak) AUIShortEpisodePlayCell *playingCell;
@property (nonatomic, assign) BOOL autoMoveNext;

@end

@implementation AUIShortEpisodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.headerView.hidden = YES;
    self.contentView.frame = self.view.bounds;
    self.collectionView.frame = self.contentView.bounds;
    
    self.collectionView.pagingEnabled = YES;
    self.collectionView.showsVerticalScrollIndicator = NO;
    [self.collectionView registerClass:AUIShortEpisodePlayCell.class forCellWithReuseIdentifier:AVCollectionViewCellIdentifier];
    
    AVProgressHUD *loading = [AVProgressHUD ShowHUDAddedTo:self.view animated:YES];
    loading.labelText = @"加载中";
    [AUIShortEpisodeDataManager fetchData:@"123" completed:^(AUIShortEpisodeData * _Nullable data, NSError * _Nullable error) {
        [loading hideAnimated:YES];
        if (error) {
            [AVToastView show:@"无法拉取播放列表，播放失败" view:self.view position:AVToastViewPositionMid];
        }
        else {
            [self startPlay:data];
        }
    }];
}

- (void)startPlay:(AUIShortEpisodeData *)data {
    _playIndex = -1;
    self.autoMoveNext = YES;
    self.episodeData = data;
    self.episodePlayer = [[AUIShortEpisodePlayer alloc] init];
    [self.episodePlayer setupPlayer:self.episodeData];
    [self.collectionView reloadData];
    if (self.episodeData.list.count > 0) {
        self.playIndex = 0;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self playCurrentCell];
        });
    }
    
    __weak typeof(self) weakSelf = self;
    self.episodePlayer.onPlayProgressBlock = ^(CGFloat progress) {
        AUIShortEpisodePlayCell *cell = [weakSelf cell:weakSelf.playIndex];
        if (cell) {
            cell.progress = progress;
        }
        if (progress >= 1.0) {
            [weakSelf moveNext];
        }
    };
    self.episodePlayer.onLoadCompletedBlock = ^{
        AUIShortEpisodePlayCell *cell = [weakSelf cell:weakSelf.playIndex];
        if (cell) {
            cell.isLoading = NO;
        }
    };
    self.episodePlayer.onPlayPauseBlock = ^(BOOL isPause) {
        AUIShortEpisodePlayCell *cell = [weakSelf cell:weakSelf.playIndex];
        if (cell) {
            cell.isPause = isPause;
        }
    };
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
}

- (void)playCurrentCell {
    AUIShortEpisodePlayCell *playingCell = [self cell:self.playIndex];
    if (playingCell) {
        [self.episodePlayer play:[self.episodeData.list objectAtIndex:self.playIndex] playerView:playingCell.playerView];
        self.playingCell.isLoading = YES;
        self.playingCell.isPause = NO;
        self.playingCell.progress = 0.0;
        self.playingCell = playingCell;
        
        if ([self canMoveNext]) {
            AUIShortEpisodePlayCell *cell = (AUIShortEpisodePlayCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:self.playIndex + 1 inSection:0]];
            [self.episodePlayer startPreloadNext:cell.playerView];
        }
    }
    else {
        NSAssert(NO, @"当前要播放的cell还未展示");
        [self.episodePlayer stop];
    }
}

- (void)setPlayIndex:(NSInteger)playIndex {
    if (_playIndex == playIndex) {
        return;
    }
    
    _playIndex = playIndex;
    NSLog(@"playIndex update: %zd", _playIndex);
}

- (AUIShortEpisodePlayCell *)cell:(NSInteger)index {
    AUIShortEpisodePlayCell *cell = (AUIShortEpisodePlayCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    return cell;  // 可能为nil，因为当前播放的cell不是visible，需要滑动当前cell可见
}

- (BOOL)canMoveNext {
    return self.autoMoveNext && self.playIndex < self.episodeData.list.count - 1;
}

- (void)moveNext {
    if (![self canMoveNext]) {
        return;
    }

    self.playIndex++;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.playIndex inSection:0];
    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self playCurrentCell];
    });
}

- (void)moveAt:(AUIVideoInfo *)videoInfo {
    NSInteger index = [self.episodeData.list indexOfObject:videoInfo];
    if (index < 0 || index >= self.episodeData.list.count) {
        return;
    }
    if (self.playIndex == index) {
        return;
    }
    self.playIndex = index;

    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self playCurrentCell];
    });
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.episodeData.list.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"cellForItemAtIndexPath:%zd", indexPath.row);
    AUIShortEpisodePlayCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:AVCollectionViewCellIdentifier forIndexPath:indexPath];
    __weak typeof(self) weakSelf = self;
    cell.onBackBtnClickBlock = ^(AUIShortEpisodePlayCell * _Nonnull cell) {
        [weakSelf.episodePlayer stop];
        [weakSelf.episodePlayer destroyPlayer];
        [weakSelf goBack];
    };
    cell.onPlayBtnClickBlock = ^(AUIShortEpisodePlayCell * _Nonnull cell) {
        [weakSelf.episodePlayer pause:!cell.isPause];
    };
    cell.onLikeBtnClickBlock = ^(AUIShortEpisodePlayCell * _Nonnull cell, AVBaseButton *likeBtn) {
        likeBtn.selected = !likeBtn.selected;
        cell.videoInfo.isLiked = likeBtn.selected;
        cell.videoInfo.likeCount = likeBtn.selected ? (cell.videoInfo.likeCount + 1) : (cell.videoInfo.likeCount - 1);
        [cell refreshUI];
        // TODO: 发送点赞请求给服务端，需要自己实现
    };
    cell.onCommentBtnClickBlock = ^(AUIShortEpisodePlayCell * _Nonnull cell, AVBaseButton *commentBtn) {
        // TODO: 打开评论页面，需要自己实现
        [AVToastView show:@"暂不支持该功能，需要自己实现" view:weakSelf.view position:AVToastViewPositionMid];
    };
    cell.onShareBtnClickBlock = ^(AUIShortEpisodePlayCell * _Nonnull cell, AVBaseButton *shareBtn) {
        // TODO: 打开分享页面，需要自己实现
        [AVToastView show:@"暂不支持改功能，需要自己实现" view:weakSelf.view position:AVToastViewPositionMid];
    };
    cell.onEntranceViewClickBlock = ^(AUIShortEpisodePlayCell * _Nonnull cell) {
        [AUIShortEpisodeListPanel setPanelHeight:weakSelf.episodeData max:weakSelf.contentView.av_height * 3 / 5.0];
        AUIShortEpisodeListPanel *panel = [[AUIShortEpisodeListPanel alloc] initWithFrame:CGRectMake(0, 0, weakSelf.contentView.av_width, 0) withEpisodeData:weakSelf.episodeData withPlaying:cell.videoInfo];
        panel.onVideoSelectedBlock = ^(AUIShortEpisodeListPanel * _Nonnull sender, AUIVideoInfo * _Nonnull videoInfo) {
            [weakSelf moveAt:videoInfo];
            [sender hide];
        };
        panel.onShowChanged = ^(AVBaseControllPanel * _Nonnull sender) {
            weakSelf.autoMoveNext = !sender.isShowing;
        };
        [AUIShortEpisodeListPanel present:panel onView:weakSelf.contentView backgroundType:AVControllPanelBackgroundTypeClickToClose];
    };
    cell.onProgressViewDragingBlock = ^(AUIShortEpisodePlayCell * _Nonnull cell, CGFloat progress) {
        if (progress >= 1.0) {
            progress = 0.99;
        }
        [weakSelf.episodePlayer seek:progress];
    };
    cell.episodeTitle = self.episodeData.title;
    cell.videoInfo = self.episodeData.list[indexPath.row];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.collectionView.bounds.size;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0f;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsZero;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat pageHeight = self.collectionView.av_height;
    NSInteger index = (NSInteger)floor((self.collectionView.contentOffset.y + 0.5 * pageHeight) / pageHeight);
    if (self.playIndex != index) {
        self.playIndex = index;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self playCurrentCell];
        });
    }
}

- (void)applicationDidBecomeActive:(NSNotification *)nofication {
    NSLog(@"applicationDidBecomeActive");
    [self.episodePlayer pause:NO];
}

- (void)applicationWillResignActive:(NSNotification *)nofication {
    NSLog(@"applicationWillResignActive");
    [self.episodePlayer pause:YES];
}

@end
