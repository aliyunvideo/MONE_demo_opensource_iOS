//
//  AlivcPlayerVideo.m
//  ApsaraVideo
//
//  Created by Bingo on 2021/7/5.
//

#import "AlivcPlayerVideo.h"
#import "AlivcPlayerFoundation.h"

@implementation AlivcPlayerVideo

- (instancetype)initWithDict:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.uuid = [NSUUID UUID];
        self.videoId = [dict av_stringValueForKey:@"videoId"];
        self.title = [dict av_stringValueForKey:@"title"];
        self.fileUrl = [dict av_stringValueForKey:@"fileUrl"];
        self.coverUrl = [dict av_stringValueForKey:@"coverUrl"];
        
        self.vodId = [dict av_intValueForKey:@"vodId"];
        self.duration = [dict av_floatValueForKey:@"duration"];
        self.width = [dict av_intValueForKey:@"width"];
        self.height = [dict av_intValueForKey:@"height"];
        self.publishTime = [dict av_longValueForKey:@"publishTime"];
        
        self.cateId = [dict av_intValueForKey:@"cateId"];
        self.cateName = [dict av_stringValueForKey:@"cateName"];

        self.user = [[AlivcPlayerUser alloc] initWithDict:[dict av_dictionaryValueForKey:@"user"]];
        
        self.commentCount = [dict av_intValueForKey:@"commentCount"];
        self.likeCount = [dict av_intValueForKey:@"likeCount"];
        self.viewCount = [dict av_intValueForKey:@"viewCount"];
        
        self.cursor = [dict av_longValueForKey:@"weight"];
    }
    return self;
}

@end
