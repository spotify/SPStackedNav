//
//  SPAppDelegate.m
//  StackExample
//
//  Created by Joachim Bengtsson on 2012-10-27.
//  Copyright (c) 2012 Spotify. All rights reserved.
//

#import "SPAppDelegate.h"
#import "RootTestViewController.h"

@implementation SPAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    
    self.tabs = [[SPSideTabController alloc] init];
    
    RootTestViewController *root1 = [RootTestViewController new];
    root1.title = @"Root 1";
    root1.tabBarItem.image = [UIImage imageNamed:@"114-balloon"];
    RootTestViewController *root2 = [RootTestViewController new];
    root2.title = @"Root 2";
    root2.tabBarItem.image = [UIImage imageNamed:@"185-printer"];
    
    self.tabs.viewControllers = @[
        [[SPStackedNavigationController alloc] initWithRootViewController:root1],
        [[SPStackedNavigationController alloc] initWithRootViewController:root2],
    ];

    
    self.window.rootViewController = self.tabs;
    [self.window makeKeyAndVisible];
    return YES;
}

@end
