//
//  AUIMusicPCMLineView.m
//  AlivcUgsvDemo
//
//  Created by coder.pi on 2022/6/9.
//

#import "AUIMusicPCMLineView.h"
#import "AUIUgsvMacro.h"
#import <AUIUgsvCom/AUIUgsvCom.h>

typedef void(^FetchPCMCompleted)(NSArray<NSNumber *> *);
@interface AUIMusicPCMCachesManager : NSObject
{
    NSMutableDictionary<NSString *, NSArray<NSNumber *> *> *_caches;
    NSMutableDictionary<NSString *, NSMutableArray<FetchPCMCompleted> *> *_fetchingCBs;
    NSMutableArray<NSString *> *_recordMRU;
}
+ (instancetype)Shared;
- (void)fetch:(NSString *)path completed:(void(^)(NSArray<NSNumber *> *))completed;
- (void)random:(NSString *)path completed:(void(^)(NSArray<NSNumber *> *))completed;
@end


@implementation AUIMusicPCMLineView

- (void)setup {
    _realShowPercentage = 1.0;
    _normalizedBegin = 0.0;
    _normalizedCurrent = 1.0;
    _normalizedEnd = 1.0;
    _color = AUIFoundationColor(@"fill_ultraweak");
    self.clipsToBounds = YES;
    self.backgroundColor = UIColor.clearColor;
    self.userInteractionEnabled = NO;
}

- (instancetype)initWithPCMData:(NSArray *)pcmData {
    self = [super init];
    if (self) {
        [self setup];
        self.pcmData = pcmData;
    }
    return self;
}

- (instancetype)initWithFile:(NSString *)filePath {
    self = [super init];
    if (self) {
        [self setup];
        __weak typeof(self) weakSelf = self;
//        [AUIMusicPCMCachesManager.Shared fetch:filePath completed:^(NSArray<NSNumber *> *result) {
        [AUIMusicPCMCachesManager.Shared random:filePath completed:^(NSArray<NSNumber *> *result) {
            weakSelf.pcmData = result;
        }];
    }
    return self;
}

- (void)setPcmData:(NSArray<NSNumber *> *)pcmData {
    _pcmData = pcmData;
    [self refresh];
}

- (void)setNormalizedCurrent:(CGFloat)normalizedCurrent {
    if (_normalizedCurrent == normalizedCurrent) {
        return;
    }
    _normalizedCurrent = normalizedCurrent;
    [self refresh];
}

- (void)setRealShowPercentage:(CGFloat)realShowPercentage {
    _realShowPercentage = MAX(0.01, MIN(1.0, realShowPercentage));
}

- (void)drawRect:(CGRect)rect {
    if (_pcmData.count == 0) {
        return;
    }
    
    const CGFloat kLineWidth = 2.0;
    const CGFloat kCellWidth = kLineWidth * 2;
    CGSize size = self.bounds.size;

    CGFloat realWidth = size.width / (_normalizedEnd - _normalizedBegin);
    CGFloat begin = realWidth * _normalizedBegin;
    int beginSkip = ceil(begin / kCellWidth);
    CGFloat beginOffset = beginSkip * kCellWidth - begin;
    
    CGFloat width = realWidth * _realShowPercentage;
    CGFloat height = size.height;
    int lineCount = width / kLineWidth;
    int skip = MAX(1, (int)_pcmData.count / lineCount);
    CGFloat stopEnd = realWidth * (_normalizedCurrent * _realShowPercentage - _normalizedBegin);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, _color.CGColor);
    CGContextSetLineWidth(context, kLineWidth);
    CGContextSetFillColorWithColor(context, UIColor.clearColor.CGColor);
    CGContextFillRect(context, self.bounds);
    CGFloat offset = kLineWidth * 0.5 + beginOffset;
    BOOL isInMute = NO;
    for (int i = beginSkip * skip; i < _pcmData.count && offset < stopEnd; i += skip) {
        float value = _pcmData[i].floatValue;
        value = MAX(0.0, MIN(1.0, value));
        if (value == 0) {
            if (isInMute) {
                CGContextAddLineToPoint(context, offset, height * 0.5);
            }
            else {
                CGContextMoveToPoint(context, offset, height * 0.5);
                CGContextSetLineWidth(context, kLineWidth * 0.5);
                isInMute = YES;
            }
        }
        else {
            if (isInMute) {
                CGContextStrokePath(context);
                CGContextSetLineWidth(context, kLineWidth);
                isInMute = NO;
            }
            
            CGFloat lineHeight = value * height;
            CGFloat space = (height - lineHeight) * 0.5;
            
            CGContextMoveToPoint(context, offset, space);
            CGContextAddLineToPoint(context, offset, height - space);
            CGContextStrokePath(context);
        }
        offset += kCellWidth;
    }
    if (isInMute) {
        CGContextStrokePath(context);
    }
}

- (void)refresh {
    [self setNeedsDisplay];
}

@end

// MARK: - AUIMusicPCMCachesManager
@implementation AUIMusicPCMCachesManager

+ (instancetype) Shared {
    static dispatch_once_t onceToken;
    static AUIMusicPCMCachesManager *s_shared;
    dispatch_once(&onceToken, ^{
        s_shared = [AUIMusicPCMCachesManager new];
    });
    return s_shared;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _caches = @{}.mutableCopy;
        _fetchingCBs = @{}.mutableCopy;
        _recordMRU = @[].mutableCopy;
    }
    return self;
}

#define noiseFloor (-50.0)
static NSArray<NSNumber *> * s_generateRandomPCM(NSTimeInterval duration, UInt32 sampleRate) {
    UInt32 sampleCount = duration * sampleRate;
    NSMutableArray<NSNumber *> *result = @[].mutableCopy;
    const int FullRange = 1000;
    // 20%~80%
    const int Min = FullRange * 0.2;
    const int Max = FullRange * 0.8;
    const int Range = Max - Min;
    for (UInt32 i = 0; i < sampleCount; ++i) {
        double value = arc4random() % Range + Min;
        value = value / FullRange;
        [result addObject:@(value)];
    }
    return result;
}

- (void)addCacheData:(NSArray<NSNumber *> *)data forPath:(NSString *)path {
    _caches[path] = data;
    [_recordMRU removeObject:path];
    [_recordMRU addObject:path];
    if (_recordMRU.count > 20) {
        NSString *needRemovePath = _recordMRU.firstObject;
        [_caches removeObjectForKey:needRemovePath];
        [_recordMRU removeObjectAtIndex:0];
    }
}

- (void)onCompleteForPath:(NSString *)path result:(NSArray<NSNumber *> *)result {
    NSArray<FetchPCMCompleted> *cbs = _fetchingCBs[path];
    [_fetchingCBs removeObjectForKey:path];
    if (!cbs) {
        return;
    }
    for (FetchPCMCompleted cb in cbs) {
        cb(result);
    }
}

static const UInt32 kSampleRate = 25;
- (void)random:(NSString *)path completed:(void(^)(NSArray<NSNumber *> *))completed {
    if (!completed) {
        return;
    }
    
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:path] options:nil];
    NSTimeInterval duration = CMTimeGetSeconds(asset.duration);
    NSArray<NSNumber *> *result = s_generateRandomPCM(duration, kSampleRate);
    completed(result);
}

- (void)fetch:(NSString *)path completed:(void(^)(NSArray<NSNumber *> *))completed {
    if (!completed) {
        return;
    }
    
    NSArray<NSNumber *> *cache = _caches[path];
    if (cache) {
        completed(cache);
        return;
    }
    NSMutableArray<FetchPCMCompleted> *fetching = _fetchingCBs[path];
    if (fetching) {
        [fetching addObject:completed];
        return;
    }
    fetching = @[].mutableCopy;
    [fetching addObject:completed];
    _fetchingCBs[path] = fetching;
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        AVURLAsset *asset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:path] options:nil];
        [AUIAsyncImageGeneratorAudio fetchAudioDBData:asset
                                           sampleRate:kSampleRate
                                            completed:^(NSData *dbData,
                                                        UInt32 dbRate,
                                                        Float32 normalizeMax,
                                                        UInt32 channelCount,
                                                        NSError *error) {
            if (error) {
                NSTimeInterval duration = CMTimeGetSeconds(asset.duration);
                NSArray<NSNumber *> *result = s_generateRandomPCM(duration, kSampleRate);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf onCompleteForPath:path result:result];
                });
                return;
            }
            
            NSMutableArray *result = @[].mutableCopy;
            Float32 *samples = (Float32 *)dbData.bytes;
            NSUInteger count = dbData.length / sizeof(Float32);
            for (NSUInteger i = 0; i < count;) {
                Float32 db = 0;
                for (NSUInteger j = 0; j < channelCount && i < count; ++j, ++i) {
                    db += samples[i];
                }
                db /= channelCount;
                db = (db - noiseFloor) / (normalizeMax - noiseFloor);
                [result addObject:@(db)];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf addCacheData:result forPath:path];
                [weakSelf onCompleteForPath:path result:result];
            });
        }];
    });
}

@end
