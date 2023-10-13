//
//  AUIVideoTemplateItem.m
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/12/14.
//

#import "AUIVideoTemplateItem.h"
#import "AUIFoundation.h"

@implementation AUIVideoTemplateItem

- (instancetype)initWithDict:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        _name = [dict av_stringValueForKey:@"name"];
        _info = [dict av_stringValueForKey:@"info"];
        _duration = [dict av_floatValueForKey:@"duration"];
        _url = [dict av_stringValueForKey:@"url"];
        _cover = [dict av_stringValueForKey:@"cover"];
        _zip = [dict av_stringValueForKey:@"zip"];
    }
    return self;
 }

@end
