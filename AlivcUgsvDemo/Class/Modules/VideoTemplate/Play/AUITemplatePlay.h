//
//  AUITemplatePlay.h
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/9/23.
//

#import <Foundation/Foundation.h>
#import "AUIVideoPlayProtocol.h"
#import "AlivcUgsvSDKHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUITemplatePlay : NSObject<AUIVideoPlayProtocol>

- (instancetype)initWithEditor:(AliyunAETemplateEditor *)editor;

@end

NS_ASSUME_NONNULL_END
