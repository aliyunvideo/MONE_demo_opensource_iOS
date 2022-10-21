//
//  AUIAsyncImageGeneratorProtocol.h
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/6/4.
//

#ifndef AUIAsyncImageGeneratorProtocol_h
#define AUIAsyncImageGeneratorProtocol_h

#import <UIKit/UIKit.h>

@protocol AUIAsyncImageGeneratorProtocol <NSObject>

- (void)generateImagesAsynchronouslyForTimes:(NSArray *)times duration:(NSTimeInterval)duration completed:(void (^)(NSTimeInterval, UIImage *))completed;

@end

#endif /* AUIAsyncImageGeneratorProtocol_h */
