//
//  SPAppDelegate.h
//  StackExample
//
//  Created by Joachim Bengtsson on 2012-10-27.
//  Copyright (c) 2012 Spotify. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SPStackedNav/SPStackedNav.h>

@interface SPAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) SPSideTabController *tabs;

@end
