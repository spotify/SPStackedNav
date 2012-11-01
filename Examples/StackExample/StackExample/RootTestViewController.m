//
//  RootTestViewController.m
//  StackExample
//
//  Created by Joachim Bengtsson on 2012-10-27.
//  Copyright (c) 2012 Spotify. All rights reserved.
//

#import "RootTestViewController.h"
#import <SPStackedNav/SPStackedNav.h>
#import "ChildTestViewController.h"

@implementation RootTestViewController

- (id)init
{
    if (!(self = [super init]))
        return nil;
    
    
    return self;
}

- (SPStackedNavigationPageSize)stackedNavigationPageSize
{
    return kStackedPageFullSize;
}

- (IBAction)test:(id)sender
{
    [self.stackedNavigationController pushViewController:[ChildTestViewController new] onTopOf:self animated:YES];
}

@end
