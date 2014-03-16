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

#import "UIImage+SPTabBarImage.h"

#define $hx(x) ((x)/(float)0xff)
#define $hexcolor(x) [UIColor colorWithRed:$hx(x>>16) green:$hx((x>>8) & 0xff) blue:$hx(x&0xff) alpha:1]

static inline CGRect SPRectCenterInRectSize(CGRect rect, CGSize containerSize) {
    CGSize delta = CGSizeMake(
        (containerSize.width - rect.size.width) / 2, 
        (containerSize.height - rect.size.height) / 2
    );
    
    return CGRectIntegral(CGRectOffset(rect, delta.width, delta.height));
}

enum
{
    SPTabBarImageStateNormal = 0,
    SPTabBarImageStateSelected,
    SPTabBarImageStateSelectedHiglighted
};
typedef NSInteger SPTabBarImageState;

static UIImage *SPMakeTabBarImage(UIImage *source, SPTabBarImageState state)
{
    if (!source) return nil;
    
    UIImage *normalOverlay = [UIImage imageNamed:@"SPSideTabBar-button-overlay+normal.png"];
    UIImage *shinyOverlay = [UIImage imageNamed:@"SPSideTabBar-button-overlay+selected.png"];
    UIImage *shinyHighlightedOverlay = [UIImage imageNamed:@"SPSideTabBar-button-overlay+selected+pressed.png"];
    UIImage *overlay = nil;
    switch (state)
    {
        case SPTabBarImageStateNormal:              overlay = normalOverlay; break;
        case SPTabBarImageStateSelected:            overlay = shinyOverlay; break;
        case SPTabBarImageStateSelectedHiglighted:  overlay = shinyHighlightedOverlay; break;
        default: @throw([NSException exceptionWithName:NSCocoaErrorDomain reason:@"Invalid SPTabBarImageState" userInfo:nil]);
    }

    CGRect r = {.size={50,50}};
    CGRect centeredIcon = SPRectCenterInRectSize((CGRect){.size=source.size}, r.size);
    centeredIcon.origin = (CGPoint){(r.size.width-centeredIcon.size.width)/2, (r.size.height-centeredIcon.size.height)/2};
    centeredIcon = CGRectIntegral(centeredIcon);

    UIGraphicsBeginImageContextWithOptions(r.size, NO, [[UIScreen mainScreen] scale]);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    if (!ctx) return nil;
    
    
    if (state > SPTabBarImageStateNormal) { // Draw glow if selected
        CGContextSetShadowWithColor(ctx, (CGSize){0,0}, 10, [UIColor colorWithHue:0.246 saturation:0.622 brightness:0.527 alpha:1.0].CGColor);
        [source drawInRect:centeredIcon];
        CGContextSetShadowWithColor(ctx, (CGSize){0,0}, 0, 0);
    }
    
    // Draw outline
    CGContextSaveGState(ctx);
    CGContextTranslateCTM(ctx, 0, r.size.height);
    CGContextScaleCTM(ctx, 1.0, -1.0);
    CGContextSetAlpha(ctx, .6);
    CGContextDrawImage(ctx, CGRectOffset(centeredIcon, -1,  0), source.CGImage);
    CGContextDrawImage(ctx, CGRectOffset(centeredIcon,  1,  0), source.CGImage);
    CGContextDrawImage(ctx, CGRectOffset(centeredIcon,  0,  1), source.CGImage);
    // And a bottom highlight "shadow" below the shape
    CGContextSetShadowWithColor(ctx, CGSizeMake(0, 1), 0, [UIColor colorWithWhite:1 alpha:.05].CGColor);
    CGContextDrawImage(ctx, CGRectOffset(centeredIcon,  0, -1), source.CGImage);
    CGContextRestoreGState(ctx);
    
    
    // Draw gradient + main shape
    UIImage *gradientedImage = nil;
    {
        UIGraphicsBeginImageContextWithOptions(r.size, NO, [[UIScreen mainScreen] scale]);
        CGContextRef ctx2 = UIGraphicsGetCurrentContext();
        
        [source drawInRect:centeredIcon];
        
        CGContextSetBlendMode(ctx2, kCGBlendModeSourceIn);
        CGContextTranslateCTM(ctx2, 0, r.size.height);
        CGContextScaleCTM(ctx2, 1.0, -1.0);

        CGContextDrawImage(ctx2, r, overlay.CGImage);

        gradientedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    [gradientedImage drawInRect:r];
    
    // Draw highlight
    CGImageRef highlight = nil;
    {
        struct __attribute__((packed)) Pixel {
            union {
                struct {char r, g, b, a;} col;
                char v[4]; 
            } reps;
        };
        struct Pixel pixels[(int)(r.size.width*r.size.height)];
        memset(pixels, 0, sizeof(pixels));
        CGColorSpaceRef cspace = CGColorSpaceCreateDeviceRGB();
        CGContextRef maskContext = CGBitmapContextCreate(pixels, r.size.width, r.size.height, 8, r.size.width*4, cspace, (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
        CGColorSpaceRelease(cspace);
        CGContextTranslateCTM(maskContext, 0, r.size.height);
        CGContextScaleCTM(maskContext, 1.0, -1.0);
        
        CGContextDrawImage(maskContext, CGRectOffset(centeredIcon, 0, 1), source.CGImage);
        CGContextSetBlendMode(maskContext, kCGBlendModeSourceOut);
        CGContextDrawImage(maskContext, CGRectOffset(centeredIcon, 0, 2), source.CGImage);
        
        // black > white x_x
        for(int i = 0, c = r.size.width*r.size.height; i < c; i++) {
            float a = pixels[i].reps.col.a/(float)0xff;
            for(int j = 0; j < 3; j++) {
                float v = pixels[i].reps.v[j]/(float)0xff; // depremultiply and shift to normalized range
                v = 1.0 - v; // do the change
                pixels[i].reps.v[j] = (v * a) *  0xff; // repremultiply and shift back to char range
            }
        }
        
        UIColor *highlightColor = (state > SPTabBarImageStateNormal) ? $hexcolor(0xd6ff59) : [UIColor colorWithWhite:1 alpha:.45];
        CGContextSetBlendMode(maskContext, kCGBlendModeSourceIn);
        CGContextSetFillColorWithColor(maskContext, highlightColor.CGColor);
        CGContextFillRect(maskContext, r);
        
        highlight = CGBitmapContextCreateImage(maskContext);
        CGContextRelease(maskContext);
    }
    CGContextDrawImage(ctx, CGRectOffset(r, 0, 2), highlight);
    CGImageRelease(highlight);
    
    
    UIImage *result =  UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}


@implementation UIImage (SPTabBarImage)
- (UIImage*)sp_imageForTabBar
{
    return SPMakeTabBarImage(self, SPTabBarImageStateNormal);
}
- (UIImage*)sp_selectedImageForTabBar
{
    return SPMakeTabBarImage(self, SPTabBarImageStateSelected);
}
- (UIImage*)sp_selectedAndHighlightedImageForTabBar
{
    return SPMakeTabBarImage(self, SPTabBarImageStateSelectedHiglighted);
}
@end