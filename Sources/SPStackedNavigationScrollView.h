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

#import "SPStackedNavigationController.h"

@class SPStackedPageContainer;
@protocol SPStackedNavigationScrollViewDelegate;

/// PRIVATE IMPLEMENTATION DETAIL of SPStackedNavigationController

@interface SPStackedNavigationScrollView : UIView
@property(nonatomic) CGPoint contentOffset;
@property(nonatomic,assign) id<SPStackedNavigationScrollViewDelegate> delegate;
@property(nonatomic,retain,readonly) UIPanGestureRecognizer *panGestureRecognizer;
- (void)setContentOffset:(CGPoint)contentOffset animated:(BOOL)animated;
- (void)snapToClosest;

- (NSRange)scrollRange;
- (CGFloat)scrollOffsetForAligningPageWithRightEdge:(SPStackedPageContainer*)pageC;
- (CGFloat)scrollOffsetForAligningPageWithLeftEdge:(SPStackedPageContainer*)pageC;
- (CGFloat)scrollOffsetForAligningPage:(SPStackedPageContainer*)pageC position:(SPStackedNavigationPagePosition)position;
- (SPStackedPageContainer*)containerForViewController:(UIViewController*)viewController;
@end

@protocol SPStackedNavigationScrollViewDelegate <NSObject>
- (void)stackedNavigationScrollView:(SPStackedNavigationScrollView *)stackedNavigationScrollView
             didStopAtPageContainer:(SPStackedPageContainer *)stackedPageContainer
                       pagePosition:(SPStackedNavigationPagePosition)pagePosition;
@end