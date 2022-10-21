

#import <UIKit/UIKit.h>

@interface AUIPlayerLandscapeController : UIViewController

- (instancetype)initWithPlayView:(UIView *)playView;

- (void)expandOrCloseWithOrientation:(UIInterfaceOrientation)orientation;

@end
