//
//  AUIVideoCrop.h
//  AlivcUGC_Demo
//
//  Created by Bingo on 2022/5/23.
//

#import "AUIFoundation.h"
#import "AlivcUgsvSDKHeader.h"
#import "AUIVideoOutputParam.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUIVideoCrop : AVBaseViewController

// param为空的情况下，不做重新编码，根据选定时长进行快裁剪
- (instancetype)initWithFilePath:(NSString *)path withParam:(nullable AUIVideoOutputParam *)param;

@property (nonatomic, assign) BOOL saveToAlbumExportCompleted;
@property (nonatomic, assign) BOOL needToPublish;

@end

NS_ASSUME_NONNULL_END
