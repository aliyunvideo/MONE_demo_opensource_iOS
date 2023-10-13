//
//  AUICropPreview.h
//  AlivcUgsvDemo
//
//  Created by coder.pi on 2022/12/15.
//

#import <UIKit/UIKit.h>
#import "AUIVideoPlayProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUICropPreviewContent : UIView
@property (nonatomic, readonly) BOOL isVideo;
@property (nonatomic, readonly) CGSize resolution;
@property (nonatomic, weak, readonly) id<AUIVideoPlayProtocol> videoPlayer;
- (instancetype)initWithImage:(UIImage *)image;
- (instancetype)initWithVideo:(id<AUIVideoPlayProtocol>)video resolution:(CGSize)resolution;
@end

@interface AUICropPreview : UIView
@property (nonatomic, readonly) CGRect cropRect;
@property (nonatomic, readonly) CGSize outputResolution;
@property (nonatomic, readonly) AUICropPreviewContent *content;
- (instancetype) initWithContent:(AUICropPreviewContent *)content
                outputResolution:(CGSize)resolution;
@end

NS_ASSUME_NONNULL_END
