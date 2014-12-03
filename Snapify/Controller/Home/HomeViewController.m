//
//  HomeViewController.m
//  Snapify (from original AnyPic)
//
//  Modified by Christopher Coudriet on 12/31/13 (Created by Héctor Ramos on 5/04/12)
//  Copyright (c) 2013 Christopher Coudriet / 2012 Héctor Ramos. All rights reserved.
//

#import "HomeViewController.h"
#import "SettingsActionSheetDelegate.h"
#import "MBProgressHUD.h"
#import "SearchUserViewController.h"


@interface HomeViewController ()
@property (nonatomic, strong) SettingsActionSheetDelegate *settingsActionSheetDelegate;
@property (nonatomic, strong) NSString *selectedEmailAddress;
@property (nonatomic, strong) UIView *blankTimelineView;
@end

@implementation HomeViewController
    
@synthesize firstLaunch;
@synthesize settingsActionSheetDelegate;
@synthesize blankTimelineView;


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.navigationItem.title = @"Find A Trainer";
    
    [self.navigationController.navigationBar setTranslucent:YES];
    
    self.navigationItem.rightBarButtonItem =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(settingsButtonAction:)];
    
    self.navigationItem.leftBarButtonItem  = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchUser)];
    
    self.blankTimelineView = [[UIView alloc] initWithFrame:self.tableView.bounds];
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        CGSize result = [[UIScreen mainScreen] bounds].size;
        if(result.height == 480)
        {
            // NSLog(@"Classic iPhone/iPod Support");
            
            UILabel *blankActivityLabel = [[UILabel alloc] initWithFrame:CGRectMake( 0.0f, 100, 320, 160.0f)];
            [blankActivityLabel setNumberOfLines:2];
            [blankActivityLabel setLineBreakMode:NSLineBreakByWordWrapping];
            [blankActivityLabel setTextAlignment:NSTextAlignmentCenter];
            [blankActivityLabel setBackgroundColor:[UIColor clearColor]];
            [blankActivityLabel setTextColor:[UIColor whiteColor]];
            [blankActivityLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:30.0]];
            [self.blankTimelineView addSubview:blankActivityLabel];
            
            [blankActivityLabel setText:@"Your photo timeline\nis currently empty."];
        }
        if(result.height == 568)
        {
            // NSLog(@"iPhone 5 Support");
            
            UILabel *blankActivityLabel = [[UILabel alloc] initWithFrame:CGRectMake( 0.0f, 140, 320, 160.0f)];
            [blankActivityLabel setNumberOfLines:2];
            [blankActivityLabel setLineBreakMode:NSLineBreakByWordWrapping];
            [blankActivityLabel setTextAlignment:NSTextAlignmentCenter];
            [blankActivityLabel setBackgroundColor:[UIColor clearColor]];
            [blankActivityLabel setTextColor:[UIColor whiteColor]];
            [blankActivityLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:30.0]];
            [self.blankTimelineView addSubview:blankActivityLabel];
            
            [blankActivityLabel setText:@"Your photo timeline\nis currently empty."];
        }
    }
}

#pragma mark - PFQueryTableViewController

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    
    if (self.objects.count == 0 && ![[self queryForTable] hasCachedResult]) {
        self.tableView.scrollEnabled = NO;
        
        if (!self.blankTimelineView.superview) {
            self.blankTimelineView.alpha = 0.0f;
            self.tableView.tableHeaderView = self.blankTimelineView;
            
            [UIView animateWithDuration:0.200f animations:^{
                self.blankTimelineView.alpha = 1.0f;
            }];
        }
    } else {
        self.tableView.tableHeaderView = nil;
        self.tableView.scrollEnabled = YES;
    }
}

- (void)settingsButtonAction:(id)sender {
    
    self.settingsActionSheetDelegate = [[SettingsActionSheetDelegate alloc] initWithNavigationController:self.navigationController];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self.settingsActionSheetDelegate cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"My Profile", @"Invite Friends", @"Log Out", nil];
    
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
}

- (void)searchUser {
    
    SearchUserViewController *searchUsers = [[SearchUserViewController alloc] init];
    [self.navigationController pushViewController:searchUsers animated:YES];
}

@end