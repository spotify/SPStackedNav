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

#import "SPSeparatorView.h"

@interface SPSeparatorView ()
{
    SPSeparatorStyle    _style;
    NSArray *           _colors;
}
@end

@implementation SPSeparatorView

- (void)commonSetup
{
    [self setBackgroundColor:[UIColor clearColor]];
    [self setOpaque:NO];
}

- (id)init
{
    if (!(self = [super init]))
        return nil;
    
    [self commonSetup];
    
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    if (!(self = [super initWithFrame:frame]))
        return nil;
    
    [self commonSetup];
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (!(self = [super initWithCoder:aDecoder]))
        return nil;
    
    [self commonSetup];
    
    return self;
}


#pragma mark Style

- (SPSeparatorStyle)style { return _style; }
- (void)setStyle:(SPSeparatorStyle)style
{
    if (_style != style)
    {
        _style = style;
        [self setNeedsDisplay];
    }
}


- (NSArray *)colors { return _colors; }
- (void)setColors:(NSArray *)colors
{
    if (![_colors isEqualToArray:colors])
    {
        _colors = [colors copy];
        [self setNeedsDisplay];
    }
}


#pragma mark Drawing

- (NSArray*)_actualColors
{
    NSMutableArray *colors = [NSMutableArray array];
    if ([self colors])
        [colors addObjectsFromArray:[self colors]];
    if ([colors count] == 0)
        [colors addObject:[UIColor colorWithWhite:0.0 alpha:0.25]];
    if ([self style] == SPSeparatorStyleSingleLineEtched && [colors count] < 2)
        [colors addObject:[UIColor colorWithWhite:1.0 alpha:1.0]];
    // you should never return a mutable instance, but who cares here?
    return colors;
}

- (void)drawRect:(CGRect)rect
{
    NSArray *colors = [self _actualColors];
    
    if ([self style] == SPSeparatorStyleSingleLine)
    {
        [colors[0] setFill];
        UIRectFill(rect);
    }
    else
    {
        CGRect frame = rect;
        if (frame.size.width > frame.size.height)
        {
            frame.size.height /= 2;
            [colors[0] setFill];
            UIRectFill(CGRectIntegral(frame));
            frame.origin.y += frame.size.height;
            [colors[1] setFill];
            UIRectFill(CGRectIntegral(frame));
        }
        else
        {
            frame.size.width /= 2;
            [colors[0] setFill];
            UIRectFill(CGRectIntegral(frame));
            frame.origin.x += frame.size.width;
            [colors[1] setFill];
            UIRectFill(CGRectIntegral(frame));
        }
    }
}

@end
