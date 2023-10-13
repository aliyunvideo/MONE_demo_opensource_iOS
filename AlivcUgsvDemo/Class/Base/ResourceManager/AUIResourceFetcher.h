//
//  AUIResourceFetcher.h
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/7/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AUIResourceFetcher : NSObject

+ (AUIResourceFetcher *)defaultFetcher;
+ (NSString *)resourceTypeName;


@end

NS_ASSUME_NONNULL_END
