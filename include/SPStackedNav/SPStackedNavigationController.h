#import <UIKit/UIKit.h>

typedef enum 
{
    SPStackedNavigationPagePositionLeft = 0,
    SPStackedNavigationPagePositionRight,
} SPStackedNavigationPagePosition;

/**
    @class SPStackedNavigationController
    @author nevyn@spotify.com

    @abstract "Twitter for iPad"-style navigation, where you have panes of content that
    you can scroll between by swiping sideways, often having more than one pane
    visible at once. API-wise, it behaves almost exactly like a UINavigationController,
    except you can push VCs in the middle of it.
*/
@interface SPStackedNavigationController : UIViewController
- (id)initWithRootViewController:(UIViewController *)rootViewController;

// activate specifies whether the pushed view controller should become the active view controller or not
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated; // activate = YES
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated activate:(BOOL)activate;
// replace everything on the stack after 'parent' with 'viewController'
- (void)pushViewController:(UIViewController *)viewController onTopOf:(UIViewController*)parent animated:(BOOL)animated; // activate = YES
- (void)pushViewController:(UIViewController *)viewController onTopOf:(UIViewController*)parent animated:(BOOL)animated activate:(BOOL)activate;

- (UIViewController *)popViewControllerAnimated:(BOOL)animated;
- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated;

/// Top of the stack
@property(nonatomic,readonly) UIViewController *topViewController;
/// The current active view controller
/// Positioned to the right or left as specified in -activeViewControllerPagePosition.
@property(nonatomic,retain,readonly) UIViewController *activeViewController;
/// Active view controller position
/// Aligns the active view controller to the specified edge of the screen (left or right).
/// Preserved between orientation changes.
@property(nonatomic,assign,readonly) SPStackedNavigationPagePosition activeViewControllerPagePosition;
- (void)setActiveViewController:(UIViewController*)viewController animated:(BOOL)animated; // automatically calculates position
- (void)setActiveViewController:(UIViewController *)viewController position:(SPStackedNavigationPagePosition)position animated:(BOOL)animated;

/// Modal if it exists, otherwise active
- (NSArray *)visibleViewControllers;
@property(nonatomic,copy) NSArray *viewControllers;
- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated;

// The scroll views pan gesture recognizer.
// Will load the view if accessed, so make sure to check -isViewLoaded first.
- (UIGestureRecognizer*)panGestureRecognizer;
@end




static const CGFloat kSPStackedNavigationHalfPageWidth = 472;

enum {
    /// Fills the width of the screen in landscape (excluding sidebar)
    kStackedPageHalfSize = 1,
    /// Uses the full available width
    kStackedPageFullSize = 2
};
typedef int SPStackedNavigationPageSize;

/// Informal protocol used to optionally customize the behavior of child VCs
/// to a SPStackedNavigationController.
@interface NSObject (SPStackedNavigationChild)
/// How much width does this VC use when pushed on a SPStackedNavigationController?
/// Default kStackedPageFullSize
- (SPStackedNavigationPageSize)stackedNavigationPageSize;
@end

/// Up-accessors from child VCs
@interface UIViewController (SPStackedNavigationControllerItem)
@property(nonatomic,readonly) SPStackedNavigationController *stackedNavigationController; // If this view controller has been pushed onto a navigation controller, return it.

/// XXX: Might count as private API? Also, category loading order isn't deterministic :/
/// Duck-type a SPStackedNav if that's the parent; return the UINavC if that's the parent; or nil.
@property(nonatomic,readonly) UINavigationController *navigationController;

// Sent to child view controllers when active view controller is changed
- (void)viewDidBecomeActiveInStackedNavigation;
- (void)viewDidBecomeInactiveInStackedNavigation;

// Calls -[SPStackedNavigationController setActiveViewController:animated:]
// Used to activate yourself when user interacts with a managed view (scrolling, opening a context menu, playing a track).
- (void)activateInStackedNavigationAnimated:(BOOL)animated;

// Returns true if this is the currently active view controller.
- (BOOL)isActiveInStackedNavigation;
@end

@interface UINavigationController (SPStackedNavigationControllerCompatibility)
- (void)pushViewController:(UIViewController *)viewController onTopOf:(UIViewController*)parent animated:(BOOL)animated;
@end