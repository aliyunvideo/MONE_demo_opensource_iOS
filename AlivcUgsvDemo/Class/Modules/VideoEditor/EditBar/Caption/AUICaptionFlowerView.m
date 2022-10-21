//
//  AUICaptionFlowerView.m
//  AlivcEdit
//
//  Created by mengyehao on 2021/5/26.
//

#import "AUICaptionFlowerView.h"
#import "AUIStickerModel.h"
#import "AUIResourceManager.h"
#import "AlivcUgsvSDKHeader.h"


@implementation AUICaptionFlowerView

- (void)fetchData
{
    [[AUIResourceManager manager] fetchFontFlowerDataWithCallBack:^(NSError *error, NSArray *data) {

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
        
        if ( [stickerController.model.fontEffectTemplatePath isEqualToString:obj.resourcePath]) {
            [self selectWithIndex:idx];
            *stop =YES;
        }
    }];
}
@end
