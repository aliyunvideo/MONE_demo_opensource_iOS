//
//  AUIEditorThumbnailCache.m
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/6/17.
//

#import "AUIEditorThumbnailCache.h"


@interface AUIEditorThumbnailCache ()

@property (nonatomic, strong) NSMutableDictionary<NSString *, id<AUITrackerThumbnailRequestProtocol>> *thumbnailCache;

@end

@implementation AUIEditorThumbnailCache

- (NSMutableDictionary<NSString *,id<AUITrackerThumbnailRequestProtocol>> *)thumbnailCache {
    if (!_thumbnailCache) {
        _thumbnailCache = [NSMutableDictionary dictionary];
    }
    return _thumbnailCache;
}

- (AUITrackerThumbnailRequest *)videoThumbnail:(NSString *)clipPath {
    AUITrackerThumbnailRequest *thumb = [self.thumbnailCache objectForKey:clipPath];
    if (!thumb && clipPath.length > 0) {
        thumb = [[AUITrackerThumbnailRequest alloc] initWithGenerator:[[AUIAsyncImageGeneratorVideo alloc] initWithPath:clipPath]];
        [self.thumbnailCache setObject:thumb forKey:clipPath];
    }
    return thumb;
}

- (AUITrackerThumbnailRequest *)photoThumbnail:(NSString *)clipPath {
    AUITrackerThumbnailRequest *thumb = [self.thumbnailCache objectForKey:clipPath];
    if (!thumb && clipPath.length > 0) {
        thumb = [[AUITrackerThumbnailRequest alloc] initWithGenerator:[[AUIAsyncImageGeneratorPhoto alloc] initWithPath:clipPath]];
        [self.thumbnailCache setObject:thumb forKey:clipPath];
    }
    return thumb;
}

@end
