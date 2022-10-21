//
//  AUIMediaPublisherProgress.h
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/6/13.
//

#import <Foundation/Foundation.h>
#import "AUIMediaPublisherInfo.h"
#import "AUIMediaProgressViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUIMediaPublisherProgress : NSObject <AUIMediaProgressProtocol>

- (instancetype)initWithRequestInfo:(AUIMediaPublisherRequestInfo *)requestInfo;
- (instancetype)initWithExportProgress:(id<AUIMediaProgressProtocol>)exportProgress withPublishRequestInfo:(AUIMediaPublisherRequestInfo *)requestInfo;

@end

NS_ASSUME_NONNULL_END
