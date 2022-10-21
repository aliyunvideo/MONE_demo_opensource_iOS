//
//  AUIVideoCropExport.h
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/6/10.
//

#import <UIKit/UIKit.h>
#import "AUIMediaProgressViewController.h"
#import "AUIVideoOutputParam.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUIVideoCropExport : NSObject <AUIMediaProgressProtocol>

@property (nonatomic, assign) BOOL saveToAlbumExportCompleted;

- (instancetype)initWithVideoFilePath:(NSString *)videoFilePath
                            startTime:(NSTimeInterval)startTime
                              endTime:(NSTimeInterval)endTime
                             cropRect:(CGRect)cropRect
                                param:(AUIVideoOutputParam *)param;

@end

NS_ASSUME_NONNULL_END
