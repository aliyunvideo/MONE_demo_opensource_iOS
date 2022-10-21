//
//  AUIPlayerVideoDetailViewCell.h
//  ApsaraVideo
//
//  Created by mengyehao on 2021/8/16.
//

#import <UIKit/UIKit.h>
@class AlivcPlayerVideo;


@interface AlivcPlayerVideoDetailViewUserInfoCell : UITableViewCell
@property (nonatomic, strong) AlivcPlayerVideo *item;
@end



@interface AlivcPlayerVideoDetailViewSeletedArtCell : UITableViewCell
@property (nonatomic, strong, readonly) UICollectionView *collectionView;

@property (nonatomic, copy) NSArray *dataList;
@property (nonatomic, copy) void(^onSeletedBlock)(int);

@end


@interface AlivcPlayerVideoDetailViewRecommendCell : UITableViewCell
@property (nonatomic, strong) AlivcPlayerVideo *item;

@end
