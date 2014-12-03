//
//  ActivityFeedViewController.m
//  Snapify (from original AnyPic)
//
//  Modified by Christopher Coudriet on 12/31/13 (Created by Héctor Ramos on 5/04/12)
//  Copyright (c) 2013 Christopher Coudriet / 2012 Héctor Ramos. All rights reserved.
//

#import "ActivityFeedViewController.h"
#import "SettingsActionSheetDelegate.h"
#import "ActivityCell.h"
#import "AccountViewController.h"
#import "PhotoDetailsViewController.h"
#import "BaseTextCell2.h"
#import "LoadMoreCell.h"
#import "MBProgressHUD.h"
#import "SearchUserViewController.h"

@interface ActivityFeedViewController ()

@property (nonatomic, strong) SettingsActionSheetDelegate *settingsActionSheetDelegate;
@property (nonatomic, strong) NSDate *lastRefresh;
@property (nonatomic, strong) UIView *blankTimelineView;
@end

@implementation ActivityFeedViewController

@synthesize settingsActionSheetDelegate;
@synthesize lastRefresh;
@synthesize blankTimelineView;

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PAPAppDelegateApplicationDidReceiveRemoteNotification object:nil];
}

- (id)initWithStyle:(UITableViewStyle)style {
   
    self = [super initWithStyle:style];
    if (self) {
        // The className to query on
        self.parseClassName = kPAPActivityClassKey;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = YES;
        
        // Whether the built-in pull-to-refresh is enabled
        if (NSClassFromString(@"UIRefreshControl")) {
            self.pullToRefreshEnabled = NO;
        } else {
            self.pullToRefreshEnabled = YES;
        }
        
        // The number of objects to show per page
        self.objectsPerPage = 15;
        
        self.loadingViewEnabled = NO;
        
        //[self.tableView setSeparatorColor:[UIColor whiteColor]];
    }
    
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)viewDidAppear:(BOOL)animated {

    [self loadObjects];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.navigationItem.title = @"Find A Trainer";
    
    [self.navigationController.navigationBar setTranslucent:YES];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]
                                             initWithTitle:@""
                                             style:UIBarButtonItemStyleBordered
                                             target:nil
                                             action:nil];
    
    UIView *texturedBackgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    [texturedBackgroundView setBackgroundColor:[UIColor whiteColor]];
    self.tableView.backgroundView = texturedBackgroundView;
    
    // Add Settings button
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(settingsButtonAction:)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidReceiveRemoteNotification:) name:PAPAppDelegateApplicationDidReceiveRemoteNotification object:nil];

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
            [blankActivityLabel setTextColor:[UIColor grayColor]];
            [blankActivityLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:30.0]];
            [self.blankTimelineView addSubview:blankActivityLabel];
            
            [blankActivityLabel setText:@"Your activity timeline\nis currently empty."];
        }
        if(result.height == 568)
        {
            // NSLog(@"iPhone 5 Support");
            
            UILabel *blankActivityLabel = [[UILabel alloc] initWithFrame:CGRectMake( 0.0f, 140, 320, 160.0f)];
            [blankActivityLabel setNumberOfLines:2];
            [blankActivityLabel setLineBreakMode:NSLineBreakByWordWrapping];
            [blankActivityLabel setTextAlignment:NSTextAlignmentCenter];
            [blankActivityLabel setBackgroundColor:[UIColor clearColor]];
            [blankActivityLabel setTextColor:[UIColor grayColor]];
            [blankActivityLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:30.0]];
            [self.blankTimelineView addSubview:blankActivityLabel];
            
            [blankActivityLabel setText:@"Your activity timeline\nis currently empty."];
        }
    }

    lastRefresh = [[NSUserDefaults standardUserDefaults] objectForKey:kPAPUserDefaultsActivityFeedViewControllerLastRefreshKey];
    
    if (NSClassFromString(@"UIRefreshControl")) {
        // Use the new iOS 6 refresh control.
        UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
        self.refreshControl = refreshControl;
        self.refreshControl.tintColor = [UIColor grayColor];
        [self.refreshControl addTarget:self action:@selector(refreshControlValueChanged:) forControlEvents:UIControlEventValueChanged];
        self.pullToRefreshEnabled = NO;
        [self beginRefreshingTableView];
        self.refreshControl.layer.zPosition = self.tableView.backgroundView.layer.zPosition + 1;
    }
}

- (void)beginRefreshingTableView {
    
    [self.refreshControl beginRefreshing];
    
    if (self.tableView.contentOffset.y == 0) {
        
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^(void){
            
            self.tableView.contentOffset = CGPointMake(0, -self.refreshControl.frame.size.height);
            
        } completion:^(BOOL finished){
            
        }];
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row < self.objects.count) {
        PFObject *object = [self.objects objectAtIndex:indexPath.row];
        NSString *activityString = [ActivityFeedViewController stringForActivityType:(NSString*)[object objectForKey:kPAPActivityTypeKey]];
        
        PFUser *user = (PFUser*)[object objectForKey:kPAPActivityFromUserKey];
        NSString *nameString = @"Someone";
        if (user && [user objectForKey:kPAPUserDisplayNameKey] && [[user objectForKey:kPAPUserDisplayNameKey] length] > 0) {
            nameString = [user objectForKey:kPAPUserDisplayNameKey];
        }
        
        return [ActivityCell heightForCellWithName:nameString contentString:activityString];
    } else {
        return 44.0f;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row < self.objects.count) {
        PFObject *activity = [self.objects objectAtIndex:indexPath.row];
        if ([activity objectForKey:kPAPActivityPhotoKey]) {
            PhotoDetailsViewController *detailViewController = [[PhotoDetailsViewController alloc] initWithPhoto:[activity objectForKey:kPAPActivityPhotoKey]];
            [self.navigationController pushViewController:detailViewController animated:YES];
        } else if ([activity objectForKey:kPAPActivityFromUserKey]) {
            AccountViewController *detailViewController = [[AccountViewController alloc] initWithStyle:UITableViewStylePlain];
            [detailViewController setUser:[activity objectForKey:kPAPActivityFromUserKey]];
            [self.navigationController pushViewController:detailViewController animated:YES];
        }
    } else if (self.paginationEnabled) {
        // load more
        [self loadNextPage];
    }
}

#pragma mark - PFQueryTableViewController

- (PFQuery *)queryForTable {
    
    if (![PFUser currentUser]) {
        PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
        [query setLimit:0];
        return query;
    }
    
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    [query whereKey:kPAPActivityToUserKey equalTo:[PFUser currentUser]];
    [query whereKey:kPAPActivityFromUserKey notEqualTo:[PFUser currentUser]];
    [query whereKeyExists:kPAPActivityFromUserKey];
    [query includeKey:kPAPActivityFromUserKey];
    [query includeKey:kPAPActivityPhotoKey];
    [query orderByDescending:@"createdAt"];
    
    [query setCachePolicy:kPFCachePolicyNetworkOnly];
    
    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    //
    // If there is no network connection, we will hit the cache first.
    if (self.objects.count == 0 || ![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]) {
        [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
    }
    
    return query;
}

- (void)objectsDidLoad:(NSError *)error {
    
    [super objectsDidLoad:error];
    
    if (NSClassFromString(@"UIRefreshControl")) {
        
        [self.refreshControl endRefreshing];
    }
    
    //NSDate *currentDate = [NSDate date];
    //NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    //[dateComponents setDay:-1];
    //NSDate *oneDayAgo = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:currentDate options:0];
    //NSLog(@"\ncurrentDate: %@\nseven days ago: %@", currentDate, oneDayAgo);
    
    NSDate *newDate = [[NSDate date] dateByAddingTimeInterval:-30];
    
    lastRefresh = newDate;
    [[NSUserDefaults standardUserDefaults] setObject:lastRefresh forKey:kPAPUserDefaultsActivityFeedViewControllerLastRefreshKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    if (self.objects.count == 0 && ![[self queryForTable] hasCachedResult]) {
        self.tableView.scrollEnabled = NO;
        self.navigationController.tabBarItem.badgeValue = nil;
        
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
        
        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
        
        NSUInteger unreadCount = 0;
        for (PFObject *activity in self.objects) {
            if ([lastRefresh compare:[activity createdAt]] == NSOrderedAscending && ![[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeJoined]) {
                unreadCount++;
            }
        }
        
        if (unreadCount > 0) {
            
            self.navigationController.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d", unreadCount];
            
            currentInstallation.badge = unreadCount;
            
            [currentInstallation saveEventually];

        } else {
            
            self.navigationController.tabBarItem.badgeValue = nil;
            
            currentInstallation.badge = 0;
            
            [currentInstallation saveEventually];
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    
    static NSString *CellIdentifier = @"ActivityCell";
    
    ActivityCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[ActivityCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell setDelegate:self];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    
    [cell setActivity:object];
    
    if ([lastRefresh compare:[object createdAt]] == NSOrderedAscending) {
        [cell setIsNew:YES];
    } else {
        [cell setIsNew:NO];
    }
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *LoadMoreCellIdentifier = @"LoadMoreCell";
    
    LoadMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:LoadMoreCellIdentifier];
    if (!cell) {
        cell = [[LoadMoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LoadMoreCellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.hideSeparatorBottom = YES;
        cell.mainView.backgroundColor = [UIColor clearColor];
    }
    
    return cell;
}

#pragma mark - PAPActivityCellDelegate Methods

- (void)cell:(ActivityCell *)cellView didTapActivityButton:(PFObject *)activity {
    
    // Get image associated with the activity
    PFObject *photo = [activity objectForKey:kPAPActivityPhotoKey];
    
    // Push single photo view controller
    PhotoDetailsViewController *photoViewController = [[PhotoDetailsViewController alloc] initWithPhoto:photo];
    [self.navigationController pushViewController:photoViewController animated:YES];
}

- (void)cell:(BaseTextCell *)cellView didTapUserButton:(PFUser *)user {
    
    // Push account view controller
    AccountViewController *accountViewController = [[AccountViewController alloc] initWithStyle:UITableViewStylePlain];
    [accountViewController setUser:user];
    [self.navigationController pushViewController:accountViewController animated:YES];
}

#pragma mark - PAPActivityFeedViewController

+ (NSString *)stringForActivityType:(NSString *)activityType {
    if ([activityType isEqualToString:kPAPActivityTypeLike]) {
        return @"Liked your photo.";
    } else if ([activityType isEqualToString:kPAPActivityTypeFollow]) {
        return @"Started following you.";
    } else if ([activityType isEqualToString:kPAPActivityTypeComment]) {
        return @"Commented on your photo.";
    } else if ([activityType isEqualToString:kPAPActivityTypeJoined]) {
        return @"Joined Snapify.";
    } else if ([activityType isEqualToString:kPAPActivityTypeReport]) {
        return @"Reported photo!";
    } else {
        return nil;
    }
}

- (void)settingsButtonAction:(id)sender {
    
    settingsActionSheetDelegate = [[SettingsActionSheetDelegate alloc] initWithNavigationController:self.navigationController];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:settingsActionSheetDelegate cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"My Profile", @"Invite Friends", @"Log Out", nil];
    
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
}

- (void)applicationDidReceiveRemoteNotification:(NSNotification *)note {
    
    [self loadObjects];
}

- (void)refreshControlValueChanged:(UIRefreshControl *)refreshControl {
    
    [self loadObjects];
    [self beginRefreshingTableView];
}

@end