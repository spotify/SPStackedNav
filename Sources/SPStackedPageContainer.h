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
