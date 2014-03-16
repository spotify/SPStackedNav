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

#import "SPStackedPageContainer.h"
#import "SPSeparatorView.h"
#import <QuartzCore/QuartzCore.h>
#include <sys/sysctl.h>
#import "SPStackedNavigationController.h"

// AKA "is too slow for transparency"
static BOOL IsIPad11() {
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = (char *)malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *ident = @(machine);
    free(machine);
    return [ident isEqualToString:@"iPad1,1"];
}

@interface SPStackedPageContainer () <UIGestureRecognizerDelegate>
{
    UIView *    highlight;
    UIView *    leftShadow;
    CALayer *   _overlayLayer;
}
@end

@implementation SPStackedPageContainer
@synthesize vc = _vc;
@synthesize vcContainer = _vcContainer;
@synthesize screenshot = _screenshot;
@synthesize markedForSuperviewRemoval = _markedForSuperviewRemoval;
@synthesize needsInitialPresentation = _needsInitialPresentation;
@synthesize overlayOpacity = _overlayOpacity;

- (id)initWithFrame:(CGRect)frame VC:(UIViewController*)vc
{
    if (!(self = [super initWithFrame:frame]))
        return nil;
    
    self.vc = vc;
    
    self.backgroundColor = [UIColor colorWithHue:0.167 saturation:0.017 brightness:0.925 alpha:1.000];
    self.opaque = NO;
    
    if (!IsIPad11())
    {
        for(NSString *img in @[@"stackShadow.png", @"stackShadow-right.png"]) {
            UIImage *shadowImage = [[UIImage imageNamed:img] resizableImageWithCapInsets:UIEdgeInsetsMake(12, 0, 12, 0)];
            BOOL left = [img rangeOfString:@"right"].location == NSNotFound;
            UIImageView *shadow = [[UIImageView alloc] initWithFrame:CGRectMake(left ? -13 : self.bounds.size.width, 0, 13, self.bounds.size.height)];
            shadow.image = shadowImage;
            shadow.autoresizingMask = UIViewAutoresizingFlexibleHeight|(left?UIViewAutoresizingFlexibleRightMargin:UIViewAutoresizingFlexibleLeftMargin);
            shadow.userInteractionEnabled = NO;
            [self addSubview:shadow];
            if (!leftShadow)
                leftShadow = shadow;
        }
    }
    else
    {
        UIColor *color1 = [UIColor colorWithRed:0x87/255. green:0x86/255. blue:0x84/255. alpha:1];
        UIColor *color2 = [UIColor colorWithRed:0xcf/255. green:0xce/255. blue:0xcb/255. alpha:1];
        
        SPSeparatorView *separatorView = [[SPSeparatorView alloc] initWithFrame:CGRectMake(-2, 0, 2, self.bounds.size.height)];
        separatorView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin;
        separatorView.style = SPSeparatorStyleSingleLineEtched;
        separatorView.colors = @[color2,
                                color1];
        [self addSubview:separatorView];
        leftShadow = separatorView;
        
        separatorView = [[SPSeparatorView alloc] initWithFrame:CGRectMake(self.bounds.size.width, 0, 2, self.bounds.size.height)];
        separatorView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin;
        separatorView.style = SPSeparatorStyleSingleLineEtched;
        separatorView.colors = @[color1,
                                color2];
        [self addSubview:separatorView];
    }
    
    _vcContainer = [[UIView alloc] initWithFrame:self.bounds];
    _vcContainer.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [self addSubview:_vcContainer];
    
    highlight = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 1)];
    highlight.backgroundColor = [UIColor colorWithWhite:1 alpha:.46];
    highlight.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    highlight.userInteractionEnabled = NO;
    [_vcContainer addSubview:highlight];
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleGestureRecognizer:)];
    panGestureRecognizer.delegate = self;
    panGestureRecognizer.cancelsTouchesInView = NO;
    panGestureRecognizer.delaysTouchesBegan = NO;
    panGestureRecognizer.delaysTouchesEnded = NO;
    [self addGestureRecognizer:panGestureRecognizer];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGestureRecognizer:)];
    tapGestureRecognizer.delegate = self;
    tapGestureRecognizer.cancelsTouchesInView = NO;
    tapGestureRecognizer.delaysTouchesBegan = NO;
    tapGestureRecognizer.delaysTouchesEnded = NO;
    [self addGestureRecognizer:tapGestureRecognizer];
    
    self.needsInitialPresentation = YES;
    
    if (!IsIPad11()) {
        _overlayLayer = [CALayer layer];
        _overlayLayer.frame = _vcContainer.bounds;
        _overlayLayer.backgroundColor = [[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0] CGColor];
        _overlayLayer.opacity = 0.0;
        [_vcContainer.layer addSublayer:_overlayLayer];
    }
    
    return self;
}


- (BOOL)isEqual:(id)object
{
    return [super isEqual:object] || [_vc isEqual:object] ||
        ([object isKindOfClass:[self class]] && [self.vc isEqual: [object vc]]);
}
- (NSString*)description
{
    return [NSString stringWithFormat:@"<%@ %p: %@>", NSStringFromClass(self.class), self, self.vc];
}
- (void)setVCVisible:(BOOL)VCVisible
{
    if (VCVisible == self.VCVisible) return;
    
    if (VCVisible) {
        [self.screenshot removeFromSuperview];
        self.screenshot = nil;
        if (!self.markedForSuperviewRemoval || [_vc isViewLoaded])
        {
            _vcContainer.backgroundColor = _vc.view.backgroundColor;
            _vc.view.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
            if (!_vc.view.superview)
                [_vcContainer insertSubview:_vc.view atIndex:0];
        }
    } else {
        //self.screenshot = [[[UIImageView alloc] initWithImage:_vc.view.sp_screenshot] autorelease];
        if ([_vc isViewLoaded])
            [_vc.view removeFromSuperview];
        //[_vcContainer insertSubview:_screenshot atIndex:0];
    }
}
- (BOOL)VCVisible
{
    return _vc.isViewLoaded && _vc.view.superview;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    leftShadow.hidden = (frame.origin.x == 0);
}

- (void)layoutSubviews
{
    if ([_vc isViewLoaded])
        _vc.view.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    highlight.frame = CGRectMake(0, 0, self.bounds.size.width, 1);
}

- (void)handleGestureRecognizer:(UIGestureRecognizer*)gestureRecognizer
{
    if (([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]] && [gestureRecognizer state] == UIGestureRecognizerStateEnded) ||
        ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && [gestureRecognizer state] == UIGestureRecognizerStateChanged))
        [self.vc activateInStackedNavigationAnimated:YES];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return ![(id)self.vc isActiveInStackedNavigation];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]])
    {
        CGPoint translation = [(UIPanGestureRecognizer*)gestureRecognizer translationInView:[gestureRecognizer view]];
        return (fabsf(translation.y) > fabsf(translation.x));
    }
    return YES;
}


#pragma mark - Overlay opacity
- (CGFloat)overlayOpacity
{
    return _overlayLayer.opacity;
}

- (void)setOverlayOpacity:(CGFloat)overlayOpacity
{
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    _overlayLayer.opacity = overlayOpacity;
    [CATransaction commit];
}

@end
