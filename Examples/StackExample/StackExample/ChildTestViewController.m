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
