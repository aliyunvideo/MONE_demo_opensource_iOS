//
//  AlivcLiveSettingManager.h
//  AlivcLiveDemo
//
//  Created by ISS013602000846 on 2022/7/6.
//

#import <Foundation/Foundation.h>
#import "AlivcLiveMusicInfoModel.h"

NS_ASSUME_NONNULL_BEGIN
#pragma mark -- AlivcLiveSettingConfig
@interface AlivcLiveSettingConfig : NSObject

@property (nonatomic, assign) int targetVideoBitrate;
@property (nonatomic, assign) int minVideoBitrate;
@property (nonatomic, assign) bool pushMirror;
@property (nonatomic, assign) bool previewMirror;
@property (nonatomic, assign) AlivcPusherPreviewDisplayMode previewDisplayMode;
@property (nonatomic, assign) AlivcLivePushQualityMode qualityMode;
@property (nonatomic, assign) AlivcLivePusherAudioScenario audioScene;

- (void)convert:(id)config;

@end

#pragma mark -- AlivcLiveSettingManager
@interface AlivcLiveSettingManager : NSObject

@property (nonatomic, strong) AlivcLivePushConfig *savedConfig;
@property (nonatomic, strong) AlivcLiveSettingConfig *moreSettingConfig;
@property (nonatomic, copy) NSArray<AlivcLiveMusicInfoModel *> *musicData;
@property (nonatomic, strong, nullable) AlivcLiveMusicInfoModel *currentMusicPlayModel;
@property (nonatomic, assign) NSInteger currentMusicPlayIndex;
@property (nonatomic, assign) BOOL musicEarBack;
@property (nonatomic, assign) BOOL musicDenoise;
@property (nonatomic, assign) BOOL musicIntelligentDenoise;
@property (nonatomic, assign) BOOL musicPlay;
@property (nonatomic, assign) BOOL musicMuted;
@property (nonatomic, assign) BOOL musicLoop;
@property (nonatomic, assign) int musicAccompanimentValue;
@property (nonatomic, assign) int musicHumanvoiceValue;

+ (instancetype)manager;
- (void)reload;
- (void)resetMusic;
- (void)clear;


@end

NS_ASSUME_NONNULL_END
