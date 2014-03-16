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

#import "SPSideTabItemButton.h"

@implementation SPSideTabItemButton
- (id)initWithFrame:(CGRect)frame {
    if (!(self = [super initWithFrame:frame])) return nil;
    
    UILabel *label = [self titleLabel];
    label.font = [UIFont boldSystemFontOfSize:11];
    label.shadowOffset = CGSizeMake(0, -1);
    
    [self setTitleShadowColor:[UIColor colorWithWhite:0.0 alpha:0.7] forState:UIControlStateNormal];
    [self setTitleColor:[UIColor colorWithWhite:0.663 alpha:1.000] forState:UIControlStateNormal];
    [self setTitleColor:[UIColor colorWithWhite:0.925 alpha:1.000] forState:UIControlStateSelected];
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    UIImageView *imageView = [self imageView];
    UILabel *label = [self titleLabel];
    
    [imageView sizeToFit];
    [label sizeToFit];
    
    CGRect imageFrame = imageView.frame;
    CGRect labelFrame = label.frame;
    
    imageFrame.origin.y = 4;
    labelFrame.origin.y = 46;
    
    imageFrame.origin.x = roundf((self.bounds.size.width - imageFrame.size.width) / 2);
    labelFrame.origin.x = roundf((self.bounds.size.width - labelFrame.size.width) / 2);
    
    imageView.frame = imageFrame;
    label.frame = labelFrame;
    
    if (self.badgeView){
        CGPoint center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
        self.badgeView.center = CGPointMake(floorf(center.x + center.x/3), floorf(center.y - center.y/2));
        self.badgeView.frame = CGRectIntegral(self.badgeView.frame);
    }
}

- (void)setBadgeView:(UIView *)badgeView
{
    [_badgeView removeFromSuperview];
    _badgeView = badgeView;
    if (badgeView)
        [self addSubview:badgeView];
    [self setNeedsLayout];
}

@end

