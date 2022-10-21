//
//  AUIMediaPublisherInfo.h
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/6/13.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AUIMediaPublisherRequestInfo : NSObject

@property (nonatomic, strong) NSString *desc;
@property (nonatomic, strong) NSString *coverImagePath;
@property (nonatomic, strong) NSString *videoFilePath;

@end

@interface AUIMediaPublisherResponseInfo : NSObject

@property (nonatomic, strong) NSString *videoId;
@property (nonatomic, strong) NSString *coverImageURL;

@end

NS_ASSUME_NONNULL_END
