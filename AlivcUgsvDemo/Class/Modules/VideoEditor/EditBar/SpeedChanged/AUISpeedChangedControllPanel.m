//
//  AUISpeedChangedControllPanel.m
//  AlivcUgsvDemo
//
//  Created by mengyehao on 2022/6/2.
//

#import "AUISpeedChangedControllPanel.h"
#import "UIView+AVHelper.h"
#import "AUIFoundation.h"
#import "AUIUgsvMacro.h"
#import "AUIPanelStatusButtonView.h"

static const int kBig_num = 4;

static const int klittle_num = 10;


@interface AUITextButton : UIButton
@property (nonatomic, assign) CGSize customImageSize;
@property (nonatomic, assign) CGFloat imageLeft;
@property (nonatomic, assign) CGFloat paddingX;


@end

@implementation AUITextButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.titleLabel.font = AVGetRegularFont(12);
        [self setTitleColor:AUIFoundationColor(@"text_strong") forState:UIControlStateNormal];
        _customImageSize = CGSizeMake(12, 12);
        _imageLeft = 8;
        _paddingX = 4;

    }
    return self;
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
    CGSize size = _customImageSize;
    return CGRectMake(_imageLeft, (contentRect.size.height - size.height) /2, size.width, size.height);
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect
{
    CGRect imageRect = [self imageRectForContentRect:contentRect];
    CGRect textRect = [super titleRectForContentRect:contentRect];

    
    return CGRectMake(CGRectGetMaxX(imageRect) + _paddingX, (contentRect.size.height - textRect.size.height)/2, contentRect.size.width - (CGRectGetMaxX(imageRect) + _paddingX) - _imageLeft, textRect.size.height);
}

- (void)sizeToFit
{
    [super sizeToFit];
    [self.titleLabel sizeToFit];
    self.av_width = _imageLeft * 2 + _paddingX + self.titleLabel.av_width + self.imageView.av_width;
}

@end


@interface AUISpeedChangedControllPanel()
@property (nonatomic, strong) UIView *rulerView;
@property (nonatomic, strong) UIView *flagView;
@property (nonatomic, assign) float curentValue;
@property (nonatomic, strong) UILabel *showLabel;
@property (nonatomic, strong) UIButton *resetButton;
@property (nonatomic, assign) BOOL shouldCallBack;


@end

@implementation AUISpeedChangedControllPanel

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.showBackButton = YES;
        [self setupUI];
    }
    return self;
}

+ (CGFloat)panelHeight
{
    return 240 + AVSafeBottom;
}


- (UIButton *)resetButton
{
    if (!_resetButton) {
        _resetButton = [[UIButton alloc] init];
        [_resetButton  addTarget:self action:@selector(onResetButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [_resetButton setTitle:AUIUgsvGetString(@"Reset") forState:UIControlStateNormal];
        [_resetButton setImage:AUIUgsvEditorImage(@"ic_reset")  forState:UIControlStateNormal];
        _resetButton.titleLabel.font = AVGetRegularFont(12);
        [_resetButton sizeToFit];

    }
    return _resetButton;
}



- (UILabel *)showLabel
{
    if (!_showLabel) {
        _showLabel = [UILabel new];
        _showLabel.font = AVGetRegularFont(12);
        _showLabel.textColor = AUIFoundationColor(@"text_strong");
        _showLabel.hidden = YES;
        [self.rulerView addSubview:_showLabel];

    }
    return _showLabel;
}

- (void)setupUI
{
    CGFloat marginX = 20.f;
        
    self.titleView.text = AUIUgsvGetString(@"Change speed");
    _rulerView  = [[UIView alloc] initWithFrame:CGRectMake(marginX, 45, self.av_width - marginX *2, 38)];
    [self.contentView addSubview:_rulerView];
    
    
    int big_num = kBig_num;
    int  little_num = klittle_num;
    
    
    CGFloat padding = (_rulerView.av_width - (big_num * (little_num - 1) - 1) - (big_num + 1) *2)/ ((big_num * little_num) - 1);
    
    CGFloat left = 0;
    for (int i = 1; i < big_num * little_num + 1; i++) {
        UIView *line = [UIView new];
        [_rulerView addSubview:line];
        if (i % little_num  == 0 || i == 1) {
            line.frame  = CGRectMake(left, 0, 2, 12);
            line.backgroundColor =  AUIFoundationColor(@"text_strong");
            UILabel *label = [UILabel new];
            label.font = AVGetRegularFont(12);
            label.textColor = AUIFoundationColor(@"text_strong");
         
            if (i / little_num == 0) {
                label.text = @"0.5x";
            } else if (i / little_num == 1) {
                label.text = @"0.75x";
            } else if (i / little_num == 2) {
                label.text = @"1x";
            } else if (i / little_num == 3) {
                label.text = @"1.5x";
            } else if (i / little_num == 4) {
                label.text = @"2x";
            }
            
            [label sizeToFit];
            [_rulerView addSubview:label];
            label.center = CGPointMake(line.center.x, _rulerView.av_height - label.av_height/2);
            
            
        } else {
            line.frame  = CGRectMake(left, 3, 1, 6);
            line.backgroundColor =  AUIFoundationColor(@"border_weak");

        }
        left = line.av_right + padding;
    }
    
    _flagView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 12)];
    _flagView.backgroundColor = AUIFoundationColor(@"text_strong");
    _flagView.layer.cornerRadius = 6;
    [self.rulerView addSubview:_flagView];
    [self reset];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onTap:)];
    [_rulerView addGestureRecognizer:tap];
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(onPan:)];
    [_rulerView addGestureRecognizer:pan];
    [tap requireGestureRecognizerToFail:pan];
        

    self.resetButton.av_height = 24.f;
    self.resetButton.av_left = 30.f;
    self.resetButton.av_top = self.rulerView.av_bottom + 48.f;
    [self.contentView addSubview:self.resetButton];

    
}

- (void)onTap:(UITapGestureRecognizer *)gesture
{
     if (gesture.state == UIGestureRecognizerStateCancelled || gesture.state == UIGestureRecognizerStateEnded) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideShowLabel) object:nil];
        self.showLabel.hidden = NO;
        CGPoint point = [gesture locationInView:gesture.view];
        [self updateValueWithPoint:point];
        [self callOnValueChangedIfNeed];
        [self performSelector:@selector(hideShowLabel) withObject:nil afterDelay:0.5];
    }
    
}

- (void)onPan:(UIPanGestureRecognizer *)gesture
{
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideShowLabel) object:nil];
        self.showLabel.hidden = NO;
    } else if (gesture.state == UIGestureRecognizerStateChanged) {
        
        CGPoint point = [gesture locationInView:gesture.view];
        [self updateValueWithPoint:point];
        
    } else if (gesture.state == UIGestureRecognizerStateCancelled || UIGestureRecognizerStateEnded) {
        [self callOnValueChangedIfNeed];
        [self performSelector:@selector(hideShowLabel) withObject:nil afterDelay:0.5];
    }

}

- (void)hideShowLabel
{
    self.showLabel.hidden = YES;
}

- (void)updateValueWithPoint:(CGPoint)point
{

    _flagView.center = CGPointMake(point.x, _flagView.center.y);
    CGFloat value = _flagView.center.x/_rulerView.av_width;
    
    float total = klittle_num * kBig_num - 1;
    value = value * total;
    int line = round(value);
    line = MIN(line, 39);
    line = MAX(line, 0);

    _flagView.center = CGPointMake(line/total * _rulerView.av_width, _flagView.center.y);

    if (line >= 29.0) {
        self.curentValue = 1.5 +  (line - 29.0) * 0.05;
    } else if (value >= 19) {
        self.curentValue = 1 +  (line - 19) * 0.05;
    } else if (value >= 9) {
        self.curentValue = 0.75 +  (line - 9) * 0.025;
    } else {
        self.curentValue = 0.5 + line * 0.025;
    }
}

- (int)getCurrentLine
{
    int line = 0;
    if (self.curentValue > 1.5) {
        line =  (self.curentValue - 1.5) / 0.05 + 29;
    } else if (self.curentValue > 1) {
        line =  (self.curentValue - 1.0) / 0.05 + 19;
    } else if (self.curentValue > 0.75) {
        line =  (self.curentValue - 0.75) / 0.025 + 9;
    } else {
        line =  (self.curentValue - 0.5) / 0.025;
    }
    return line;
}

- (void)setCurentValue:(float)curentValue
{
    
    if (curentValue > 2 || curentValue < 0.5) {
        return;
    }
    
    if (_curentValue != curentValue) {
        _curentValue = curentValue;
        
        self.showLabel.text = [NSString stringWithFormat:@"%.3fx",self.curentValue];
        [self.showLabel sizeToFit];
        float total = klittle_num * kBig_num - 1;
        self.flagView.center = CGPointMake([self getCurrentLine]/total * _rulerView.av_width, _flagView.center.y);
        self.showLabel.center = CGPointMake(self.flagView.center.x, self.flagView.center.y - 16);
        self.shouldCallBack = YES;
        
    }
}

- (void)reset
{
    _flagView.center = CGPointMake(19.0/39.0 * self.rulerView.av_width, _flagView.center.y);
    self.curentValue = 1;
    [self callOnValueChangedIfNeed];

}

- (void)onResetButtonClick:(id)sender
{
    [self reset];
}


- (void)updateCurentValue:(float)value
{
    self.curentValue = value;
    [self callOnValueChangedIfNeed];
}

- (void)callOnValueChangedIfNeed
{
    if (self.shouldCallBack && self.onValueChanged) {
        self.shouldCallBack = NO;
        self.onValueChanged(_curentValue);
    }
}
@end
