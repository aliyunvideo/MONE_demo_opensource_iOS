//
//  AUIRecorderWrapper.h
//  AlivcUgsvDemo
//
//  Created by coder.pi on 2022/6/5.
//

#import <Foundation/Foundation.h>
#import "AUIRecorderCameraWrapper.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUIRecorderWrapper : NSObject
@property (nonatomic, readonly) AUIRecorderCameraWrapper *camera;
@end

NS_ASSUME_NONNULL_END
