//
//  AUIPlayerWatchPointContainer.m
//  ApsaraVideo
//
//  Created by mengyehao on 2021/7/29.
//

#import "AUIPlayerWatchPointContainer.h"
#import "AUIPlayerWatchPointService.h"
#import "AUIPlayerWatchPointEntry.h"
#import "AlivcPlayerManager.h"
#import "AUIPlayerRecommendWatchPointView.h"
#import "AlivcPlayerManager.h"

@interface AUIPlayerWatchPointContainer()
@property (nonatomic, weak) AUIPlayerRecommendWatchPointView *watchPointView;
@property (nonatomic, copy) NSArray *dataList;

@end

@implementation AUIPlayerWatchPointContainer

- (void)updateData
{
    AUIPlayerWatchPointService *service  =[AUIPlayerWatchPointService  new];
    NSArray<AlivcPlayerWatchPointModel *> *list = [service getWatchPoints];
    
   int64_t duration =  [AlivcPlayerManager manager].duration;
    NSMutableArray *tempList = [NSMutableArray array];
    for (AlivcPlayerWatchPointModel *model in list) {
        if (model.ts <= duration) {
            [tempList addObject:model];
        }
    }
    
    self.dataList = tempList;

}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
    
    for (AlivcPlayerWatchPointModel *obj in self.dataList) {
        AUIPlayerWatchPointEntry *entry = [[AUIPlayerWatchPointEntry alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        
        CGFloat X = 0;
        CGFloat duration = [AlivcPlayerManager manager].duration;
        if (duration) {
            X = self.bounds.size.width * obj.ts/duration;
        }
        entry.center = CGPointMake(X, self.bounds.size.height/2);
        
        __weak typeof (self) weakSelf = self;

        [self addSubview:entry];
        entry.model = obj;
        
        __weak typeof (entry) weakEntry = entry;

        
        entry.onViewBlock = ^{
            [weakSelf showRecommendWatchPointView:weakEntry];
        };
        
        
    }
}

- (void)showRecommendWatchPointView:(AUIPlayerWatchPointEntry *)entry
{
    if (self.watchPointView) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideWatchPointView) object:nil];
        [self.watchPointView removeFromSuperview];
        self.watchPointView = nil;
    }

    
    AlivcPlayerWatchPointModel *model = entry.model;
    AUIPlayerRecommendWatchPointView *view = [[AUIPlayerRecommendWatchPointView alloc] initWithFrame:CGRectMake(0, 0, 336, 40)];
    view.accessibilityIdentifier = [self accessibilityId:@"recommendWatchPointView"];
    [self.superContainer addSubview:view];
//    CGFloat centerX =  [entry convertPoint:entry.center toView:self.superContainer].x;
    CGFloat centerX =  entry.center.x + self.av_left;
    
    if (centerX - view.bounds.size.width/2 < self.av_left) {
        centerX = view.bounds.size.width/2 + self.av_left;
    }
    
    if (centerX > self.superContainer.av_width - view.bounds.size.width/2 - self.av_left) {
        centerX = self.superContainer.av_width - view.bounds.size.width/2 - self.av_left;
    }
    
    view.center = CGPointMake(centerX, self.superContainer.bounds.size.height - 88 - 20);
    view.model = model;
    self.watchPointView = view;
    [self performSelector:@selector(hideWatchPointView) withObject:nil afterDelay:3];
    
    UITapGestureRecognizer *tapgesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSeekTo:)];
    [view addGestureRecognizer:tapgesture];
}

- (void)onSeekTo:(id)sender
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideWatchPointView) object:nil];
    
    [[AlivcPlayerManager manager] seekToTimeProgress:(float)self.watchPointView.model.ts/[AlivcPlayerManager manager].duration seekMode:AVP_SEEKMODE_ACCURATE];
    
    [self hideWatchPointView];
    
    
    
}

- (void)hideWatchPointView
{
    [self.watchPointView removeFromSuperview];
    self.watchPointView = nil;
}


- (void)setHidden:(BOOL)hidden
{
    [super setHidden:hidden];
    self.watchPointView.hidden = hidden;
}

- (NSString *)accessibilityId:(NSString *)key {
    NSString *name = NSStringFromClass([self class]);
    return [AUIVideoFlowAccessibilityStr(name) stringByAppendingString:key];
}

@end
