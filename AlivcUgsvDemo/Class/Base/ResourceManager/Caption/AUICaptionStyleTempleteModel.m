//
//  AUICaptionStyleTempleteModel.m
//  AlivcUgsvDemo
//
//  Created by mengyehao on 2022/6/20.
//

#import "AUICaptionStyleTempleteModel.h"
#import "UIColor+AVHelper.h"

@implementation AUICaptionStyleTempleteModel


- (instancetype)initWithResourcePath:(NSString *)resourcePath {
    self = [super initWithResourcePath:resourcePath];
    if (self) {
        NSString  *dataPath = [resourcePath stringByAppendingPathComponent:@"config.json"];
        NSData *jsonData = [NSData dataWithContentsOfFile:dataPath];
        NSDictionary *data = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:nil];
        if ([data[@"color"] isKindOfClass:NSString.class]) {
            self.color = [UIColor av_colorWithHexString:data[@"color"]];
        }
        
        if ([data[@"bgcolor"] isKindOfClass:NSString.class]) {
            self.bgColor = [UIColor av_colorWithHexString:data[@"bgcolor"]];
        }
        
        if ([data[@"outline"] isKindOfClass:NSDictionary.class]) {
            
            if ([data[@"outline"][@"color"] isKindOfClass:NSString.class]) {
                self.outlineColor = [UIColor av_colorWithHexString:data[@"outline"][@"color"]];
            }
            
            if ([data[@"outline"][@"width"] isKindOfClass:NSString.class] || [data[@"outline"][@"width"] isKindOfClass:NSNumber.class]) {
                self.outlineWidth = [data[@"outline"][@"width"] floatValue];
            }
        }
        
        if ([data[@"shadow"] isKindOfClass:NSDictionary.class]) {
            
            if ([data[@"shadow"][@"color"] isKindOfClass:NSString.class]) {
                self.outlineColor = [UIColor av_colorWithHexString:data[@"shadow"][@"color"]];
            }
            
            NSString *temp_x = data[@"shadow"][@"x"];
            NSString *temp_y = data[@"shadow"][@"y"];
            
            self.shadowOffset = (UIOffset) {[temp_x floatValue],[temp_y floatValue]};
        }

    }
    return self;
}

+ (AUIResourceModel *)EmptyModel
{
    AUICaptionStyleTempleteModel *model = [[AUICaptionStyleTempleteModel alloc] init];
    model.color = [UIColor whiteColor];
    model.shadowColor = [UIColor clearColor];
    model.shadowOffset = UIOffsetZero;
    model.outlineColor = [UIColor clearColor];
    model.outlineWidth = 0;

    return model;
    
}


@end
