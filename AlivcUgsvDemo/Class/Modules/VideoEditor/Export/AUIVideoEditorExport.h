//
//  AUIVideoEditorExport.h
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/6/14.
//

#import <UIKit/UIKit.h>
#import "AUIMediaProgressViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUIVideoEditorExport : NSObject<AUIMediaProgressProtocol>

@property (nonatomic, assign) BOOL saveToAlbumExportCompleted;

// Export and save to album if need
- (instancetype)initWithTaskPath:(NSString *)taskPath;

// Exsits a video file, only save to album if need
- (instancetype)initWithVideoFilePath:(NSString *)videoFilePath outputSize:(CGSize)outputSize;

@end

NS_ASSUME_NONNULL_END
