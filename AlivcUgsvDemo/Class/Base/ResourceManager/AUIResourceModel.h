//
//  AUIResourceModel.h
//  AlivcUgsvDemo
//
//  Created by coder.pi on 2022/6/6.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AUIResourceModel : NSObject
@property (nonatomic, readonly) NSString *resourcePath;
@property (nonatomic, readonly) NSString *iconPath;
@property (nonatomic, readonly) BOOL isEmpty;
- (instancetype)initWithResourcePath:(NSString *)resourcePath;
+ (instancetype) EmptyModel;
@end

NS_ASSUME_NONNULL_END
