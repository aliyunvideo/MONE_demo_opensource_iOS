//
//  AUIPhotoAlbumListView.h
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/5/25.
//

#import "AUIFoundation.h"
#import "AUIPhotoLibraryManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUIPhotoAlbumListView : UIView

- (instancetype)initWithFrame:(CGRect)frame
           withAlbumModelList:(NSArray<AUIPhotoAlbumModel *> *)modelList
            withSelectedBlock:(void(^)(AUIPhotoAlbumModel *selectedModel))selectedBlock;

- (void)appear:(void(^)(void))completed;
- (void)disappear:(void(^)(void))completed;

@end

NS_ASSUME_NONNULL_END
