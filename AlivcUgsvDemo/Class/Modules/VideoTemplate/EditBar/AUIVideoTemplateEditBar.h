//
//  AUIVideoTemplateEditBar.h
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/9/22.
//

#import <UIKit/UIKit.h>
#import "AUITemplatePlay.h"
#import "AUIVideoTemplateEditItem.h"


NS_ASSUME_NONNULL_BEGIN

@interface AUIVideoTemplateEditBar : UIView

@property (nonatomic, strong) AUITemplatePlay *player;
@property (nonatomic, copy) void (^selectedAssetBlock)(id<AUIVideoTemplateEditItemProtocol>  _Nullable  editItem);
@property (nonatomic, copy) void (^editAssetBlock)(id<AUIVideoTemplateEditItemProtocol> editItem);
@property (nonatomic, copy) void (^selectedMusicBlock)(NSString * _Nullable musicPath);


- (instancetype)initWithFrame:(CGRect)frame editItems:(NSArray<NSArray<AUIVideoTemplateEditItemProtocol> *> *)editItems;

- (void)clearSelectedNode;

@end

NS_ASSUME_NONNULL_END
