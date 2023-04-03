//
//  AUIVideoInfo.h
//  AUIVideoList
//
//  Created by zzy on 2022/5/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AUIVideoInfo : NSObject

/// 播放源url
@property (nonatomic,copy)NSString *url;
/// 作者
@property (nonatomic,copy)NSString *author;
/// 标题
@property (nonatomic,copy)NSString *title;
/// 占位图，可以不设置
@property (nonatomic,copy)NSString *coverURL;
/// 数据源标识。AliListPlayer时需要，保持唯一，可以自动生成随机数。
@property (nonatomic,copy)NSString *uid;

@end

NS_ASSUME_NONNULL_END
