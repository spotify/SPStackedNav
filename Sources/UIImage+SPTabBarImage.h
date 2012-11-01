#import <Foundation/Foundation.h>

@interface UIImage (SPTabBarImage)
- (UIImage*)sp_imageForTabBar;
- (UIImage*)sp_selectedImageForTabBar;
- (UIImage*)sp_selectedAndHighlightedImageForTabBar;
@end
