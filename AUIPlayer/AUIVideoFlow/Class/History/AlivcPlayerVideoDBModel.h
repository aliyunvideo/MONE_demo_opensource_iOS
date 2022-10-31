//
//  AlivcPlayerVideoDBModel.h
//  ApsaraVideo
//
//  Created by mengyehao on 2021/7/13.
//

#import <Foundation/Foundation.h>



@interface AlivcPlayerVideoDBModel : NSObject

@property (nonatomic, copy) NSString *videoId;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *watchTime;
@property (nonatomic, assign) NSTimeInterval ts;
@property (nonatomic, assign) int64_t vaildTime; //存储有效时长，单位:秒, 默认30天

 
@end


