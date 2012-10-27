#import <UIKit/UIKit.h>
@protocol SPSideTabBarDelegate;

@interface SPSideTabBar : UIView
-(id)initWithFrame:(CGRect)r;
@property(nonatomic,assign) id<SPSideTabBarDelegate> delegate; // weak reference. default is nil
@property(nonatomic,copy)   NSArray             *items;        // get/set visible UITabBarItems. default is nil. changes not animated. shown in order
@property(nonatomic,retain) UITabBarItem        *selectedItem;
@property(nonatomic,copy)   NSArray             *additionalItems; // shown starting from the bottom, not associated with a view controller
-(void)select:(BOOL)selected additionalItem:(UITabBarItem*)item;
-(CGRect)rectForItem:(UITabBarItem*)item;
@end


@protocol SPSideTabBarDelegate<NSObject>
@optional
- (void)tabBar:(SPSideTabBar *)tabBar didSelectItem:(UITabBarItem *)item; // called when a new view is selected by the user (but not programatically)
@end
