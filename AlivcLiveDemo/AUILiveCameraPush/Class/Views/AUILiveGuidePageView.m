//
//  AUILiveGuidePageView.m
//  AlivcLivePusherTest
//
//  Created by lyz on 2017/10/18.
//  Copyright © 2017年 TripleL. All rights reserved.
//

#import "AUILiveGuidePageView.h"

@implementation AUILiveGuidePageView


- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubViews];
    }
    return self;
}


- (void)setupSubViews {
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:AUILiveCameraPushImage(@"Line")];
    imageView.frame = CGRectMake(self.bounds.size.width/4, 0, self.bounds.size.width/2, self.bounds.size.height / 2);
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:imageView];
    
    UILabel *leftLabel = [[UILabel alloc] init];
    leftLabel.frame = CGRectMake(0, self.bounds.size.height / 2, self.bounds.size.width / 2, self.bounds.size.height / 2);
    leftLabel.text = AUILiveCameraPushString(@"右滑查看log");
    leftLabel.textAlignment = NSTextAlignmentLeft;
    leftLabel.textColor = [UIColor whiteColor];
    
    [self addSubview:leftLabel];
    
    UILabel *rightLabel = [[UILabel alloc] init];
    rightLabel.frame = CGRectMake(self.bounds.size.width / 2, self.bounds.size.height / 2, self.bounds.size.width / 2, self.bounds.size.height / 2);
    rightLabel.text = AUILiveCameraPushString(@"左滑查看log图表");
    rightLabel.textAlignment = NSTextAlignmentRight;
    rightLabel.textColor = [UIColor whiteColor];
    
    [self addSubview:rightLabel];
}


@end
