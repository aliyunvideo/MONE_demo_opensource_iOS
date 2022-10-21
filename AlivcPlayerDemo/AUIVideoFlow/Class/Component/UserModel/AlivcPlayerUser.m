//
//  AlivcPlayerUser.m
//  ApsaraVideo
//
//  Created by Bingo on 2021/7/5.
//

#import "AlivcPlayerUser.h"
#import "AlivcPlayerFoundation.h"

@implementation AlivcPlayerUser

- (instancetype)initWithDict:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.userId = [dict av_intValueForKey:@"userId"];
        self.userName = [dict av_stringValueForKey:@"userName"];
        self.avatarUrl = [dict av_stringValueForKey:@"avatarUrl"];
    }
    return self;
}

@end
