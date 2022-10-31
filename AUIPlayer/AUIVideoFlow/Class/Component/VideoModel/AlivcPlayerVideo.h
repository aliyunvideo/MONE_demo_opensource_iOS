//
//  AlivcPlayerVideo.h
//  ApsaraVideo
//
//  Created by Bingo on 2021/7/5.
//

#import <Foundation/Foundation.h>
#import "AlivcPlayerUser.h"

NS_ASSUME_NONNULL_BEGIN

@interface AlivcPlayerVideo : NSObject

@property (nonatomic, strong) NSUUID *uuid;

@property (nonatomic, copy) NSString *videoId;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *fileUrl;
@property (nonatomic, copy) NSString *coverUrl;

@property (nonatomic, assign) int vodId;
@property (nonatomic, assign) float duration;
@property (nonatomic, assign) int width;
@property (nonatomic, assign) int height;
@property (nonatomic, assign) long publishTime;

@property (nonatomic, assign) int cateId;
@property (nonatomic, copy) NSString *cateName;

@property (nonatomic, strong) AlivcPlayerUser *user;

@property (nonatomic, assign) int commentCount;
@property (nonatomic, assign) int likeCount;
@property (nonatomic, assign) int viewCount;

@property (nonatomic, assign) long cursor;


- (instancetype)initWithDict:(NSDictionary *)dict;


@end

NS_ASSUME_NONNULL_END
