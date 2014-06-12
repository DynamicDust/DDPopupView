//
//  DDPopupView.m
//  DDBetaFeedback
//
//  Created by Dominik Hádl on 12/06/14.
//  Copyright (c) 2014 DynamicDust. All rights reserved.
//
// ---------------------------------------------------------------------
#import "DDPopupView.h"

@import QuartzCore;
// ---------------------------------------------------------------------

const NSTimeInterval kDDPopupViewAnimationDuration = 0.4f;

NSString *const kDDPopupViewAnimationShowKey = @"DDPopupViewShowAnimation";
NSString *const kDDPopupViewAnimationHideKey = @"DDPopupViewHideAnimation";

// ---------------------------------------------------------------------
@interface DDPopupView ()
// ---------------------------------------------------------------------

@property (nonatomic, weak) UIView *overlayView;
@property (nonatomic, weak) UIView *popupView;

@property (nonatomic, strong) CABasicAnimation *showAnimation;
@property (nonatomic, strong) CABasicAnimation *hideAnimation;

// ---------------------------------------------------------------------
@end
// ---------------------------------------------------------------------

@implementation DDPopupView

// ---------------------------------------------------------------------
#pragma mark - Init & Dealloc -
// ---------------------------------------------------------------------

+ (instancetype)popupView
{
    return [[self alloc] init];
}

// ---------------------------------------------------------------------

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        CGRect screenFrame  = [UIScreen mainScreen].bounds;
        CGRect popupFrame   = CGRectMake(0, 0,
                                         screenFrame.size.width * 0.8,
                                         screenFrame.size.height * 0.7);
        
        // Set own frame
        self.frame = screenFrame;
        
        // Set defaults
        self.removeOnHide  = YES;
        self.dimBackground = YES;
        
        // Create the overlay
        UIView *overlayView         = [[UIView alloc] initWithFrame:screenFrame];
        overlayView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        overlayView.alpha           = 0.0f;
        self.overlayView            = overlayView;
        
        // Create the popup view
        UIView *popupView           = [[UIView alloc] initWithFrame:popupFrame];
        popupView.center            = [self offScreenCenterForView:popupView];
        popupView.backgroundColor   = [UIColor whiteColor];
        self.popupView              = popupView;
        
        // Some popup customizations
        popupView.layer.cornerRadius  = 5;
        popupView.layer.masksToBounds = YES;
        
        // Add the subviews to self
        [self addSubviewToSelf:self.overlayView];
        [self addSubviewToSelf:self.popupView];
        
        [self prepareAnimations];
    }
    return self;
}

// ---------------------------------------------------------------------
#pragma mark - Animations -
#pragma mark Init
// ---------------------------------------------------------------------

- (void)prepareAnimations
{
    // -------------------------
    // Create the show animation
    // -------------------------
    
    CABasicAnimation *showAnimation = [CABasicAnimation animationWithKeyPath:@"position.y"];
    
    // Set from and to values
    [showAnimation setFromValue:[NSNumber numberWithFloat:[self offScreenCenterForView:self.popupView].y]];
    [showAnimation setToValue:[NSNumber numberWithFloat:self.center.y]];
    
    // Set the animation duration
    [showAnimation setDuration:kDDPopupViewAnimationDuration];
    
    // Do not remove on completion
    [showAnimation setRemovedOnCompletion:NO];
    [showAnimation setFillMode:kCAFillModeForwards];
    
    // Create the bounce out effect
    CAMediaTimingFunction *bounceOut = nil;
    bounceOut = [CAMediaTimingFunction functionWithControlPoints:0.5 :1.8 :0.2 :0.8];
    [showAnimation setTimingFunction:bounceOut];
    
    // Set self as the delegate
    [showAnimation setDelegate:self];
    
    // -------------------------
    // Create the hide animation
    // -------------------------
    
    // Make a copy from the previous
    CABasicAnimation *hideAnimation = [showAnimation copy];
    
    // Set from and to values
    [hideAnimation setFromValue:showAnimation.toValue];
    [hideAnimation setToValue:showAnimation.fromValue];
    
    // Create the bounce in effect
    CAMediaTimingFunction *bounceIn = nil;
    bounceIn = [CAMediaTimingFunction functionWithControlPoints:0.5 :-0.6 :0.8 :0.4];
    [hideAnimation setTimingFunction:bounceIn];
    
    // -------------------------
    
    // Assign to properties
    self.showAnimation = showAnimation;
    self.hideAnimation = hideAnimation;
}

// ---------------------------------------------------------------------
#pragma mark Controls
// ---------------------------------------------------------------------

- (void)show
{
    if (!self.superview)
    {
        [NSException raise:@"DDPopupView has no superview."
                    format:@"DDPopupView needs to be added to a superview before animating."];
    }
    
    // Animate the overlay
    if (self.dimBackground)
    {
        [UIView beginAnimations:@"DDPopupViewAnimationOverlayShow" context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        [UIView setAnimationDuration:kDDPopupViewAnimationDuration];

        self.overlayView.alpha = 1.0f;

        [UIView commitAnimations];
    }
    
    // Animate the popup
    [self.popupView.layer addAnimation:self.showAnimation
                                forKey:kDDPopupViewAnimationShowKey];

    // Fix the frame after animation
    self.popupView.center = self.center;
}

// ---------------------------------------------------------------------

- (void)showInView:(UIView *)view
{
    [self removeFromSuperview];
    [view addSubview:self];
    
    [self show];
}

// ---------------------------------------------------------------------

- (void)hide
{
    if (!self.superview)
    {
        [NSException raise:@"DDPopupView has no superview."
                    format:@"DDPopupView needs to be added to a superview before animating."];
    }
    
    // Animate the overlay
    if (self.dimBackground)
    {
        [UIView beginAnimations:@"DDPopupViewAnimationOverlayHide" context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        [UIView setAnimationDuration:kDDPopupViewAnimationDuration];
        
        self.overlayView.alpha = 0.0f;
        
        [UIView commitAnimations];
    }
    
    // Animate the popup
    [self.popupView.layer addAnimation:self.hideAnimation
                                forKey:kDDPopupViewAnimationHideKey];
    
    // Fix the frame after animation
    self.popupView.center = [self offScreenCenterForView:self.popupView];
}

// ---------------------------------------------------------------------
#pragma mark CAAnimation Delegate
// ---------------------------------------------------------------------

- (void)animationDidStop:(CABasicAnimation *)anim
                finished:(BOOL)flag
{
    CAAnimation *hideAnimation = [self.popupView.layer animationForKey:kDDPopupViewAnimationHideKey];
    
    if (self.removeOnHide && [anim isEqual:hideAnimation])
            [self removeFromSuperview];
}

// ---------------------------------------------------------------------
#pragma mark - Helpers -
// ---------------------------------------------------------------------

- (CGPoint)offScreenCenterForView:(UIView *)view
{
    CGSize selfSize = self.frame.size;
    CGSize viewSize = view.frame.size;
    return (CGPoint){selfSize.width / 2, selfSize.height + (viewSize.height / 2)};
}

// ---------------------------------------------------------------------
#pragma mark - Overrides -
#pragma mark Add Subview
// ---------------------------------------------------------------------

- (void)addSubview:(UIView *)view
{
    [self.popupView addSubview:view];
}

// ---------------------------------------------------------------------

- (void)addSubviewToSelf:(UIView *)view
{
    [super addSubview:view];
}

// ---------------------------------------------------------------------
#pragma mark Background Color
// ---------------------------------------------------------------------

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [self.popupView setBackgroundColor:backgroundColor];
}

// ---------------------------------------------------------------------

- (void)setBackgroundColorToSelf:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
}

// ---------------------------------------------------------------------
@end
