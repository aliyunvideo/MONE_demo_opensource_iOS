//
//  AUIVideoTemplateExport.h
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/10/12.
//

#import <UIKit/UIKit.h>
#import "AUIMediaProgressViewController.h"
#import "AUIVideoTemplateOutputParam.h"
#import "AlivcUgsvSDKHeader.h"


NS_ASSUME_NONNULL_BEGIN

@interface AUIVideoTemplateExport : NSObject <AUIMediaProgressProtocol>

- (instancetype)initWithEditor:(AliyunAETemplateEditor *)editor outputParam:(nullable AUIVideoTemplateOutputParam *)param;


@end

NS_ASSUME_NONNULL_END
