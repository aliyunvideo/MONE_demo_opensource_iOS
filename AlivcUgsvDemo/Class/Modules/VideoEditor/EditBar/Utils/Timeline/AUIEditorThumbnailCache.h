//
//  AUIEditorThumbnailCache.h
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/6/17.
//

#import <Foundation/Foundation.h>
#import <AUIUgsvCom/AUIUgsvCom.h>

NS_ASSUME_NONNULL_BEGIN

@interface AUIEditorThumbnailCache : NSObject

- (AUITrackerThumbnailRequest *)videoThumbnail:(NSString *)clipPath;
- (AUITrackerThumbnailRequest *)photoThumbnail:(NSString *)clipPath;

@end

NS_ASSUME_NONNULL_END
