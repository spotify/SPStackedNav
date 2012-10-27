#import <UIKit/UIKit.h>
#import <SPStackedNav/SPSideTabBar.h>

@interface SPSideTabController : UIViewController

@property(nonatomic,copy) NSArray *viewControllers;
@property(nonatomic,retain) UIViewController *selectedViewController; // This may return the "More" navigation controller if it exists.
@property(nonatomic) NSUInteger selectedIndex;
@property(nonatomic,retain) UIViewController *bottomAttachment;
@property(nonatomic,readonly,retain) SPSideTabBar *tabBar;
@property(nonatomic,assign) id<SPSideTabBarDelegate> tabBarDelegate; // is forwarded additionalItems
@property(nonatomic,retain) NSArray *additionalItems;

- (BOOL)isBottomAttachmentHidden;
- (void)setBottomAttachmentHidden:(BOOL)hidden animated:(BOOL)animated;
@end

/**
 * SPTabBarItem is a UITabBarItem subclass that adds SPSideTabController specific functionality.
 */
@interface SPTabBarItem : UITabBarItem
- (id)initWithTitle:(NSString *)title imageName:(NSString*)imageName tag:(NSInteger)tag;


/// SPSideTabController will present this view (if available) instead of the normal button (default = nil).
@property(nonatomic,strong) UIView *view;

/// instead of -image, if you want to use pre-composited images in the form "{name}-{state(s)}-tb.png"
@property(nonatomic,copy) NSString *imageName;
@end
