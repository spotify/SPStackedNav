// Copyright 2014 Spotify
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
//     http://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

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
