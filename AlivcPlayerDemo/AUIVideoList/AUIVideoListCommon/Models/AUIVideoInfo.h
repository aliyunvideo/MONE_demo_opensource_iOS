//
//  AUIVideoInfo.h
//  AUIVideoList
//
//  Created by zzy on 2022/5/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AUIVideoInfo : NSObject

/// 唯一标识
@property(nonatomic, assign) int videoId;

/// 播放源url
@property (nonatomic, copy) NSString *url;

/// 时长
@property(nonatomic, assign) NSTimeInterval duration;

/// 占位图，可以不设置
@property (nonatomic, copy, nullable) NSString *coverUrl;

/// 作者
@property (nonatomic, copy, nullable) NSString *author;

/// 标题
@property (nonatomic, copy, nullable) NSString *title;

/// 播放次数
@property(nonatomic, assign) int videoPlayCount;

/// 是否被点赞
@property(nonatomic, assign) int isLiked;

/// 点赞数
@property(nonatomic, assign) int likeCount;

/// 评论数
@property(nonatomic, assign) int commentCount;

/// 分享数
@property(nonatomic, assign) int shareCount;

/// 数据源标识。AliListPlayer时需要，保持唯一，可以自动生成随机数。
@property (nonatomic, copy, nullable) NSString *uid;


- (instancetype)initWithDict:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
