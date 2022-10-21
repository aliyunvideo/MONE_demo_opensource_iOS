//
//  AUIVideoListModel.h
//  AUIVideoList
//
//  Created by zzy on 2022/5/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AUIVideoListModel : NSObject

@property (nonatomic,copy)NSString *user;
@property (nonatomic,copy)NSString *title;
@property (nonatomic,copy)NSString *url;
@property (nonatomic,copy)NSString *coverURL;
@property (nonatomic,assign)NSInteger index;

@end

NS_ASSUME_NONNULL_END
