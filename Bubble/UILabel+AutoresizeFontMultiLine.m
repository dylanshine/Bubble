//
//  UILabel+AutoresizeFontMultiLine.m
//  Bubble
//
//  Created by Jordan Guggenheim on 8/10/15.
//  Copyright (c) 2015 Bubble. All rights reserved.
//

#import "UILabel+AutoresizeFontMultiLine.h"

@implementation UILabel (AutoresizeFontMultiLine)

- (void)adjustFontSizeToFitWithMaxSize:(CGFloat)maxFontSize{
    UIFont *font = self.font;
    CGSize size = self.frame.size;
    
    for (CGFloat maxSize = maxFontSize; maxSize >= self.minimumScaleFactor * maxFontSize; maxSize -= 1.f)
//            for (CGFloat maxSize = self.font.pointSize; maxSize >= self.minimumScaleF actor * self.font.pointSize; maxSize -= 1.f)
    {
        font = [font fontWithSize:maxSize];
        CGSize constraintSize = CGSizeMake(size.width, MAXFLOAT);
        
        CGRect textRect = [self.text boundingRectWithSize:constraintSize
                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                               attributes:@{NSFontAttributeName:font}
                                                  context:nil];
        
        CGSize labelSize = textRect.size;
        
        
        if(labelSize.height <= size.height)
        {
            self.font = font;
            [self setNeedsLayout];
            break;
        }
    }
    // set the font to the minimum size anyway
    self.font = font;
    [self setNeedsLayout]; }

@end
