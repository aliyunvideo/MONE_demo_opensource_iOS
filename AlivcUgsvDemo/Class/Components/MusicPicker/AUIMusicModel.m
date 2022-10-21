//
//  AUIMusicModel.m
//  AlivcUgsvDemo
//
//  Created by coder.pi on 2022/6/7.
//

#import "AUIMusicModel.h"

@implementation AUIMusicModel

- (instancetype) initWithDict:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        _musicId = dict[@"musicId"];
        _title = dict[@"title"];
        _artistName = dict[@"artistName"];
        _coverUrl = dict[@"image"];
        _duration = [dict[@"duration"] doubleValue];
        int dur = _duration;
        int sec = dur % 60;
        int min = dur / 60;
        _formatDuration = [NSString stringWithFormat:@"%02d:%02d", min, sec];
    }
    return self;
}

@end

@implementation AUIMusicSelectedModel
- (NSTimeInterval) duration {
    return self.endTime - self.beginTime;
}
@end
