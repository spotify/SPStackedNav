#import "SPStackedNavigationController.h"

@class SPStackedPageContainer;
@protocol SPStackedNavigationScrollViewDelegate;

/// PRIVATE IMPLEMENTATION DETAIL of SPStackedNavigationController

@interface SPStackedNavigationScrollView : UIView
@property(nonatomic) CGPoint contentOffset;
@property(nonatomic,assign) id<SPStackedNavigationScrollViewDelegate> delegate;
@property(nonatomic,retain,readonly) UIPanGestureRecognizer *panGestureRecognizer;
- (void)setContentOffset:(CGPoint)contentOffset animated:(BOOL)animated;
- (void)snapToClosest;

- (NSRange)scrollRange;
- (CGFloat)scrollOffsetForAligningPageWithRightEdge:(SPStackedPageContainer*)pageC;
- (CGFloat)scrollOffsetForAligningPageWithLeftEdge:(SPStackedPageContainer*)pageC;
- (CGFloat)scrollOffsetForAligningPage:(SPStackedPageContainer*)pageC position:(SPStackedNavigationPagePosition)position;
- (SPStackedPageContainer*)containerForViewController:(UIViewController*)viewController;
@end

@protocol SPStackedNavigationScrollViewDelegate <NSObject>
- (void)stackedNavigationScrollView:(SPStackedNavigationScrollView *)stackedNavigationScrollView
             didStopAtPageContainer:(SPStackedPageContainer *)stackedPageContainer
                       pagePosition:(SPStackedNavigationPagePosition)pagePosition;
@end