//
//  ChildTestViewController.m
//  StackExample
//
//  Created by Joachim Bengtsson on 2012-10-27.
//  Copyright (c) 2012 Spotify. All rights reserved.
//

#import "ChildTestViewController.h"
#import <SPStackedNav/SPStackedNav.h>

@implementation ChildTestViewController

- (id)init
{
    if (!(self = [super init]))
        return nil;
	
	self.stackedNavigationController.tabBarItem.badgeValue = @"0";
    
    return self;
}

- (IBAction)test:(id)sender
{
    [self.stackedNavigationController pushViewController:[ChildTestViewController new] onTopOf:self animated:YES];
	self.stackedNavigationController.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d", self.stackedNavigationController.viewControllers.count];
}

- (SPStackedNavigationPageSize)stackedNavigationPageSize;
{
    return [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad ? kStackedPageHalfSize : kStackedPageFullSize;
}

@end
