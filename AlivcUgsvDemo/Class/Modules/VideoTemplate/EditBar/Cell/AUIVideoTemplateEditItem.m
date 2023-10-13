//
//  AUIVideoTemplateEditItem.m
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/12/22.
//

#import "AUIVideoTemplateEditItem.h"
#import "AUIUgsvMacro.h"

@interface AUIVideoTemplateEditItemMedia ()

@property (nonatomic, strong) UIImage *defaultCover;
@property (nonatomic, copy) NSString *templatePath;

@end

@implementation AUIVideoTemplateEditItemMedia

@synthesize asset = _asset;
@synthesize selected = _selected;
@synthesize coverImage = _coverImage;
@synthesize text;
@synthesize title;
@synthesize refreshCoverBlock;
@synthesize refreshTextBlock;
@synthesize refreshSelectedBlock;
@synthesize itemText;
@synthesize itemMusic;

- (instancetype)initWithAsset:(AliyunAETemplateAssetMedia *)asset templatePath:(NSString *)templatePath {
    self = [super init];
    if (self) {
        _asset = asset;
        _templatePath = templatePath;
    }
    return self;
}

- (AUIVideoTemplateEditItemMedia *)itemMedia {
    return self;
}

- (void)updateClip:(NSString *)clipPath cover:(UIImage *)image {
    _asset.replacedPath = clipPath;
    _coverImage = image;
    if (self.refreshCoverBlock) {
        self.refreshCoverBlock(self);
    }
}

- (void)setSelected:(BOOL)selected {
    if (_selected == selected) {
        return;
    }
    _selected = selected;
    if (self.refreshSelectedBlock) {
        self.refreshSelectedBlock(self);
    }
}

- (UIImage *)coverImage {
    if (!_coverImage) {
        _coverImage = self.defaultCover;
    }
    return _coverImage;
}

- (UIImage *)defaultCover {
    if (!_defaultCover) {
        NSString *path = [[_templatePath stringByAppendingPathComponent:@"assets"] stringByAppendingPathComponent:_asset.assetName];
        _defaultCover = [self coverWithAssetPath:path outputSize:CGSizeMake(200, 200)];
    }
    return _defaultCover;
}

- (NSTimeInterval)duration {
    return _asset.duration;
}

- (BOOL)isReplaced {
    return _asset && _asset.replacedPath.length > 0 && _pickerResult;
}

- (UIImage *)coverWithAssetPath:(NSString *)path outputSize:(CGSize)outputSize {
    if (path.length == 0 || ![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return nil;
    }
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:path] options:nil];
    if ([asset tracksWithMediaType: AVMediaTypeVideo].count > 0) {
        AVAssetImageGenerator *assetGen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
        assetGen.maximumSize = outputSize;
        assetGen.appliesPreferredTrackTransform = YES;
        CMTime time = CMTimeMakeWithSeconds(0.1, 600);
        CGImageRef image = [assetGen copyCGImageAtTime:time actualTime:NULL error:nil];
        UIImage *videoImage = [[UIImage alloc] initWithCGImage:image];
        CGImageRelease(image);
        return videoImage;
    }
    return [UIImage imageWithContentsOfFile:path];
}

@end

@interface AUIVideoTemplateEditItemText ()

@end

@implementation AUIVideoTemplateEditItemText

@synthesize asset = _asset;
@synthesize selected = _selected;
@synthesize coverImage;
@synthesize title;
@synthesize duration;
@synthesize refreshCoverBlock;
@synthesize refreshTextBlock;
@synthesize refreshSelectedBlock;
@synthesize itemMedia;
@synthesize itemMusic;

- (instancetype)initWithAsset:(AliyunAETemplateAssetText *)asset {
    self = [super init];
    if (self) {
        _asset = asset;
    }
    return self;
}

- (AUIVideoTemplateEditItemText *)itemText {
    return self;
}

- (void)setSelected:(BOOL)selected {
    if (_selected == selected) {
        return;
    }
    _selected = selected;
    if (self.refreshSelectedBlock) {
        self.refreshSelectedBlock(self);
    }
}

- (void)updateText:(NSString *)text {
    _asset.replacedText = text;
    if (self.refreshTextBlock) {
        self.refreshTextBlock(self);
    }
}

- (NSString *)text {
    if (_asset.replacedText.length > 0) {
        return _asset.replacedText;
    }
    return _asset.text;
}

@end


@interface AUIVideoTemplateEditItemMusic ()

@end

@implementation AUIVideoTemplateEditItemMusic

@synthesize musicType = _musicType;
@synthesize selectedModel = _selectedModel;
@synthesize selected = _selected;
@synthesize coverImage = _coverImage;
@synthesize title = _title;
@synthesize text;
@synthesize duration;
@synthesize refreshCoverBlock;
@synthesize refreshTextBlock;
@synthesize refreshSelectedBlock;
@synthesize itemText;
@synthesize itemMedia;

- (instancetype)initWithMusicType:(AUIVideoTemplateEditMusicType)musicType {
    self = [super init];
    if (self) {
        _musicType = musicType;
        if (_musicType == AUIVideoTemplateEditMusicTypeNone) {
            _coverImage = AUIUgsvTemplateImage(@"ic_music_none");
            _title = @"不设置音乐";
        }
        else if (_musicType == AUIVideoTemplateEditMusicTypeTemplate) {
            _coverImage = AUIUgsvTemplateImage(@"ic_music_template");
            _title = @"模板音乐";
        }
        else {
            _coverImage = AUIUgsvTemplateImage(@"ic_music_custom");
            _title = @"其他音乐";
        }
    }
    return self;
}

- (AUIVideoTemplateEditItemMusic *)itemMusic {
    return self;
}

- (void)setSelected:(BOOL)selected {
    if (_selected == selected) {
        return;
    }
    _selected = selected;
    if (self.refreshSelectedBlock) {
        self.refreshSelectedBlock(self);
    }
}

- (void)updateMusicCustomSelectedModel:(AUIMusicSelectedModel *)selectedModel {
    if (_selectedModel != selectedModel) {
        _selectedModel = selectedModel;
        if (self.refreshCoverBlock) {
            self.refreshCoverBlock(self);
        }
    }
}

@end

