//
//  JSONModel.m
//  QupaiSDK
//
//  Created by yly on 15/6/26.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AlivcLiveJSONModel.h"
#import <objc/runtime.h>

@implementation AlivcLiveJSONModel

#pragma mark - dic to model

- (instancetype)initWithDictionary:(NSDictionary *)dic
{
    self = [super init];
    if (self) {
        [self setValuesForKeysWithDictionary:dic];
    }
    return [self customInit:dic];
}

- (instancetype)customInit:(NSDictionary *)dic
{
    return self;
}

#pragma mark - model to dic

- (NSDictionary *)toDictionary
{
    unsigned int count = 0;
    objc_property_t *property = class_copyPropertyList([self class], &count);
    NSMutableArray *propertyArray = [NSMutableArray arrayWithCapacity:4];
    for (unsigned int i = 0; i < count; ++i) {
        const char * name = property_getName(property[i]);
        const char * attributes = property_getAttributes(property[i]);
        
        NSString *nameStr = [NSString stringWithUTF8String:name];
        NSString *attrStr = [NSString stringWithUTF8String:attributes];
        if (![attrStr hasPrefix:@"T{"] && [self valueForKey:nameStr]) {
            [propertyArray addObject:nameStr];
        }
    }
    NSDictionary *dict = [self dictionaryWithValuesForKeys:propertyArray];
    free(property);
    return [self customToDictionary:dict];
}

- (NSString *)toString {
    
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[self toDictionary] options:NSJSONWritingPrettyPrinted error:&parseError];
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

- (NSDictionary *)customToDictionary:(NSDictionary *)dict
{
    return dict;
}

#pragma mark - file

- (instancetype)initWithFile:(NSString *)path
{
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSError *error = nil;
    if (!data) {
        return [self initWithDictionary:nil];
    }
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    return [self initWithDictionary:json];
}

- (void)jsonToFile:(NSString *)path
{
    NSDictionary *json = [self toDictionary];
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:&error];
    [data writeToFile:path atomically:YES];
}

@end
