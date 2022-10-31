//
//  AUIVideoEditor.h
//  AlivcUGC_Demo
//
//  Created by Bingo on 2022/5/23.
//

#import "AUIFoundation.h"
#import "AlivcUgsvSDKHeader.h"
#import "AUIVideoOutputParam.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUIVideoEditor : AVBaseViewController

- (instancetype)initWithTaskPath:(NSString *)taskPath;
- (instancetype)initWithVideoFilePath:(NSString *)videoFilePath;
- (instancetype)initWithClips:(NSArray<AliyunClip *> * _Nullable)clips withParam:(AUIVideoOutputParam *)param;

@property (nonatomic, assign) BOOL saveToAlbumExportCompleted;
@property (nonatomic, assign) BOOL needToPublish;

@end

NS_ASSUME_NONNULL_END
