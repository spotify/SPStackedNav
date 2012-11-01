#import <UIKit/UIKit.h>

/// PRIVATE IMPLEMENTATION DETAIL of SPStackedNavigationController


/// Holds a VC in the navigation stack, visual decorations, and info about it.
/// It will also make sure to load/unload its view as needed when it appears/
/// disappears.
@interface SPStackedPageContainer : UIView
@property(nonatomic,retain) UIViewController *vc;
@property(nonatomic,retain) UIView *vcContainer;
@property(nonatomic) BOOL VCVisible;
@property(nonatomic,retain) UIImageView *screenshot;
@property(nonatomic) BOOL markedForSuperviewRemoval;
@property(nonatomic) BOOL needsInitialPresentation;
@property(nonatomic) CGFloat overlayOpacity;

- (id)initWithFrame:(CGRect)frame VC:(UIViewController*)vc;
@end
