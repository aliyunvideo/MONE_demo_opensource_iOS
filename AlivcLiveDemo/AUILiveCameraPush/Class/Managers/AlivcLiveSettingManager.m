//
//  AlivcLiveSettingManager.m
//  AlivcLiveDemo
//
//  Created by ISS013602000846 on 2022/7/6.
//

#import "AlivcLiveSettingManager.h"

#pragma mark -- AlivcLiveSettingConfig
@implementation AlivcLiveSettingConfig

- (void)convert:(id)config {
    if ([config isKindOfClass:[AlivcLivePushConfig class]] ||
        [config isKindOfClass:[AlivcLiveSettingConfig class]]) {
        self.targetVideoBitrate = [config targetVideoBitrate];
        self.minVideoBitrate = [config minVideoBitrate];
        self.pushMirror = [config pushMirror];
        self.previewMirror = [config previewMirror];
        self.previewDisplayMode = [config previewDisplayMode];
        self.qualityMode = [config qualityMode];
        self.audioScene = [config audioScene];
    }
}

@end

#pragma mark -- AlivcLiveSettingManager
@implementation AlivcLiveSettingManager

+ (instancetype)manager {
    static AlivcLiveSettingManager *manger = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manger = [[AlivcLiveSettingManager alloc] init];
    });
    return manger;
}

- (void)setCurrentMusicPlayIndex:(NSInteger)currentMusicPlayIndex {
    _currentMusicPlayIndex = currentMusicPlayIndex;
    if (currentMusicPlayIndex == -1) {
        self.currentMusicPlayModel = nil;
    } else {
        if (self.musicData && self.musicData.count > 0) {
            self.currentMusicPlayModel = self.musicData[currentMusicPlayIndex];
        }
    }
}

- (void)reload {
    [self resetMoreSettingConfig];
    [self fetchMusicData];
}

- (void)resetMoreSettingConfig {
    [self.moreSettingConfig convert:self.savedConfig];
}

- (void)fetchMusicData {
    AlivcLiveMusicInfoModel *model0 = [[AlivcLiveMusicInfoModel alloc] initWithMusicName:AUILiveCameraPushString(@"无音乐") musicPath:nil musicDuation:0.0 isLocal:YES];
    
    NSString *path1 = AUILiveCameraPushData(@"Axol.mp3");
    AlivcLiveMusicInfoModel *model1 = [[AlivcLiveMusicInfoModel alloc] initWithMusicName:AUILiveCameraPushString(@"Axol(APP资源)") musicPath:path1 musicDuation:0.0 isLocal:YES];
    
    NSString *path2 = [self getMusicPathWithMusicName:@"Pas de Deux"];
    
    AlivcLiveMusicInfoModel *model2 = [[AlivcLiveMusicInfoModel alloc] initWithMusicName:AUILiveCameraPushString(@"Pas de Deux(沙盒资源)") musicPath:path2 musicDuation:0.0 isLocal:YES];
    
    NSString *path3 = @"http://docs-aliyun.cn-hangzhou.oss.aliyun-inc.com/assets/attach/51991/cn_zh/1511776743437/JUST%202017.mp3";
    AlivcLiveMusicInfoModel *model3 = [[AlivcLiveMusicInfoModel alloc] initWithMusicName:AUILiveCameraPushString(@"网络音乐1") musicPath:path3 musicDuation:0.0 isLocal:NO];
    self.musicData = [[NSArray alloc] initWithObjects:model0, model1, model2, model3, nil];
    
    [self resetMusic];
}

- (NSString *)getMusicPathWithMusicName:(NSString *)musicName {
    
    NSString *musicResource = [NSString stringWithFormat:@"%@.mp3", musicName];
    NSString *bundlePath = AUILiveCameraPushData(musicResource);
    
    if (!bundlePath) {
        return nil;
    }
    
    NSString *cachePath = [[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:musicName] stringByAppendingPathExtension:@"mp3"];
        
    if (![[NSFileManager defaultManager] fileExistsAtPath:cachePath]) {
        [[NSFileManager defaultManager] copyItemAtPath:bundlePath toPath:cachePath error:nil];
    }
    
    return cachePath;
}

- (void)resetMusic {
    self.currentMusicPlayIndex = 1;
}

- (void)clear {
    [self resetMoreSettingConfig];
    self.currentMusicPlayIndex = -1;
    self.musicData = @[];
    self.musicEarBack = NO;
    self.musicDenoise = NO;
    self.musicIntelligentDenoise = NO;
    self.musicPlay = NO;
    self.musicMuted = NO;
    self.musicLoop = YES;
    self.musicAccompanimentValue = 50;
    self.musicHumanvoiceValue = 50;
}

#pragma mark -- lazy load
- (AlivcLiveSettingConfig *)moreSettingConfig {
    if (!_moreSettingConfig) {
        _moreSettingConfig = [[AlivcLiveSettingConfig alloc] init];
    }
    return _moreSettingConfig;
}

@end
