//
//  AUIEditorTimelineTitleLoader.m
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/6/17.
//

#import "AUIEditorTimelineTitleLoader.h"
#import "AUIUgsvMacro.h"

@implementation AUIEditorTimelineTitleView

@synthesize textView = _textView;
@synthesize imageView = _imageView;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (UILabel *)textView {
    if (!_textView) {
        _textView = [[UILabel alloc] initWithFrame:self.bounds];
        _textView.font = AVGetRegularFont(10);
        _textView.textColor = AUIFoundationColor(@"text_strong");
        [self addSubview:_textView];
    }
    return _textView;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.av_height, self.av_height)];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_imageView];
    }
    return _imageView;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (_textView) {
        [_textView sizeToFit];
        if (CGRectEqualToRect(self.textFrame, CGRectZero)) {
            _textView.frame = UIEdgeInsetsInsetRect(self.bounds, self.textInsets);
        }
        else {
            _textView.frame = self.textFrame;
        }
    }
    if (_imageView) {
        CGRect rect = CGRectMake(0, 0, self.av_height, self.av_height);
        rect = UIEdgeInsetsInsetRect(rect, self.imageInsets);
        _imageView.frame = rect;
    }
}

+ (AUIEditorTimelineTitleView *)textView:(NSString *)title {
    AUIEditorTimelineTitleView *view = [AUIEditorTimelineTitleView new];
    view.textView.text = title;
    view.textInsets = UIEdgeInsetsMake(0, 4, 0, 4);
    return view;
}

+ (AUIEditorTimelineTitleView *)imageView:(NSString *)path {
    AUIEditorTimelineTitleView *view = [AUIEditorTimelineTitleView new];
    view.imageView.image = [[UIImage alloc] initWithContentsOfFile:path];
    view.imageInsets = UIEdgeInsetsMake(0, 4, 0, 4);
    return view;
}

+ (AUIEditorTimelineTitleView *)videoDurationView:(NSTimeInterval)duration {
    AUIEditorTimelineTitleView *view = [AUIEditorTimelineTitleView new];
    view.textView.text = [NSString stringWithFormat:@"%.2fs", duration];
    view.textView.backgroundColor = AUIFoundationColor(@"tsp_fill_medium");
    view.textView.textAlignment = NSTextAlignmentCenter;
    [view.textView sizeToFit];
    view.textFrame = CGRectMake(4, 4, view.textView.av_width + 4, view.textView.av_height);
    view.layer.cornerRadius = 4.0;
    return view;
}

@end

@implementation AUIEditorTimelineTitleLoader

-(instancetype)initWithTitleView:(AUIEditorTimelineTitleView *)titleView {
    self = [super init];
    if (self) {
        _titleView = titleView;
    }
    return self;
}

- (UIView *)loadTitleView {
    return _titleView;
}

@end
