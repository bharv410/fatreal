//
//  SearchUserViewController.m
//  Snapify (from original AnyPic)
//
//  Modified by Christopher Coudriet on 12/31/13 (Created by Héctor Ramos on 5/04/12)
//  Copyright (c) 2013 Christopher Coudriet / 2012 Héctor Ramos. All rights reserved.
//

#import "SearchUserViewController.h"
#import "ProfileImageView.h"
#import "AppDelegate.h"
#import "LoadMoreCell.h"
#import "AccountViewController.h"
#import "MBProgressHUD.h"

typedef enum {
    PAPFindFriendsFollowingNone = 0,    // User isn't following anybody in Friends list
    PAPFindFriendsFollowingAll,         // User is following all Friends
    PAPFindFriendsFollowingSome         // User is following some of their Friends
}   PAPFindFriendsFollowStatus;

@interface SearchUserViewController ()
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, assign) PAPFindFriendsFollowStatus followStatus;
@property (nonatomic, strong) NSString *selectedEmailAddress;
@property (nonatomic, strong) NSMutableDictionary *outstandingFollowQueries;
@property (nonatomic, strong) NSMutableDictionary *outstandingCountQueries;
@end

static NSUInteger const kPAPCellFollowTag = 2;
static NSUInteger const kPAPCellNameLabelTag = 3;
static NSUInteger const kPAPCellAvatarTag = 4;
static NSUInteger const kPAPCellPhotoNumLabelTag = 5;

@implementation SearchUserViewController
@synthesize headerView;
@synthesize followStatus;
@synthesize selectedEmailAddress;
@synthesize outstandingFollowQueries;
@synthesize outstandingCountQueries;
@synthesize querys;


- (id)initWithStyle:(UITableViewStyle)style {
    
    self = [super initWithStyle:style];
    if (self) {
        
        self.outstandingFollowQueries = [NSMutableDictionary dictionary];
        self.outstandingCountQueries = [NSMutableDictionary dictionary];
        
        self.selectedEmailAddress = @"";
        
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        
        // Whether the built-in pull-to-refresh is enabled
        if (NSClassFromString(@"UIRefreshControl")) {
            self.pullToRefreshEnabled = NO;
        } else {
            self.pullToRefreshEnabled = YES;
        }
        
        // The number of objects to show per page
        self.objectsPerPage = 10;
        
        self.loadingViewEnabled = NO;
        
        // Used to determine Follow/Unfollow All button status
        self.followStatus = PAPFindFriendsFollowingSome;
        
        //[self.tableView setSeparatorColor:[UIColor whiteColor]];
    }
    
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.navigationItem.title = @"Users";
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]
                                             initWithTitle:@""
                                             style:UIBarButtonItemStyleBordered
                                             target:nil
                                             action:nil];
    
    UIView *texturedBackgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    [texturedBackgroundView setBackgroundColor:[UIColor whiteColor]];
    self.tableView.backgroundView = texturedBackgroundView;
    
    if (NSClassFromString(@"UIRefreshControl")) {
        // Use the new iOS 6 refresh control.
        UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
        self.refreshControl = refreshControl;
        [self.refreshControl setTintColor:[UIColor grayColor]];
        [self.refreshControl addTarget:self action:@selector(refreshControlValueChanged:) forControlEvents:UIControlEventValueChanged];
        self.pullToRefreshEnabled = NO;
        self.refreshControl.layer.zPosition = self.tableView.backgroundView.layer.zPosition + 1;
        
        self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 67)];

        UISearchBar *findsUser = [[UISearchBar alloc]init];
        findsUser.placeholder = @"Search For Users (case sensitive)";
        findsUser.tintColor = [UIColor blackColor];
        findsUser.delegate = self;
        [findsUser sizeToFit];
        [findsUser setAutocapitalizationType:UITextAutocapitalizationTypeNone];
        [findsUser sizeToFit];
        [self.headerView addSubview:findsUser];
        
        [self.tableView setTableHeaderView:self.headerView];
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
            
            [self.refreshControl beginRefreshing];
        }];
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row < self.objects.count) {
        return [FindFriendsCell heightForCell];
    } else {
        return 44.0f;
    }
}

#pragma mark - PFQueryTableViewController

- (void)searchBarSearchButtonClicked:(UISearchBar*) theSearchBar {
    
    NSString *querySearch = theSearchBar.text;
    NSLog(@"Tap search");
    PFQuery *searchBarUser = [PFUser query];
    [searchBarUser whereKey:@"displayName" containsString:querySearch];
    
    PFQuery *rez = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:searchBarUser, nil]];
    querys = rez;
    [self loadObjects];
    NSLog(@"%@",querys);
}

- (PFQuery *)queryForTable {
    
    // Use cached facebook friend ids
    NSArray *facebookFriends = [[Cache sharedCache] facebookFriends];
    
    PFQuery *allUser = [PFUser query];
    [allUser whereKey:@"displayName" containsString:@""];
    
    // Query for all friends you have on facebook and who are using the app
    PFQuery *friendsQuery = [PFUser query];
    [friendsQuery whereKey:kPAPUserFacebookIDKey containedIn:facebookFriends];
    
    // Query for all auto-follow accounts
    NSMutableArray *autoFollowAccountFacebookIds = [[NSMutableArray alloc] initWithArray:kPAPAutoFollowAccountFacebookIds];
    [autoFollowAccountFacebookIds removeObject:[[PFUser currentUser] objectForKey:kPAPUserFacebookIDKey]];
    PFQuery *parseEmployeeQuery = [PFUser query];
    [parseEmployeeQuery whereKey:kPAPUserFacebookIDKey containedIn:autoFollowAccountFacebookIds];
    
    PFQuery *query = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:friendsQuery, parseEmployeeQuery, allUser, nil]];
    query.cachePolicy = kPFCachePolicyNetworkOnly;
    
    if (self.objects.count == 0) {
        
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    
    [query orderByAscending:kPAPUserDisplayNameKey];
    
    if (querys == nil){
        
        query = query;
    }
    
    else {
        
        query = querys;
    }
    
    return query;
}

- (void)objectsDidLoad:(NSError *)error {
    
    [super objectsDidLoad:error];
    
    if (NSClassFromString(@"UIRefreshControl")) {
        
        [self.refreshControl endRefreshing];
    }
    
    PFQuery *isFollowingQuery = [PFQuery queryWithClassName:kPAPActivityClassKey];
    [isFollowingQuery whereKey:kPAPActivityFromUserKey equalTo:[PFUser currentUser]];
    [isFollowingQuery whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeFollow];
    [isFollowingQuery whereKey:kPAPActivityToUserKey containedIn:self.objects];
    [isFollowingQuery setCachePolicy:kPFCachePolicyNetworkOnly];
    
    [isFollowingQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (!error) {
            if (number == self.objects.count) {
                self.followStatus = PAPFindFriendsFollowingAll;
                [self configureUnfollowAllButton];
                for (PFUser *user in self.objects) {
                    [[Cache sharedCache] setFollowStatus:YES user:user];
                }
            } else if (number == 0) {
                self.followStatus = PAPFindFriendsFollowingNone;
                [self configureFollowAllButton];
                for (PFUser *user in self.objects) {
                    [[Cache sharedCache] setFollowStatus:NO user:user];
                }
            } else {
                self.followStatus = PAPFindFriendsFollowingSome;
                [self configureFollowAllButton];
            }
        }
        
        if (self.objects.count == 0) {
            self.navigationItem.rightBarButtonItem = nil;
        }
    }];
    
    if (self.objects.count == 0) {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    
    static NSString *FriendCellIdentifier = @"FriendCell";
    
    FindFriendsCell *cell = [tableView dequeueReusableCellWithIdentifier:FriendCellIdentifier];
    if (cell == nil) {
        cell = [[FindFriendsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:FriendCellIdentifier];
        [cell setDelegate:self];
    }
    
    [cell setUser:(PFUser*)object];
    
    [cell.photoLabel setText:@"0 Photos"];
    
    NSDictionary *attributes = [[Cache sharedCache] attributesForUser:(PFUser *)object];
    
    if (attributes) {
        // set them now
        NSString *pluralizedPhoto;
        NSNumber *number = [[Cache sharedCache] photoCountForUser:(PFUser *)object];
        if ([number intValue] == 1) {
            pluralizedPhoto = @"Photo";
        } else {
            pluralizedPhoto = @"Photos";
        }
        [cell.photoLabel setText:[NSString stringWithFormat:@"%@ %@", number, pluralizedPhoto]];

    } else {
        
        @synchronized(self) {
            NSNumber *outstandingCountQueryStatus = [self.outstandingCountQueries objectForKey:indexPath];
            if (!outstandingCountQueryStatus) {
                [self.outstandingCountQueries setObject:[NSNumber numberWithBool:YES] forKey:indexPath];
                PFQuery *photoNumQuery = [PFQuery queryWithClassName:kPAPPhotoClassKey];
                [photoNumQuery whereKey:kPAPPhotoUserKey equalTo:object];
                [photoNumQuery setCachePolicy:kPFCachePolicyCacheThenNetwork];
                
                [photoNumQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
                    @synchronized(self) {
                        [[Cache sharedCache] setPhotoCount:[NSNumber numberWithInt:number] user:(PFUser *)object];
                        [self.outstandingCountQueries removeObjectForKey:indexPath];
                    }
                    FindFriendsCell *actualCell = (FindFriendsCell*)[tableView cellForRowAtIndexPath:indexPath];
                    NSString *pluralizedPhoto;
                    if (number == 1) {
                        pluralizedPhoto = @"photo";
                    } else {
                        pluralizedPhoto = @"photos";
                    }
                    [actualCell.photoLabel setText:[NSString stringWithFormat:@"%d %@", number, pluralizedPhoto]];
                    
                }];
            };
        }
    }
    
    cell.followButton.selected = NO;
    cell.tag = indexPath.row;
    
    if (self.followStatus == PAPFindFriendsFollowingSome) {
        if (attributes) {
            
            PFUser *currentUser = [PFUser currentUser];
            
            NSString *title = cell.nameButton.titleLabel.text;
            
            if([title isEqualToString:[currentUser objectForKey:@"displayName"]])
            {
                // NSLog(@"%@", title);
                
                cell.followButton.titleLabel.text = @"";
            }
            else
            {
                cell.currentUserButton.titleLabel.text = @"";
                
                [cell.followButton setSelected:[[Cache sharedCache] followStatusForUser:(PFUser *)object]];
            }

        } else {
            
            @synchronized(self) {
                NSNumber *outstandingQuery = [self.outstandingFollowQueries objectForKey:indexPath];
                if (!outstandingQuery) {
                    [self.outstandingFollowQueries setObject:[NSNumber numberWithBool:YES] forKey:indexPath];
                    PFQuery *isFollowingQuery = [PFQuery queryWithClassName:kPAPActivityClassKey];
                    [isFollowingQuery whereKey:kPAPActivityFromUserKey equalTo:[PFUser currentUser]];
                    [isFollowingQuery whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeFollow];
                    [isFollowingQuery whereKey:kPAPActivityToUserKey equalTo:object];
                    [isFollowingQuery setCachePolicy:kPFCachePolicyCacheThenNetwork];
                    
                    [isFollowingQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
                        @synchronized(self) {
                            [self.outstandingFollowQueries removeObjectForKey:indexPath];
                            [[Cache sharedCache] setFollowStatus:(!error && number > 0) user:(PFUser *)object];
                        }
                        if (cell.tag == indexPath.row) {
                            [cell.followButton setSelected:(!error && number > 0)];
                        }
                    }];
                }
            }
        }
    } else {
        
        [cell.followButton setSelected:(self.followStatus == PAPFindFriendsFollowingAll)];
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

#pragma mark - FindFriendsCellDelegate

- (void)cell:(FindFriendsCell *)cellView didTapUserButton:(PFUser *)aUser {
    
    // Push account view controller
    AccountViewController *accountViewController = [[AccountViewController alloc] initWithStyle:UITableViewStylePlain];
    [accountViewController setUser:aUser];
    [self.navigationController pushViewController:accountViewController animated:YES];
}

- (void)cell:(FindFriendsCell *)cellView didTapFollowButton:(PFUser *)aUser {
    
    [self shouldToggleFollowFriendForCell:cellView];
}

- (void)followAllFriendsButtonAction:(id)sender {
    
    [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    
    self.followStatus = PAPFindFriendsFollowingAll;
    [self configureUnfollowAllButton];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Unfollow All" style:UIBarButtonItemStyleBordered target:self action:@selector(unfollowAllFriendsButtonAction:)];
        
        NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:self.objects.count];
        for (int r = 0; r < self.objects.count; r++) {
            PFObject *user = [self.objects objectAtIndex:r];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:r inSection:0];
            FindFriendsCell *cell = (FindFriendsCell *)[self tableView:self.tableView cellForRowAtIndexPath:indexPath object:user];
            
            PFUser *currentUser = [PFUser currentUser];
            
            NSString *title = cell.nameButton.titleLabel.text;
            
            if([title isEqualToString:[currentUser objectForKey:@"displayName"]])
            {
                // NSLog(@"%@", title);
                
                [indexPaths removeObject:indexPath];
            }
            else
            {
                cell.followButton.selected = YES;
                [indexPaths addObject:indexPath];
            }
        }
        
        [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
        [MBProgressHUD hideAllHUDsForView:[UIApplication sharedApplication].keyWindow animated:YES];
        
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(followUsersTimerFired:) userInfo:nil repeats:NO];
        [Utility followUsersEventually:self.objects block:^(BOOL succeeded, NSError *error) {
            // note -- this block is called once for every user that is followed successfully. We use a timer to only execute the completion block once no more saveEventually blocks have been called in 2 seconds
            [timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:2.0f]];
        }];
        
    });
}

- (void)unfollowAllFriendsButtonAction:(id)sender {
    
    [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    
    self.followStatus = PAPFindFriendsFollowingNone;
    [self configureFollowAllButton];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Follow All" style:UIBarButtonItemStyleBordered target:self action:@selector(followAllFriendsButtonAction:)];
        
        NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:self.objects.count];
        for (int r = 0; r < self.objects.count; r++) {
            PFObject *user = [self.objects objectAtIndex:r];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:r inSection:0];
            FindFriendsCell *cell = (FindFriendsCell *)[self tableView:self.tableView cellForRowAtIndexPath:indexPath object:user];
            
            PFUser *currentUser = [PFUser currentUser];
            
            NSString *title = cell.nameButton.titleLabel.text;
            
            if([title isEqualToString:[currentUser objectForKey:@"displayName"]])
            {
                // NSLog(@"%@", title);
                
                [indexPaths removeObject:indexPath];
            }
            else
            {
                cell.followButton.selected = NO;
                [indexPaths addObject:indexPath];
            }
        }
        
        [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
        [MBProgressHUD hideAllHUDsForView:[UIApplication sharedApplication].keyWindow animated:YES];
        
        [Utility unfollowUsersEventually:self.objects];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:PAPUtilityUserFollowingChangedNotification object:nil];
    });
}

- (void)shouldToggleFollowFriendForCell:(FindFriendsCell*)cell {
    
    PFUser *cellUser = cell.user;
    if ([cell.followButton isSelected]) {
        
        // Unfollow
        cell.followButton.selected = NO;
        [Utility unfollowUserEventually:cellUser];
        [[NSNotificationCenter defaultCenter] postNotificationName:PAPUtilityUserFollowingChangedNotification object:nil];

     } else {
         
         // Follow
         cell.followButton.selected = YES;
         [Utility followUserEventually:cellUser block:^(BOOL succeeded, NSError *error) {
             if (!error) {
                 [[NSNotificationCenter defaultCenter] postNotificationName:PAPUtilityUserFollowingChangedNotification object:nil];
             } else {
                 cell.followButton.selected = NO;
             }
         }];
     }
}

- (void)configureUnfollowAllButton {
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Unfollow All" style:UIBarButtonItemStyleBordered target:self action:@selector(unfollowAllFriendsButtonAction:)];
}

- (void)configureFollowAllButton {
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Follow All" style:UIBarButtonItemStyleBordered target:self action:@selector(followAllFriendsButtonAction:)];
}

- (void)followUsersTimerFired:(NSTimer *)timer {
    
    [self.tableView reloadData];
    [[NSNotificationCenter defaultCenter] postNotificationName:PAPUtilityUserFollowingChangedNotification object:nil];
}

- (void)refreshControlValueChanged:(UIRefreshControl *)refreshControl {
    
    [self loadObjects];
}

@end