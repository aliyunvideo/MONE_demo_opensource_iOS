//
//  AUIPlayerWatchPointEntry.m
//  ApsaraVideo
//
//  Created by mengyehao on 2021/7/29.
//

#import "AUIPlayerWatchPointEntry.h"
#import "AlivcPlayerAsset.h"

@interface AUIPlayerWatchPointEntry()
@property (nonatomic) UIView *outView;
@property (nonatomic) UIView *centerView;

@end

@implementation AUIPlayerWatchPointEntry

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.outView];
        [self addSubview:self.centerView];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onViewClick:)];
        [self addGestureRecognizer:tapGesture];
    }
    return self;
}

- (void)onViewClick:(id)sender
{
    if (self.onViewBlock) {
        self.onViewBlock();
    }
}

- (UIView *)outView
{
    if (!_outView) {
        _outView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        _outView.accessibilityIdentifier = [self accessibilityId:@"outView"];
        _outView.backgroundColor = APGetColor(APColorTypeCyanBg);
        _outView.layer.cornerRadius = 5;
        _outView.clipsToBounds = YES;
        _outView.hidden = YES;
    }
    
    return _outView;
}

- (UIView *)centerView
{
    if (!_centerView) {
        _centerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 4, 4)];
        _centerView.accessibilityIdentifier = [self accessibilityId:@"centerView"];
        _centerView.backgroundColor = APGetColor(APColorTypeCCC);
        _centerView.layer.cornerRadius = 2;
        _centerView.clipsToBounds = YES;
    }
    
    return _centerView;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _centerView.center = _outView.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
}

- (NSString *)accessibilityId:(NSString *)key {
    NSString *name = NSStringFromClass([self class]);
    return [AUIVideoFlowAccessibilityStr(name) stringByAppendingString:key];
}

@end
