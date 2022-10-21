//
//  AUIMusicModel.h
//  AlivcUgsvDemo
//
//  Created by coder.pi on 2022/6/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AUIMusicModel : NSObject
@property (nonatomic, readonly) NSString *musicId;
@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSString *artistName;
@property (nonatomic, readonly) NSString *coverUrl;
@property (nonatomic, readonly) NSTimeInterval duration;
@property (nonatomic, readonly) NSString *formatDuration;
- (instancetype) initWithDict:(NSDictionary *)dict;
@end

@interface AUIMusicSelectedModel : NSObject
@property (nonatomic, strong) AUIMusicModel *music;
@property (nonatomic, copy) NSString *localPath;
@property (nonatomic, assign) NSTimeInterval beginTime;
@property (nonatomic, assign) NSTimeInterval endTime;
@property (nonatomic, readonly) NSTimeInterval duration;
@end

NS_ASSUME_NONNULL_END
