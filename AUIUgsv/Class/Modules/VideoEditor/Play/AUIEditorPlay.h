//
//  AUIEditorPlay.h
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/6/8.
//

#import <Foundation/Foundation.h>
#import "AUIVideoPlayProtocol.h"
#import "AlivcUgsvSDKHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUIEditorPlay : NSObject<AUIVideoPlayProtocol>

- (instancetype)initWithEditor:(AliyunEditor *)editor;

@property (nonatomic, assign) CGFloat speed;
@property (nonatomic, assign) NSTimeInterval rangePlayOffset;

@end

NS_ASSUME_NONNULL_END
