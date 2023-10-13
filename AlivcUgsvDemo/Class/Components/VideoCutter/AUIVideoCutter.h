//
//  AUIVideoCutter.h
//  AlivcUgsvDemo
//
//  Created by coder.pi on 2022/12/9.
//

#import "AVBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUIVideoCutterParam : NSObject

@property (nonatomic, copy) NSString *inputPath;
@property (nonatomic, assign) BOOL isImage;
@property (nonatomic, assign) CGSize outputAspectRatio;
@property (nonatomic, assign) NSTimeInterval outputDuration;

@end

@interface AUIVideoCutterResult : NSObject

@property (nonatomic, assign) NSTimeInterval startTime;
@property (nonatomic, assign) CGRect frame;

@end

@class AUIVideoCutter;
typedef BOOL(^OnCutCompleted)(BOOL isCancel, AUIVideoCutterParam *param, AUIVideoCutterResult * _Nullable result, AUIVideoCutter *sender);

@interface AUIVideoCutter : AVBaseViewController

- (instancetype)initWithParam:(AUIVideoCutterParam *)param completed:(OnCutCompleted)completed;

@end

NS_ASSUME_NONNULL_END
