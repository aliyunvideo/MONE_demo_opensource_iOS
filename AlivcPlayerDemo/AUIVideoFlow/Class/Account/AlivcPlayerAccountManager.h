//
//  AlivcPlayerAccountManager.h
//  ApsaraVideo
//
//  Created by mengyehao on 2021/7/14.
//

#import <Foundation/Foundation.h>



@interface AlivcPlayerAccountManager : NSObject

@property (nonatomic, copy, readonly) NSString *currentUserId;

+ (instancetype)manager;


@end

