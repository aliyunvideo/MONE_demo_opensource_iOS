//
//  AUIVideoEditorExport.m
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/6/14.
//

#import "AUIVideoEditorExport.h"
#import "AlivcUgsvSDKHeader.h"
#import "AUIUgsvPath.h"
#import "AUIPhotoLibraryManager.h"

@interface AUIVideoEditorExport () <AliyunIExporterCallback>

@property (nonatomic, copy) NSString *taskPath;
@property (nonatomic, copy) NSString *outputPath;
@property (nonatomic, assign) CGSize outputSize;
@property(nonatomic, strong) AliyunEditor *editor;

@end

@implementation AUIVideoEditorExport

@synthesize onMediaDoProgress;
@synthesize onMediaFinishProgress;
@synthesize requestCoverImageBlock;

- (instancetype)initWithTaskPath:(NSString *)taskPath {
    self = [super init];
    if (self) {
        _taskPath = taskPath;
        _outputPath = [AUIUgsvPath exportFilePath:nil];

        _editor = [[AliyunEditor alloc] initWithPath:_taskPath preview:nil];
        _editor.exporterCallback = self;
    }
    return self;
}

- (instancetype)initWithVideoFilePath:(NSString *)videoFilePath outputSize:(CGSize)outputSize {
    self = [super init];
    if (self) {
        _outputPath = videoFilePath;
        _outputSize = outputSize;
    }
    return self;
}


- (CGSize)coverImageSize {
    if (self.editor) {
        return [self.editor getEditorProject].config.outputResolution;
    }
    return self.outputSize;
}

- (void)mediaStartProgress {
    
    if (self.editor) {
        [self.editor stopEdit];
        int ret = [[self.editor getExporter] startExport:self.outputPath];
        if (ret != ALIVC_COMMON_RETURN_SUCCESS) {
            [self exportError:ret];
        }
    }
    else if (self.outputPath) {
        // save to album
        if (self.saveToAlbumExportCompleted) {
            [AUIPhotoLibraryManager saveVideoWithUrl:[NSURL fileURLWithPath:self.outputPath] location:nil completion:^(PHAsset * _Nonnull asset, NSError * _Nonnull error) {
                
                if (self.onMediaDoProgress) {
                    self.onMediaDoProgress(1.0);
                }
                if (error) {
                    if (self.onMediaFinishProgress) {
                        self.onMediaFinishProgress(error, nil);
                    }
                }
                else {
                    if (self.onMediaFinishProgress) {
                        self.onMediaFinishProgress(nil, self.outputPath);
                    }
                }
            }];
        }
        else {
            if (self.onMediaDoProgress) {
                self.onMediaDoProgress(1.0);
            }
            if (self.onMediaFinishProgress) {
                self.onMediaFinishProgress(nil, self.outputPath);
            }
        }
    }
    else {
        if (self.onMediaFinishProgress) {
            self.onMediaFinishProgress([NSError errorWithDomain:@"error.editor" code:-1 userInfo:nil], nil);
        }
    }
}

- (void)mediaCancelProgress {
    [[self.editor getExporter] cancelExport];
}

#pragma mark - AliyunIExporterCallback

- (void)exporterDidEnd:(NSString *)outputPath {
    NSLog(@"editor exporter completed");
    [self.editor stopEdit];
    if (self.saveToAlbumExportCompleted) {
        [AUIPhotoLibraryManager saveVideoWithUrl:[NSURL fileURLWithPath:self.outputPath] location:nil completion:^(PHAsset * _Nonnull asset, NSError * _Nonnull error) {
            if (error) {
                NSLog(@"保存相册失败");
            }
            if (self.onMediaDoProgress) {
                self.onMediaDoProgress(1.0);
            }
            if (self.onMediaFinishProgress) {
                self.onMediaFinishProgress(nil, self.outputPath);
            }
        }];
    }
    else {
        if (self.onMediaFinishProgress) {
            self.onMediaFinishProgress(nil, self.outputPath);
        }
    }
}

- (void)exporterDidCancel {
    [self.editor stopEdit];
    NSLog(@"editor exporter cancel");
}

- (void)exportProgress:(float)progress {
    NSLog(@"editor exporter progress:%f", progress);
    if (self.saveToAlbumExportCompleted) {
        progress = progress * 0.95;
    }
    if (self.onMediaDoProgress) {
        self.onMediaDoProgress(progress);
    }
}

- (void)exportError:(int)errorCode {
    [self.editor stopEdit];
    NSLog(@"editor exporter error:%@", @(errorCode));
    if (self.onMediaFinishProgress) {
        self.onMediaFinishProgress([NSError errorWithDomain:@"error.editor" code:errorCode userInfo:nil], nil);
    }
}

- (void)exporterDidStart {
    
}


@end
