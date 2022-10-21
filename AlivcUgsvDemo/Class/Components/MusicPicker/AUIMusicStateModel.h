//
//  AUIMusicStateModel.h
//  AlivcUgsvDemo
//
//  Created by coder.pi on 2022/6/8.
//

#import "AUIMusicModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, AUIMusicResourceState) {
    AUIMusicResourceStateNetwork,
    AUIMusicResourceStateDownloading,
    AUIMusicResourceStateLocal,
};

@class AUIMusicStateModel;
@protocol AUIMusicStateModelDelegate <NSObject>
- (void) onAUIMusicStateModel:(AUIMusicStateModel *)model didChangeState:(AUIMusicResourceState)state;
- (void) onAUIMusicStateModel:(AUIMusicStateModel *)model didChangeProgress:(float)progress;
@end

@interface AUIMusicStateModel : NSObject
@property (nonatomic, readonly) AUIMusicModel *music;
@property (nonatomic, readonly) AUIMusicResourceState state;
@property (nonatomic, readonly) float downloadProgress;
@property (nonatomic, readonly) NSString *musicLocalPath;
@property (nonatomic, readonly) NSTimeInterval duration;
@property (nonatomic, weak) id<AUIMusicStateModelDelegate> delegate;
- (instancetype) initWithMusic:(AUIMusicModel *)music;
- (void) download;
@end

NS_ASSUME_NONNULL_END
