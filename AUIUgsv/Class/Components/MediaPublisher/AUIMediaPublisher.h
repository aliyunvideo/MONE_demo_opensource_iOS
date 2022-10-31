//
//  AUIMediaPublisher.h
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/6/7.
//

#import "AUIFoundation.h"
#import "AUIMediaProgressViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUIMediaPublisher : AVBaseViewController

- (instancetype)initWithExportProgress:(id<AUIMediaProgressProtocol>)exportProgress;
- (instancetype)initWithVideoFilePath:(NSString *)videoFilePath withThumbnailImage:(nullable UIImage *)thumb;

@property (nonatomic, copy)void (^onFinish)(UIViewController *current, NSError * _Nullable error,  id  _Nullable product);

@end

NS_ASSUME_NONNULL_END
