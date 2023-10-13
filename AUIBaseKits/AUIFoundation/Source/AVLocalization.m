//
//  AVLocalization.m
//  ApsaraVideo
//
//  Created by Bingo on 2021/6/30.
//

#import "AVLocalization.h"

@interface AVLocalization ()

@property (nonatomic, strong) NSMutableDictionary<NSString *, NSBundle *> *moduleBundleMap;

@end

@implementation AVLocalization

- (instancetype)init {
    self = [super init];
    if (self) {
        self.moduleBundleMap = [NSMutableDictionary dictionary];
    }
    return self;
}

- (NSBundle *)addModule:(NSString *)module {
    NSBundle *bundle = [self.moduleBundleMap objectForKey:module];
    if (bundle) {
        return bundle;
    }
    
    NSString *path = [NSBundle.mainBundle.resourcePath stringByAppendingPathComponent:[module stringByAppendingString:@".bundle/Localization"]];
    bundle = [NSBundle bundleWithPath:path];
    [self.moduleBundleMap setObject:bundle forKey:module];
    return bundle;
}

+ (AVLocalization *)shared {
    static AVLocalization *_global = nil;
    if (!_global) {
        _global = [AVLocalization new];
    }
    
    return _global;
}

+ (NSString *)stringWithKey:(NSString *)key withModule:(NSString *)module {
    NSBundle *bundle = [[self shared] addModule:module];
    return NSLocalizedStringFromTableInBundle(key, nil, bundle, nil);
}

@end
