//
//  AUIVideoRecorder.h
//  AlivcUGC_Demo
//
//  Created by Bingo on 2022/5/23.
//

#import "AUIFoundation.h"
#import "AUIRecorderConfig.h"

NS_ASSUME_NONNULL_BEGIN

@class AUIVideoRecorder;
typedef void(^OnRecordCompletion)(AUIVideoRecorder *recorder,
                                  NSString *taskPath,
                                  NSString * _Nullable outputPath,
                                  NSError * _Nullable error);

@interface AUIVideoRecorder : UIViewController
@property (nonatomic, copy) OnRecordCompletion onCompletion;
- (instancetype) initWithConfig:(nullable AUIRecorderConfig *)config onCompletion:(OnRecordCompletion)completion;
- (instancetype) initWithCompletion:(OnRecordCompletion)completion;
@end

NS_ASSUME_NONNULL_END
