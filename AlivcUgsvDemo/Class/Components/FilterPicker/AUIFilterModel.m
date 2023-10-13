//
//  AUIFilterModel.m
//  AlivcUgsvDemo
//
//  Created by coder.pi on 2022/6/6.
//

#import "AUIFilterModel.h"
#import "AUIUgsvMacro.h"

@implementation AUIFilterModel

- (instancetype) init {
    self = [super init];
    if (self) {
        _name = AUIUgsvGetString(@"原始");
    }
    return self;
}

- (instancetype)initWithResourcePath:(NSString *)resourcePath {
    self = [super initWithResourcePath:resourcePath];
    if (self) {
        _name = resourcePath.lastPathComponent;
    }
    return self;
}

- (BOOL) isEqual:(id)object {
    if (![super isEqual:object]) {
        return NO;
    }
    
    AUIFilterModel *other = (AUIFilterModel *)object;
    if (![other isKindOfClass:AUIFilterModel.class]) {
        return NO;
    }
    
    return [self.name isEqualToString:other.name];
}
@end
