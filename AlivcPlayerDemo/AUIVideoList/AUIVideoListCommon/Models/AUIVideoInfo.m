//
//  AUIVideoInfo.m
//  AUIVideoList
//
//  Created by zzy on 2022/5/25.
//

#import "AUIVideoInfo.h"
#import "AUIFoundation.h"

@implementation AUIVideoInfo

- (instancetype)initWithDict:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.videoId = [dict av_intValueForKey:@"videoId"];
        self.url = [dict av_stringValueForKey:@"url"];
        self.duration = (NSTimeInterval)([dict av_longValueForKey:@"videoDuration"] / 1000.0);
        self.coverUrl = [dict av_stringValueForKey:@"coverUrl"];
        self.author = [dict av_stringValueForKey:@"author"];
        self.title = [dict av_stringValueForKey:@"title"];
        self.videoPlayCount = [dict av_intValueForKey:@"videoPlayCount"];
        self.likeCount = [dict av_intValueForKey:@"likeCount"];
        self.isLiked = [dict av_boolValueForKey:@"isLiked"];
        self.commentCount = [dict av_intValueForKey:@"commentCount"];
        self.shareCount = [dict av_intValueForKey:@"shareCount"];
    }
    return self;
}

@end
