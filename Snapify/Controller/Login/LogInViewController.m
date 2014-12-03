//
//  LogInViewController.m
//  Snapify (from original AnyPic)
//
//  Modified by Christopher Coudriet on 12/31/13 (Created by Héctor Ramos on 5/04/12)
//  Copyright (c) 2013 Christopher Coudriet / 2012 Héctor Ramos. All rights reserved.
//

#import "LogInViewController.h"
#import "AppDelegate.h"
#import "SVModalWebViewController.h"

@interface LogInViewController ()
@end

@implementation LogInViewController

@synthesize checkboxSelected;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.logInView.facebookButton.enabled = NO;
    
    UIImageView *loginBackgroundImageView = [[UIImageView alloc] initWithImage:nil];
    [loginBackgroundImageView setImage:[UIImage imageNamed:@"loginBg.png"]];
    [loginBackgroundImageView setFrame:CGRectMake( 0.0f, 0.0f, 320.0f, 568.0f)];
    [self.logInView insertSubview:loginBackgroundImageView atIndex:0];
    
    UIButton *checkboxButton = [[UIButton alloc] initWithFrame:CGRectMake(36.0f, 417.0f, 45.0f, 45.0f)];
    [checkboxButton setImage:[UIImage imageNamed:@"checkBox.png"] forState:UIControlStateNormal];
    // uncomment below to see the hit area
    // [checkboxButton setBackgroundColor:[UIColor redColor]];
    [checkboxButton addTarget:self action:@selector(didTapCheckbox:) forControlEvents: UIControlEventTouchUpInside];
    [checkboxButton setImageEdgeInsets:UIEdgeInsetsMake(0.0f, -1.0f, 0.0f, 0.0f)];
    
    UILabel *checkBoxLabel = [[UILabel alloc] initWithFrame:CGRectMake(80.0f, 430.0f, 200.0f, 20.0f)];
    [checkBoxLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:16.0f]];
    [checkBoxLabel setTextColor:[UIColor whiteColor]];
    [checkBoxLabel setBackgroundColor:[UIColor clearColor]];
    [checkBoxLabel setText:@"I agree to the "];
    
    UIButton *termsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [termsButton setFrame:CGRectMake( 177.0f, 431.0f, 100.0f, 20.0f)];
    [termsButton setBackgroundColor:[UIColor clearColor]];
    [termsButton setTitle:@"Terms of Use." forState:UIControlStateNormal];
    [termsButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [termsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [termsButton setTitleEdgeInsets:UIEdgeInsetsMake( -0.0f, 0.0f, 0.0f, 0.0f)];
    [[termsButton titleLabel] setFont:[UIFont fontWithName:@"HelveticaNeue" size:16.0f]];
    [termsButton addTarget:self action:@selector(didTapTermsButtonAction:) forControlEvents:UIControlEventTouchUpInside];

    NSString *welcomeText = @"Sign in and start sharing your story with your friends.";
    CGSize welcomeTextSize = [welcomeText sizeWithFont:[UIFont fontWithName:@"HelveticaNeue" size:18.0f] constrainedToSize:CGSizeMake( 255.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    UILabel *welcomeTextLabel = [[UILabel alloc] initWithFrame:CGRectMake( ([UIScreen mainScreen].bounds.size.width - welcomeTextSize.width)/2.0f, 330.0f, welcomeTextSize.width, welcomeTextSize.height)];
    [welcomeTextLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:18.0f]];
    [welcomeTextLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [welcomeTextLabel setNumberOfLines:0];
    [welcomeTextLabel setText:welcomeText];
    [welcomeTextLabel setTextColor:[UIColor whiteColor]];
    [welcomeTextLabel setBackgroundColor:[UIColor clearColor]];
    [welcomeTextLabel setTextAlignment:NSTextAlignmentCenter];
    
    [self.logInView setLogo:nil];
    
    [self.logInView addSubview:checkboxButton];
    [self.logInView addSubview:checkBoxLabel];
    [self.logInView addSubview:welcomeTextLabel];
    [self.logInView addSubview:termsButton];
}

- (void)didTapCheckbox:(id)sender {
    
    checkboxSelected = !checkboxSelected;
    UIButton *check = (UIButton*) sender;
    if (checkboxSelected == NO)
    {
        self.logInView.facebookButton.enabled = NO;
        [check setImage:[UIImage imageNamed:@"checkBox.png"] forState:UIControlStateNormal];
    }
    else
    {
        self.logInView.facebookButton.enabled = YES;
        [check setImage:[UIImage imageNamed:@"checkBoxChecked.png"] forState:UIControlStateNormal];
    }
}

- (void)didTapTermsButtonAction:(id)sender {
    
    NSLog(@"didTapTermsButtonAction");
    
    SVModalWebViewController *webViewController = [[SVModalWebViewController alloc] initWithAddress:@"http://yourserver.com/snapify/termsofuse.html"];
    
    [self presentViewController:webViewController animated:YES completion:nil];
}

@end
