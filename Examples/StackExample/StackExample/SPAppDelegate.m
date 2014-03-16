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
//
//  File created by Joachim Bengtsson on 2012-10-27.

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
