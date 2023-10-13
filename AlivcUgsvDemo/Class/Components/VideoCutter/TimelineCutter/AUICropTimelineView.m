//
//  AUICropTimelineView.m
//  AlivcUgsvDemo
//
//  Created by coder.pi on 2022/12/9.
//

#import "AUICropTimelineView.h"
#import "AUIUgsvMacro.h"
#import "AUIFoundation.h"
#import "AVAsset+UgsvHelper.h"
#import "AUIVideoPlayProtocol.h"
#import <AUIUgsvCom/AUIUgsvCom.h>

// MARK: - Thumbnail Mgr
@class AUICropTimelineThumbnailInfo;
typedef void(^ThumbnailInfoCallback)(AUICropTimelineThumbnailInfo *info);

@interface AUICropTimelineThumbnailInfo : NSObject
@property (nonatomic, assign) int64_t pos;
@property (nonatomic, strong) UIImage *thumbnail;
@property (nonatomic, assign) int retryCount;
@property (nonatomic, strong) NSMutableArray<ThumbnailInfoCallback> *callbacks;
@end
@implementation AUICropTimelineThumbnailInfo
- (NSMutableArray<ThumbnailInfoCallback> *)callbacks {
    if (!_callbacks) {
        _callbacks = @[].mutableCopy;
    }
    return _callbacks;
}
@end

@interface AUICropTimelineThumbnailMgr : NSObject
{
    id<AUIAsyncImageGeneratorProtocol> _imageGenerator;
    NSMutableDictionary<NSNumber *, AUICropTimelineThumbnailInfo *> *_caches;

    NSMutableSet<NSNumber *> *_waitRequests;
}
@property (nonatomic, readonly) int64_t duration;
@property (nonatomic, assign) int64_t cellDuration;
@property (nonatomic, readonly) int cellCount;
- (instancetype)initWithFilePath:(NSString *)filePath duration:(NSTimeInterval)duration;
- (void)getThumbnail:(int)index callback:(ThumbnailInfoCallback)callback;
@end


// MARK: - UI
@interface AUICropTimelineCell : UICollectionViewCell
@property (nonatomic, assign) int index;
@property (nonatomic, strong) UIImageView *thumbnail;
@property (nonatomic, weak) AUICropTimelineThumbnailMgr *thumbnailMgr;
@end

@interface AUICropTimelineView()<UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, strong) id<AUIVideoPlayProtocol> player;
@property (nonatomic, strong) AUICropTimelineThumbnailMgr *thumbnailMgr;
@property (nonatomic, assign) CGFloat timeScale; // time/pixel
@property (nonatomic, readonly) NSTimeInterval cropDuration;

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UILabel *durationLabel;
@property (nonatomic, strong) UIView *rightMaskView;
@property (nonatomic, strong) UIView *leftMaskView;
@property (nonatomic, strong) UIView *centerMaskView;
@end

@implementation AUICropTimelineView

static const CGFloat kCellSize = 44.0;
static const CGFloat kMaskEdgeSize = 80.0;
#define kCellIdentifier @"CropTimelineCellIdentifier"

- (instancetype)initWithPlayer:(id<AUIVideoPlayProtocol>)player
                  cropDuration:(NSTimeInterval)duration
                      filePath:(NSString *)filePath {
    self = [super init];
    if (self) {
        _cropDuration = duration;
        _thumbnailMgr = [[AUICropTimelineThumbnailMgr alloc] initWithFilePath:filePath duration:player.duration];
        self.player = player;
        [self updatePlayRange];

        [self setupContent];
        [self setupMaskView];
        [self setupDurationLabel];
        
        _durationLabel.text = [NSString stringWithFormat:@"%.1fs", self.cropDuration];
        [self reloadData];
    }
    return self;
}

- (void)setTimeScale:(CGFloat)timeScale {
    if (_timeScale == timeScale) {
        return;
    }
    _timeScale = timeScale;
    int count = self.thumbnailMgr.cellCount;
    self.thumbnailMgr.cellDuration = _timeScale * kCellSize * 1000;
    if (count != self.thumbnailMgr.cellCount) {
        [self reloadData];
    }
}

- (void) reloadData {
    [_collectionView reloadData];
}

// MARK: - UICollectionViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetX = scrollView.contentOffset.x + self.centerMaskView.av_left;
    _startTime = MIN(self.player.duration, MAX(0, offsetX) * self.timeScale);
    [self.player seek:_startTime];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.player pause];
}

- (void)updatePlayRange {
    self.player.isLoopPlay = YES;
    [self.player enablePlayInRange:self.startTime rangeDuration:self.cropDuration];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self updatePlayRange];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self updatePlayRange];
}

// MARK: - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.thumbnailMgr.cellCount;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AUICropTimelineCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentifier forIndexPath:indexPath];
    cell.thumbnailMgr = self.thumbnailMgr;
    cell.index = (int)indexPath.row;
    return cell;
}

// MARK: - views
- (void)setupContent {
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(44, 44);
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _collectionView.backgroundColor = UIColor.clearColor;
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.showsVerticalScrollIndicator = NO;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.contentInset = UIEdgeInsetsMake(0, kMaskEdgeSize, 0, kMaskEdgeSize);
    [_collectionView registerClass:AUICropTimelineCell.class forCellWithReuseIdentifier:kCellIdentifier];
    [self addSubview:_collectionView];
}

- (UIView *)addMaskView {
    UIView *maskView = [UIView new];
    maskView.av_height = kCellSize;
    maskView.userInteractionEnabled = NO;
    maskView.backgroundColor = AUIFoundationColor(@"tsp_fill_weak");
    [self addSubview:maskView];
    return maskView;
}

- (void)setupMaskView {
    _rightMaskView = [self addMaskView];
    _leftMaskView = [self addMaskView];
    _centerMaskView = [self addMaskView];
    _centerMaskView.backgroundColor = UIColor.clearColor;
    _centerMaskView.layer.borderColor = UIColor.whiteColor.CGColor;
    _centerMaskView.layer.borderWidth = 2.f;
    _centerMaskView.layer.cornerRadius = 3.f;
    [self addSubview:_centerMaskView];
}

- (void)setupDurationLabel {
    _durationLabel = [UILabel new];
    _durationLabel.backgroundColor = UIColor.clearColor;
    _durationLabel.textColor = AUIFoundationColor(@"text_ultraweak");
    _durationLabel.font = AVGetRegularFont(10.0);
    _durationLabel.text = @"0s";
    _durationLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_durationLabel];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize size = self.bounds.size;
    
    // mask view
    CGFloat maskY = (size.height - kCellSize) * 0.5;
    _leftMaskView.frame = CGRectMake(0, maskY, kMaskEdgeSize, kCellSize);
    _rightMaskView.frame = CGRectMake(size.width - kMaskEdgeSize, maskY, kMaskEdgeSize, kCellSize);
    CGFloat cropWidth = size.width - 2 * kMaskEdgeSize;
    _centerMaskView.frame = CGRectMake(kMaskEdgeSize, maskY, cropWidth, kCellSize);
    
    // duration
    _durationLabel.frame = CGRectMake(0, 0, size.width, maskY);
    
    // collection
    _collectionView.contentInset = UIEdgeInsetsMake(maskY, kMaskEdgeSize, maskY, kMaskEdgeSize);
    _collectionView.frame = self.bounds;
    
    self.timeScale = self.cropDuration / cropWidth;
}

@end

// MARK: - AUICropTimelineCell
@implementation AUICropTimelineCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _index = -1;
        _thumbnail = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
        _thumbnail.contentMode = UIViewContentModeScaleAspectFill;
        _thumbnail.clipsToBounds = YES;
        [self.contentView addSubview:_thumbnail];
        self.backgroundColor = AUIFoundationColor(@"tsp_fill_infrared");
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _thumbnail.frame = self.contentView.bounds;
}

- (void)setIndex:(int)index {
    if (_index == index) {
        return;
    }
    _index = index;
    self.thumbnail.alpha = 0.0;
    
    __weak typeof(self) weakSelf = self;
    [_thumbnailMgr getThumbnail:index callback:^(AUICropTimelineThumbnailInfo *info) {
        if (weakSelf.index != index) {
            return;
        }
        weakSelf.thumbnail.image = info.thumbnail;
        [UIView animateWithDuration:0.15 animations:^{
            weakSelf.thumbnail.alpha = 1.0;
        }];
    }];
}

@end

// MARK: - Thumbnail Mgr
@implementation AUICropTimelineThumbnailMgr
- (instancetype)initWithFilePath:(NSString *)filePath duration:(NSTimeInterval)duration {
    self = [super init];
    if (self) {
        _imageGenerator = [[AUIAsyncImageGeneratorVideo alloc] initWithPath:filePath];
        _duration = duration * 1000;
        
        _caches = @{}.mutableCopy;
        _waitRequests = [NSMutableSet set];
    }
    return self;
}

- (int) cellCount {
    if (self.cellDuration <= 0) {
        return 1;
    }
    
    int count = (int)(self.duration / self.cellDuration);
    if (self.duration % self.cellDuration > 0) {
        ++count;
    }
    return count;
}

- (void)setCellDuration:(int64_t)cellDuration {
    if (_cellDuration == cellDuration) {
        return;
    }
    _cellDuration = cellDuration;
    
    for (NSNumber *idx in _caches.allKeys) {
        int64_t beginPos = idx.intValue * self.cellDuration;
        int64_t endPos = (idx.intValue + 1) * self.cellDuration;
        int64_t curPos = _caches[idx].pos;
        if (beginPos > curPos || curPos > endPos) {
            _caches[idx].retryCount = 0;
            _caches[idx].thumbnail = nil;
            _caches[idx].pos = (beginPos + endPos) * 0.5;
            [self request:_caches[idx]];
        }
    }
}

- (void)getThumbnail:(int)index callback:(ThumbnailInfoCallback)callback {
    AUICropTimelineThumbnailInfo *info = [_caches objectForKey:@(index)];
    if (!info) {
        info = [AUICropTimelineThumbnailInfo new];
        [info.callbacks addObject:callback];
        _caches[@(index)] = info;
        info.pos = self.cellDuration * (index + 0.5);
        [self request:info];
        return;
    }
    
    if (info.thumbnail) {
        callback(info);
    } else {
        [info.callbacks addObject:callback];
    }
}

- (void) addImage:(UIImage *)img forPos:(NSTimeInterval)time {
    int64_t pos = time * 1000;
    if (self.cellDuration <= 0) {
        return;
    }
    
    int index = (int)(pos / self.cellDuration);
    AUICropTimelineThumbnailInfo *info = _caches[@(index)];
    if (!info) {
        if (!img) {
            return;
        }
        
        info = [AUICropTimelineThumbnailInfo new];
        info.pos = pos;
        info.thumbnail = img;
        _caches[@(index)] = info;
        return;
    }
    
    if (!img) {
        // 重试
        if (info.retryCount < 3) {
            ++info.retryCount;
            [self request:info];
            return;
        }
        
        int count = self.cellCount;
        for (int l = index - 1, r = index + 1; l >= 0 || r < count;--l,++r) {
            if (_caches[@(l)].thumbnail) {
                img = _caches[@(l)].thumbnail;
                break;
            }
            if (_caches[@(r)].thumbnail) {
                img = _caches[@(r)].thumbnail;
                break;
            }
        }
        if (!img) {
            __weak typeof(self) weakSelf = self;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf request:info];
            });
        }
    }

    NSAssert(img, @"Got nil thumbnail");
    info.retryCount = 0;
    info.pos = pos;
    info.thumbnail = img;
    NSArray *cbs = info.callbacks.copy;
    [info.callbacks removeAllObjects];
    for (ThumbnailInfoCallback cb in cbs) {
        cb(info);
    }
}

- (void)request:(AUICropTimelineThumbnailInfo *)info {
    [_waitRequests addObject:@(info.pos)];
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf requestImpl];
    });
}

- (void)requestImpl {
    if (_waitRequests.count == 0) {
        return;
    }
    NSSet *requests = _waitRequests.copy;
    _waitRequests = [NSMutableSet set];
    
    NSMutableArray *times = @[].mutableCopy;
    for (NSNumber *time in requests) {
        [times addObject:@(time.longLongValue/1000.0)];
    }
    
    __weak typeof(self) weakSelf = self;
    [_imageGenerator generateImagesAsynchronouslyForTimes:times
                                                 duration:0
                                                completed:^(NSTimeInterval pos, UIImage *img) {
        [weakSelf addImage:img forPos:pos];
    }];
}
@end

