//
//  AUIVideoTemplateExport.m
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/10/12.
//

#import "AUIVideoTemplateExport.h"
#import "AUIPhotoLibraryManager.h"
#import "AUIUgsvPath.h"

@interface AUIVideoTemplateExport () <AliyunAETemplateRenderDelegate>

@property (nonatomic, weak) AliyunAETemplateEditor *editor;
@property (nonatomic, strong) AUIVideoTemplateOutputParam *param;

@end

@implementation AUIVideoTemplateExport

@synthesize onMediaDoProgress;
@synthesize onMediaFinishProgress;
@synthesize requestCoverImageBlock;

- (instancetype)initWithEditor:(AliyunAETemplateEditor *)editor outputParam:(AUIVideoTemplateOutputParam *)param {
    self = [super init];
    if (self) {
        self.editor = editor;
        self.editor.render.delegate = self;
        
        self.param = param;
        if (self.param.bpp > 0) {
            self.editor.render.bpp = self.param.bpp;
        }
        self.editor.render.outputPath = self.param.outputPath;
        if (self.editor.render.outputPath.length == 0) {
            self.editor.render.outputPath = [AUIUgsvPath exportFilePath:nil];
        }
    }
    return self;
}

- (CGSize)coverImageSize {
    return self.editor.currentTemplate.outputSize;
}

- (void)mediaStartProgress {
    BOOL ret = [self.editor.render start];
    if (!ret) {
        [self templateRenderFailed:[NSError errorWithDomain:@"aliyun.templage" code:-1 userInfo:nil]];
    }
}

- (void)mediaCancelProgress {
    [self.editor.render cancel];
}

#pragma mark - AliyunAETemplateRenderDelegate

- (void)templateRenderStarted {
    NSLog(@"templage render started");
}

- (void)templateRenderFinished:(NSURL *)outputUrl {
    NSLog(@"templage render completed");
    if (self.param.saveToAlbumExportCompleted) {
        [AUIPhotoLibraryManager saveVideoWithUrl:outputUrl location:nil completion:^(PHAsset * _Nonnull asset, NSError * _Nonnull error) {
            if (error) {
                NSLog(@"保存相册失败");
            }
            if (self.onMediaDoProgress) {
                self.onMediaDoProgress(1.0);
            }
            if (self.onMediaFinishProgress) {
                self.onMediaFinishProgress(nil, outputUrl.absoluteString);
            }
        }];
    }
    else {
        if (self.onMediaFinishProgress) {
            self.onMediaFinishProgress(nil, outputUrl.absoluteString);
        }
    }
}

- (void)templateRenderCancelled {
    NSLog(@"templage render cancel");
}

- (void)templateRenderFailed:(NSError *)error {
    NSLog(@"templage render error:%@", error);
    if (self.onMediaFinishProgress) {
        self.onMediaFinishProgress(error, nil);
    }
}

- (void)templateRenderProgress:(CGFloat)progress {
    NSLog(@"templage render progress:%f", progress);
    if (self.onMediaDoProgress) {
        self.onMediaDoProgress(progress);
    }
}

@end
