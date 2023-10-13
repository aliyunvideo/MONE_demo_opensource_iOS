//
//  AUIVideoTemplateItem.h
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/12/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AUIVideoTemplateItem : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, copy) NSString *info;
@property (nonatomic, copy) NSString *cover;
@property (nonatomic, copy) NSString *zip;
@property (nonatomic, copy) NSString *url;

- (instancetype)initWithDict:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
