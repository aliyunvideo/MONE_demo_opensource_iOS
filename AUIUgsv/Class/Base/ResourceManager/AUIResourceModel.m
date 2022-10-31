//
//  AUIResourceModel.m
//  AlivcUgsvDemo
//
//  Created by coder.pi on 2022/6/6.
//

#import "AUIResourceModel.h"

@implementation AUIResourceModel

- (instancetype)initWithResourcePath:(NSString *)resourcePath {
    self = [super init];
    if (self) {
        resourcePath = resourcePath.stringByResolvingSymlinksInPath;
        _resourcePath = resourcePath;
        _iconPath = [resourcePath stringByAppendingPathComponent:@"icon.png"];
    }
    return self;
}

- (BOOL) isEmpty {
    return (self.resourcePath.length == 0);
}

+ (instancetype) EmptyModel {
    return [self new];
}

- (BOOL) isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    
    AUIResourceModel *other = (AUIResourceModel *)object;
    if (![other isKindOfClass:AUIResourceModel.class]) {
        return NO;
    }
    if (self.isEmpty != other.isEmpty) {
        return NO;
    }
    if (self.isEmpty && other.isEmpty) {
        return YES;
    }
    return [self.resourcePath isEqualToString:other.resourcePath];
}

@end
