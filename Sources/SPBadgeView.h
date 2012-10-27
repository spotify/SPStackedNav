//
//  SPBadgeView.h
//  Spotify
//
//  Created by Joachim Bengtsson on 2010-04-14.
//  Copyright 2010 Spotify. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SPBadgeView : UIControl
@property(nonatomic) NSInteger count;
@property(nonatomic, copy) NSString *text;
@property (nonatomic, retain) UIImage *backgroundImage;
@property (nonatomic, retain) UIImage *highlightedBackgroundImage;
@property (nonatomic, retain) UIFont *font;
@property (nonatomic, retain) UIColor *textColor;
@property (nonatomic, assign) BOOL textTransparentOnHighlightedAndSelected;

@end

