//
//  AUICaptionBubbleView.m
//  AlivcUgsvDemo
//
//  Created by mengyehao on 2022/6/1.
//

#import "AUICaptionBubbleView.h"
#import "AUIStickerModel.h"
#import "AUIResourceManager.h"
#import "AlivcUgsvSDKHeader.h"


@implementation AUICaptionBubbleView

- (void)fetchData
{
    [[AUIResourceManager manager] fetchBubbleDataWithCallBack:^(NSError *error, NSArray *data) {
        
        NSMutableArray *list = [NSMutableArray array];
        [list addObject:[AUIStickerModel EmptyModel]];
        [list addObjectsFromArray:data];
        [self updateDataSource:list];
    }];

}

- (void)setStickerController:(AliyunCaptionStickerController *)stickerController
{
    _stickerController = stickerController;
   
    
    [self.dataList enumerateObjectsUsingBlock:^(AUIStickerModel*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ( [stickerController.model.resourePath isEqualToString:obj.resourcePath]) {
            [self selectWithIndex:idx];
            *stop = YES;
        }
    }];
}

@end
