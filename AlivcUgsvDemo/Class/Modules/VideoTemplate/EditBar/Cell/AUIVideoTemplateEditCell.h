//
//  AUIVideoTemplateEditCell.h
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/12/22.
//

#import <UIKit/UIKit.h>
#import "AUIVideoTemplateEditItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUIVideoTemplateEditCell : UICollectionViewCell

- (void)updateItem:(id<AUIVideoTemplateEditItemProtocol>)item;

@end

NS_ASSUME_NONNULL_END
