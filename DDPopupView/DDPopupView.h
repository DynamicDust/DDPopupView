//
//  DDPopupView.h
//  DDBetaFeedback
//
//  Created by Dominik Hádl on 12/06/14.
//  Copyright (c) 2014 DynamicDust. All rights reserved.
//
// ---------------------------------------------------------------------
#import <UIKit/UIKit.h>
// ---------------------------------------------------------------------

@interface DDPopupView : UIView

// ---------------------------------------------------------------------

// Sets if the popup should remove itself on hide animation
@property (nonatomic, assign) BOOL removeOnHide;

// Sets if the background should be dimmed (and also disables touch)
@property (nonatomic, assign) BOOL dimBackground;

// Convenience constructor
+ (instancetype)popupView;

// Animation controls
- (void)show;
- (void)showInView:(UIView *)view;
- (void)hide;

// ---------------------------------------------------------------------
@end
// ---------------------------------------------------------------------
