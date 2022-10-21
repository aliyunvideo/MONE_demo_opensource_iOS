//
//  AUIVideoListConfig.m
//  AUIVideoList
//
//  Created by ISS013602000846 on 2022/6/13.
//

#import "AUIVideoListConfig.h"
#import "AUIVideoListTool.h"

@implementation AUIVideoListConfig

- (void)didFinishLaunching {
    AUIVideoListTool *tool = [[AUIVideoListTool alloc] init];
    [tool setDefalutCache];
}

@end
