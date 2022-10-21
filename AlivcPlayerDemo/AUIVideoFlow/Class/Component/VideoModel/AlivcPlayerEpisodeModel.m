//
//  AlivcPlayerEpisodeModel.m
//  ApsaraVideo
//
//  Created by mengyehao on 2021/7/22.
//

#import "AlivcPlayerEpisodeModel.h"

@implementation AlivcPlayerEpisodeModel

- (instancetype)initWithDict:(NSDictionary *)dict
{
    self = [super initWithDict:dict];
    if (self) {
        self.episodeId = [[dict objectForKey:@"episodeId"] longLongValue];
        self.parentVodId = [[dict objectForKey:@"parentVodId"] longLongValue];
        self.episodeId = [[dict objectForKey:@"episodeNum"] integerValue];

    }
    return self;
}
@end
