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

#import "SPStackedNavigationScrollView.h"
#import "SPStackedPageContainer.h"
#import <QuartzCore/QuartzCore.h>
#import "SPFunctional-mini.h"

#ifndef CLAMP
#define CLAMP(v, min, max) ({ \
    __typeof(v) _v = v; \
    __typeof(min) _min = min; \
    __typeof(max) _max = max; \
    MAX(_min, MIN(_v, _max)); \
})
#endif

#define fcompare(actual, expected, epsilon) ({ \
    __typeof(actual) _actual = actual; \
    __typeof(expected) _expected = expected; \
    __typeof(epsilon) _epsilon = epsilon; \
    fabs(_actual - _expected) < _epsilon; \
})
#define fsign(f) ({ __typeof(f) _f = f; _f > 0. ? 1. : (_f < 0.) ? -1. : 0.; })

static const CGFloat kScrollDoneMarginOvershoot = 3;
static const CGFloat kScrollDoneMarginNormal = 1;
static const CGFloat kPanCaptureAngle = ((55.f) / 180.f * M_PI);
static const CGFloat kPanScrollViewDeceleratingCaptureAngle = ((40.f) / 180.f * M_PI);

@interface SPStackedNavigationScrollView () <UIGestureRecognizerDelegate>
@property(nonatomic,retain) UIPanGestureRecognizer *scrollRec;
@property(nonatomic,retain) CADisplayLink *scrollAnimationTimer;
@property(nonatomic,copy) void(^onScrollDone)();
- (void)scrollGesture:(UIPanGestureRecognizer*)grec;
- (void)updateContainerVisibilityByShowing:(BOOL)doShow byHiding:(BOOL)doHide;
@end

@implementation SPStackedNavigationScrollView {
    CGPoint _actualOffset;
    CGPoint _targetOffset;
    CGPoint _scrollAtStartOfPan;
    CGFloat _scrollDoneMargin;
    BOOL    _runningRunLoop;
    BOOL    _inRunLoop;
}
@synthesize scrollRec = _scrollRec;
@synthesize scrollAnimationTimer = _scrollAnimationTimer;
@synthesize onScrollDone = _onScrollDone;
@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame
{
    if (!(self = [super initWithFrame:frame]))
        return nil;
    
    self.scrollRec = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(scrollGesture:)];
    _scrollRec.maximumNumberOfTouches = 1;
    _scrollRec.delaysTouchesBegan = _scrollRec.delaysTouchesEnded = NO;
    _scrollRec.cancelsTouchesInView = YES;
    _scrollRec.delegate = self;

    [self addGestureRecognizer:_scrollRec];
    
    return self;
}

#pragma mark Gesture recognizing
- (NSRange)scrollRangeForPageContainer:(SPStackedPageContainer*)pageC
{
    CGFloat width = 0.;
    for(SPStackedPageContainer *pc in self.subviews)
    {
        if (pc == pageC)
            break;
        if (pc.vc.stackedNavigationPageSize == kStackedPageFullSize)
            width += self.frame.size.width;
        else
            width += pc.frame.size.width;
    }
    return NSMakeRange(width, (pageC.vc.stackedNavigationPageSize  == kStackedPageFullSize ?
                               self.frame.size.width : 
                               pageC.frame.size.width));
}

- (NSRange)scrollRange
{
    return [self scrollRangeForPageContainer:[self.subviews lastObject]];
}

- (CGFloat)scrollOffsetForAligningPageWithRightEdge:(SPStackedPageContainer*)pageC
{
    NSRange scrollRange = [self scrollRangeForPageContainer:pageC];
    return scrollRange.location // align left edge with left edge of screen
        - self.frame.size.width // scroll it completely out of screen to the right
        + scrollRange.length; // scroll it back just so it's exactly on screen.
}

- (CGFloat)scrollOffsetForAligningPageWithLeftEdge:(SPStackedPageContainer*)pageC
{
    NSRange scrollRange = [self scrollRangeForPageContainer:pageC];
    return scrollRange.location;
}

- (CGFloat)scrollOffsetForAligningPage:(SPStackedPageContainer*)pageC position:(SPStackedNavigationPagePosition)position
{
    return (position == SPStackedNavigationPagePositionLeft ? 
            [self scrollOffsetForAligningPageWithLeftEdge:pageC] :
            [self scrollOffsetForAligningPageWithRightEdge:pageC]);
}

- (SPStackedPageContainer*)containerForViewController:(UIViewController*)viewController
{
    for (SPStackedPageContainer *pc in self.subviews)
    {
        if (pc.vc == viewController)
            return pc;
    }
    return nil;
}

- (void)scrollAndSnapWithVelocity:(float)vel animated:(BOOL)animated
{
    // this is ugly, but we need to ensure that all views are loaded correctly to calculate left/right containers
    [self setNeedsLayout];
    [self layoutIfNeeded];
    
    // If swiping to the left, snap to the left; and vice versa.    
    CGFloat targetPoint;
    SPStackedPageContainer *target = nil;
    
    SPStackedPageContainer *left = [self.subviews spstacked_any:^BOOL(id obj) { return [obj VCVisible]; }];
    SPStackedPageContainer *right = [self.subviews spstacked_filter:^BOOL(id obj) { return [obj VCVisible]; }].lastObject;
    
    if (vel < 0) // trying to reveal to the left
        target = left;
    else // trying to reveal to the right
        target = right;
    
    // scroll extra far if user scrolls really fast
    int extraMove = (fabs(vel) > 8500 ? 2 : (fabs(vel) > 5500) ? 1 : 0)*fsign(vel);
    if (extraMove != 0)
        target = (self.subviews)[CLAMP((int)[self.subviews indexOfObject:target]+extraMove, 0, (int)(self.subviews.count-1))];
    
    // Align with left edge if scrolling left, or vice versa
    NSRange leftScrollRange = [self scrollRangeForPageContainer:left];
    if (vel < 0 && extraMove == 0 && _actualOffset.x > (leftScrollRange.location + leftScrollRange.length/2)) {
        SPStackedPageContainer *targetView = (self.subviews)[CLAMP((int)[self.subviews indexOfObject:left]+1, 0, (int)(self.subviews.count-1))];
        if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]))
            target = targetView;
        targetPoint = [self scrollOffsetForAligningPageWithRightEdge:targetView];
    } else if (vel < 0)
        targetPoint = [self scrollRangeForPageContainer:target].location;
    else
        targetPoint = [self scrollOffsetForAligningPageWithRightEdge:target];
    
    // Overshoot the target a bit
    if (animated)
    {
        __weak typeof(self) weakSelf = self;
        self.onScrollDone = ^{
            __strong __typeof(self) strongSelf = weakSelf;
            [strongSelf setContentOffset:CGPointMake(targetPoint, 0) animated:animated];
            [strongSelf->_delegate stackedNavigationScrollView:strongSelf
                            didStopAtPageContainer:target
                                      pagePosition:(target == left ? SPStackedNavigationPagePositionLeft :
                                                    SPStackedNavigationPagePositionRight)];
        };
    }
    
    targetPoint += MAX(10, fabs(vel/150))*fsign(vel);
    
    [self setContentOffset:CGPointMake(targetPoint, 0) animated:animated];
    _scrollDoneMargin = kScrollDoneMarginOvershoot;
    
    if (!animated)
        [_delegate stackedNavigationScrollView:self
                        didStopAtPageContainer:target
                                  pagePosition:(target == left ? SPStackedNavigationPagePositionLeft :
                                                SPStackedNavigationPagePositionRight)];
}


- (void)scrollGesture:(UIPanGestureRecognizer*)grec
{
    if (grec.state == UIGestureRecognizerStateBegan) {
        _scrollAtStartOfPan = _actualOffset;
        [self startRunLoop];
    }
    else if (grec.state == UIGestureRecognizerStateChanged) {
        self.contentOffset = CGPointMake(_scrollAtStartOfPan.x-[grec translationInView:self].x, 0);
    } else if (grec.state == UIGestureRecognizerStateFailed || grec.state == UIGestureRecognizerStateCancelled) {
        [self stopRunLoop];
        [self setContentOffset:_scrollAtStartOfPan animated:YES];
    } else if (grec.state == UIGestureRecognizerStateRecognized) {
        // minus: swipe left means navigate to VC to the right
        [self stopRunLoop];
        [self scrollAndSnapWithVelocity:-[grec velocityInView:self].x animated:YES];
    }
}

- (void)startRunLoop
{
    if (!_runningRunLoop)
    {
        _runningRunLoop = YES;
        CFRunLoopPerformBlock(CFRunLoopGetCurrent(), kCFRunLoopDefaultMode, ^{
            if (_inRunLoop)
                return;
            _inRunLoop = YES;
            while (_runningRunLoop)
                [[NSRunLoop currentRunLoop] runMode:UITrackingRunLoopMode beforeDate:[NSDate distantFuture]];
            _inRunLoop = NO;
        });
    }
}

- (void)stopRunLoop
{
    _runningRunLoop = NO;
}

- (void)snapToClosest
{
    [self scrollAndSnapWithVelocity:0 animated:NO];
}

- (UIPanGestureRecognizer *)panGestureRecognizer { return self.scrollRec; }

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer
{
    CGPoint velocity = [gestureRecognizer velocityInView:[gestureRecognizer view]];
    CGFloat angle = velocity.x == 0.0 ?: atanf(fabsf(velocity.y / velocity.x));

    CGFloat captureAngle = kPanCaptureAngle;
    if ([[gestureRecognizer view] isKindOfClass:[UIScrollView class]] && [(UIScrollView*)[gestureRecognizer view] isDecelerating])
        captureAngle = kPanScrollViewDeceleratingCaptureAngle;

    return captureAngle >= angle;
}

#pragma mark Animating content offset
@synthesize contentOffset = _targetOffset;
- (void)setContentOffset:(CGPoint)contentOffset
{
    [self setContentOffset:contentOffset animated:NO];
}

- (void)scrollAnimationFrame:(CADisplayLink*)cdl
{
    if (fcompare(_targetOffset.x, _actualOffset.x, _scrollDoneMargin)) {
        [self.scrollAnimationTimer invalidate]; self.scrollAnimationTimer = nil;
        [self setNeedsLayout];
        _actualOffset = _targetOffset;
        if (_onScrollDone) {
            self.onScrollDone();
            self.onScrollDone = nil;
        } else
            // we're done animating, hide everything that needs to be hidden
            [self updateContainerVisibilityByShowing:YES byHiding:YES];

        // TODO<nevyn>: Unblock processing
    }
    NSTimeInterval delta = cdl.duration;
    CGFloat diff = _targetOffset.x - _actualOffset.x;
    CGFloat movementPerSecond = CLAMP(abs(diff)*14, 20, 4000)*fsign(diff);
    CGFloat movement = movementPerSecond * delta;
    
    if (abs(movement) > abs(diff)) movement = diff; // so we never step over the target point
    
    _actualOffset.x += movement;
    [self setNeedsLayout];
}
- (void)animateToTargetScrollOffset
{
    if (_scrollAnimationTimer) return;
    _scrollDoneMargin = kScrollDoneMarginNormal;
    self.scrollAnimationTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(scrollAnimationFrame:)];
    [_scrollAnimationTimer addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    // TODO<nevyn>: Block processing
}


- (void)setContentOffset:(CGPoint)contentOffset animated:(BOOL)animated
{
    _targetOffset = contentOffset;
    if (animated)
        [self animateToTargetScrollOffset];
    else {
        _actualOffset = _targetOffset;
        if (_onScrollDone)
        {
            self.onScrollDone();
            self.onScrollDone = nil;
        }
        [self setNeedsLayout];
    }                                                                                                                         
}



- (void)layoutSubviews
{
    CGRect pen = CGRectZero;
    pen.origin.x = -_actualOffset.x;
    
    // stretch scroll at start and end
    if (_actualOffset.x < 0)
        pen.origin.x = -_actualOffset.x/2;
    CGFloat maxScroll = [self scrollOffsetForAligningPageWithRightEdge:self.subviews.lastObject];
    if (_actualOffset.x > maxScroll)
        pen.origin.x = -(maxScroll + (_actualOffset.x-maxScroll)/2);

    int i = 0;
    CGFloat markedForSuperviewRemovalOffset = pen.origin.x;
    NSMutableArray *stackedViews = [NSMutableArray array];
    for(SPStackedPageContainer *pageC in self.subviews) {
        pen.size = pageC.bounds.size;
        pen.size.height = self.frame.size.height;
        if (pageC.vc.stackedNavigationPageSize == kStackedPageFullSize)
            pen.size.width = self.frame.size.width;
        
        CGRect actualPen = pen;
        if (pageC.markedForSuperviewRemoval)
            actualPen.origin.x = markedForSuperviewRemovalOffset;
        // Stack on the left
        if (actualPen.origin.x < (MIN(i, 3))*3)
            [stackedViews addObject:pageC];
        else
            pageC.hidden = NO;
        if (self.scrollAnimationTimer == nil)
            actualPen.origin.x = floorf(actualPen.origin.x);
        pageC.frame = actualPen;
        markedForSuperviewRemovalOffset += pen.size.width;
        if (!pageC.markedForSuperviewRemoval)
            pen.origin.x += pen.size.width;
        
        if (actualPen.origin.x <= 0 && pageC != [self.subviews lastObject]) {
            pageC.overlayOpacity = 0.3/actualPen.size.width*abs(actualPen.origin.x);
        } else {
            pageC.overlayOpacity = 0.0;
        }

        i++;
    }
    
    i = 0;
    for (NSInteger index = 0; index < [stackedViews count]; index++)
    {
        SPStackedPageContainer *pageC = stackedViews[index];
        if ([stackedViews count] > 3 && index < ([stackedViews count]-3))
            pageC.hidden = YES;
        else
        {
            pageC.hidden = NO;
            CGRect frame = pageC.frame;
            frame.origin.x = 0 + MIN(i, 3)*3;
            pageC.frame = frame;
            
            i++;
        }
    }
    
    // Only make sure we show what we need to, don't unload stuff until we're done animating
    [self updateContainerVisibilityByShowing:YES byHiding:NO];
}

#pragma mark Visibility
- (void)updateContainerVisibilityByShowing:(BOOL)doShow byHiding:(BOOL)doHide
{
    BOOL bouncing = self.scrollAnimationTimer && fabsf(_targetOffset.x - _actualOffset.x) < 30;
    CGFloat pen = -_actualOffset.x;
    
    // stretch scroll at start and end
    if (_actualOffset.x < 0)
        pen = -_actualOffset.x/2;
    CGFloat maxScroll = [self scrollOffsetForAligningPageWithRightEdge:self.subviews.lastObject];
    if (_actualOffset.x > maxScroll)
        pen = -(maxScroll + (_actualOffset.x-maxScroll)/2);
    
    CGFloat markedForSuperviewRemovalOffset = pen;
    NSMutableArray *viewsToDelete = [NSMutableArray array];
    for(SPStackedPageContainer *pageC in self.subviews) {
        CGFloat currentPen = pen;
        if (pageC.markedForSuperviewRemoval)
            currentPen = markedForSuperviewRemovalOffset;
        
        BOOL isOffScreenToTheRight = currentPen >= self.bounds.size.width;
        NSRange scrollRange = [self scrollRangeForPageContainer:pageC];
        BOOL isCovered = currentPen + scrollRange.length <= 0;
        BOOL isVisible = !isOffScreenToTheRight && !isCovered;
        
        if (pageC.VCVisible != isVisible && ((!isVisible && doHide) || (isVisible && doShow)))
        {
            if (!isVisible || !bouncing || (isVisible && pageC.needsInitialPresentation)) {
                pageC.needsInitialPresentation = NO;
                pageC.VCVisible = isVisible;
            }
        }
        if (doHide && pageC.markedForSuperviewRemoval)
            [viewsToDelete addObject:pageC];
        markedForSuperviewRemovalOffset += pageC.frame.size.width;
        if (!pageC.markedForSuperviewRemoval)
            pen += pageC.frame.size.width;
    }
    
    [viewsToDelete makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

@end
