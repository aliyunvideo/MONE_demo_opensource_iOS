//
//  AUIVideoParamBuilder.m
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/6/30.
//

#import "AUIVideoParamBuilder.h"

@implementation AUIBitrateConverter

- (id)fromParamToValue:(id)param {
    return @(((NSNumber *)param).intValue * 1024);
}

- (id)fromValueToParam:(id)value {
    return @(((NSNumber *)value).intValue / 1024);
}

@end

@implementation AUIVideoParamBuilder

@end
