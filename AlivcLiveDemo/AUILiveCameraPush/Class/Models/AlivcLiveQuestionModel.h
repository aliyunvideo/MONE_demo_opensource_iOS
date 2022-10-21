//
//  AlivcLiveQuestionModel.h
//  AlivcLivePusherTest
//
//  Created by lyz on 2018/1/22.
//  Copyright © 2018年 TripleL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AlivcLiveJSONModel.h"

@interface AlivcLiveQuestionModel : AlivcLiveJSONModel

@property (nonatomic, copy) NSString *questionId;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *content;

@end
