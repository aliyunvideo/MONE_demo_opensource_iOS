//
//  AUIMediaProgressViewController.h
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/6/10.
//

#import "AUIFoundation.h"

NS_ASSUME_NONNULL_BEGIN

@protocol AUIMediaProgressProtocol <NSObject>

@property (nonatomic, copy) void(^requestCoverImageBlock)(void(^completedBlock)(UIImage *coverImage));
- (CGSize)coverImageSize;


@property (nonatomic, copy) void (^onMediaDoProgress)(float progress);
@property (nonatomic, copy) void (^onMediaFinishProgress)(NSError * _Nullable error,  id  _Nullable product);

- (void)mediaStartProgress;
- (void)mediaCancelProgress;

@end

typedef NS_ENUM(NSUInteger, AUIMediaProgressState) {
    AUIMediaProgressStateInit,
    AUIMediaProgressStateStarted,
    AUIMediaProgressStateFinishSucceed,
    AUIMediaProgressStateFinishFailed,
};

@interface AUIMediaProgressViewController : AVBaseViewController

- (instancetype)initWithHandle:(id<AUIMediaProgressProtocol>)handle;
@property (nonatomic, assign, readonly) AUIMediaProgressState state;
@property (nonatomic, copy)void (^onFinish)(UIViewController *current, NSError * _Nullable error,  id  _Nullable product);

@end

NS_ASSUME_NONNULL_END
