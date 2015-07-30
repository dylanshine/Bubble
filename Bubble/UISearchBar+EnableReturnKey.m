//
//  UISearchBar+EnableReturnKey.m
//  Bubble
//
//  Created by Lukas Thoms on 7/29/15.
//  Copyright (c) 2015 Bubble. All rights reserved.
//

#import "UISearchBar+EnableReturnKey.h"

@implementation UISearchBar (EnableReturnKey)


- (void) alwaysEnableReturn {
    // loop around subviews of UISearchBar
    NSMutableSet *viewsToCheck = [NSMutableSet setWithArray:[self subviews]];
    while ([viewsToCheck count] > 0) {
        UIView *searchBarSubview = [viewsToCheck anyObject];
        [viewsToCheck addObjectsFromArray:searchBarSubview.subviews];
        [viewsToCheck removeObject:searchBarSubview];
        if ([searchBarSubview conformsToProtocol:@protocol(UITextInputTraits)]) {
            @try {
                // always force return key to be enabled
                [(UITextField *)searchBarSubview setEnablesReturnKeyAutomatically:NO];
                
//                [(UITextField *)searchBarSubview setKeyboardAppearance:UIKeyboardAppearanceAlert];
            }
            @catch (NSException * e) {
                // ignore exception
            }
        }
    }
}

@end
