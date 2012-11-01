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
    
    return self;
}

- (IBAction)test:(id)sender
{
    [self.stackedNavigationController pushViewController:[ChildTestViewController new] onTopOf:self animated:YES];
}

- (SPStackedNavigationPageSize)stackedNavigationPageSize;
{
    return [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad ? kStackedPageHalfSize : kStackedPageFullSize;
}

@end
