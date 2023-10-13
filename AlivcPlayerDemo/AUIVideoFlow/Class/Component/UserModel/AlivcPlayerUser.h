//
//  AlivcPlayerUser.h
//  ApsaraVideo
//
//  Created by Bingo on 2021/7/5.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AlivcPlayerUser : NSObject

@property (nonatomic, assign) int userId;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *avatarUrl;

- (instancetype)initWithDict:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
