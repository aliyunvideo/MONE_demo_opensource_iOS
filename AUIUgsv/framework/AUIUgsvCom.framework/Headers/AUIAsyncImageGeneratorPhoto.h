//
//  AUIAsyncImageGeneratorPhoto.h
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/6/4.
//

#import "AUIAsyncImageGeneratorProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUIAsyncImageGeneratorPhoto : NSObject<AUIAsyncImageGeneratorProtocol>

- (instancetype)initWithPath:(NSString *)filePath;

@end

NS_ASSUME_NONNULL_END
