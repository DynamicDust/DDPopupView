//
//  ViewController.m
//  DDPopupViewExample
//
//  Created by Dominik Hádl on 12/06/14.
//  Copyright (c) 2014 DynamicDust s.r.o. All rights reserved.
//

#import "ViewController.h"
#import "DDPopupView.h"

@implementation ViewController
            
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showPopupPressed:(id)sender
{
    // Create and setup the popup view
    DDPopupView *popupView = [DDPopupView popupView];
    [popupView showInView:self.view];
    [popupView setBackgroundColor:[UIColor colorWithRed:46.0f/255.0f green:204.0f/255.0f blue:113.0f/255.0f alpha:1.0]];
    
    // Create and add the hide button
    UIButton *hideButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [hideButton setTitle:@"Hide Popup" forState:UIControlStateNormal];
    [hideButton addTarget:popupView action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
    [hideButton setTitleColor:[UIColor colorWithRed:39.0f/255.0f green:174.0f/255.0f blue:96.0f/255.0f alpha:1.0] forState:UIControlStateNormal];
    [popupView addSubview:hideButton];
    
    // Position the hide button
    CGSize superViewSize = hideButton.superview.frame.size;
    CGPoint center       = CGPointMake(superViewSize.width / 2, superViewSize.height / 2);
    [hideButton setFrame:CGRectMake(0, 0, superViewSize.width, superViewSize.height)];
    [hideButton setCenter:center];
}

@end
