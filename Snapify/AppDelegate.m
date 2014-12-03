//
//  AppDelegate.m
//  Snapify (from original AnyPic)
//
//  Modified by Christopher Coudriet on 12/31/13 (Created by Héctor Ramos on 5/04/12)
//  Copyright (c) 2013 Christopher Coudriet / 2012 Héctor Ramos. All rights reserved.
//

#import "AppDelegate.h"
#import "Reachability.h"
#import "MBProgressHUD.h"
#import "HomeViewController.h"
#import "LogInViewController.h"
#import "AccountViewController.h"
#import "WelcomeViewController.h"
#import "ActivityFeedViewController.h"
#import "PhotoDetailsViewController.h"
#import "SearchUserViewController.h"
#import "Settings.h"

@interface AppDelegate () {
    NSMutableData *_data;
    BOOL firstLaunch;
}

@property (nonatomic, strong) HomeViewController *homeViewController;
@property (nonatomic, strong) ActivityFeedViewController *activityViewController;
@property (nonatomic, strong) WelcomeViewController *welcomeViewController;
@property (nonatomic, strong) SearchUserViewController *searchUser;

@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) NSTimer *autoFollowTimer;

@property (nonatomic, strong) Reachability *hostReach;
@property (nonatomic, strong) Reachability *internetReach;
@property (nonatomic, strong) Reachability *wifiReach;

- (void)setupAppearance;
- (BOOL)shouldProceedToMainInterface:(PFUser *)user;
- (BOOL)handleActionURL:(NSURL *)url;

@end

@implementation AppDelegate

@synthesize window;
@synthesize tabBarController;
@synthesize navController;
@synthesize adminData;
@synthesize networkStatus;

@synthesize homeViewController;
@synthesize activityViewController;
@synthesize welcomeViewController;
@synthesize searchUser;

@synthesize hud;
@synthesize autoFollowTimer;

@synthesize hostReach;
@synthesize internetReach;
@synthesize wifiReach;

// Download Parse admin credentials
- (id)init {
	
	self = [super init];
    
    adminData = [[NSDictionary alloc] initWithContentsOfFile:@"snapifyParseAdmin.plist"];

    return self;
}

#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // Parse initialization
    [Parse setApplicationId:ParseAppId clientKey:ParseClientKey];
    [PFFacebookUtils initializeFacebook];
    
    // Track app open.
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    PFACL *defaultACL = [PFACL ACL];
    // Enable public read access by default, with any newly created PFObjects belonging to the current user
    [defaultACL setPublicReadAccess:YES];
    [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];
    
    // Set up our app's global UIAppearance
    [self setupAppearance];
    
    // Use Reachability to monitor connectivity
    [self monitorReachability];
    
    self.welcomeViewController = [[WelcomeViewController alloc] init];
    
    self.navController = [[UINavigationController alloc] initWithRootViewController:self.welcomeViewController];
    self.navController.navigationBarHidden = YES;
    
    self.window.rootViewController = self.navController;
    [self.window makeKeyAndVisible];
    
    [self handlePush:launchOptions];
   
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    if ([self handleActionURL:url]) {
        return YES;
    }
    
    return [PFFacebookUtils handleOpenURL:url];
}

// Notification start
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)newDeviceToken {
    
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:newDeviceToken];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
	
    if ([error code] != 3010) { // 3010 is for the iPhone Simulator
        NSLog(@"Application failed to register for push notifications: %@", error);
	}
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
   
    [[NSNotificationCenter defaultCenter] postNotificationName:PAPAppDelegateApplicationDidReceiveRemoteNotification object:nil userInfo:userInfo];
    
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
        // Track app opens due to a push notification being acknowledged while the app wasn't active.
        [PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
    }
    
    if ([PFUser currentUser]) {
        if ([self.tabBarController viewControllers].count > PAPActivityTabBarItemIndex) {
            UITabBarItem *tabBarItem = [[self.tabBarController.viewControllers objectAtIndex:PAPActivityTabBarItemIndex] tabBarItem];
            
            NSLog(@"didReceiveRemoteNotification");
            
            if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive)
            {
                NSString *currentBadgeValue = tabBarItem.badgeValue;
                
                if (currentBadgeValue && currentBadgeValue.length > 0) {
                    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
                    NSNumber *badgeValue = [numberFormatter numberFromString:currentBadgeValue];
                    NSNumber *newBadgeValue = [NSNumber numberWithInt:[badgeValue intValue] + 1];
                    tabBarItem.badgeValue = [numberFormatter stringFromNumber:newBadgeValue];
                    
                    NSLog(@"Current badge is %d", [tabBarItem.badgeValue intValue]);
                }
                else {
                    
                    tabBarItem.badgeValue = @"1";
                    
                    NSLog(@"Current badge is %d", [tabBarItem.badgeValue intValue]);
                }
            }
            else {
            
                PFInstallation *currentInstallation = [PFInstallation currentInstallation];
                
                if (currentInstallation.badge == 0)  {
                    
                    NSLog(@"Current badge is %ld", (long)currentInstallation.badge);
                    
                    currentInstallation.badge = 0;
                    tabBarItem.badgeValue = 0;
                    
                    [currentInstallation saveEventually];
                }
                else
                {
                    NSLog(@"Current badge is %ld", (long)currentInstallation.badge);
                    
                    tabBarItem.badgeValue = [NSString stringWithFormat:@"%ld", (long)currentInstallation.badge];
                    
                    currentInstallation.badge = [tabBarItem.badgeValue intValue];
                    
                   [currentInstallation saveEventually];
                }
            }
        }
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    if ([PFUser currentUser]) {
        if ([self.tabBarController viewControllers].count > PAPActivityTabBarItemIndex) {
            UITabBarItem *tabBarItem = [[self.tabBarController.viewControllers objectAtIndex:PAPActivityTabBarItemIndex] tabBarItem];
            
            PFInstallation *currentInstallation = [PFInstallation currentInstallation];
            
            NSLog(@"applicationDidBecomeActive");
            
            if (currentInstallation.badge == 0)  {
                
                NSLog(@"Current badge is %ld", (long)currentInstallation.badge);
                
                currentInstallation.badge = 0;
                tabBarItem.badgeValue = 0;
                
                [currentInstallation saveEventually];
            }
            else
            {
                NSLog(@"Current badge is %ld", (long)currentInstallation.badge);
                
                tabBarItem.badgeValue = [NSString stringWithFormat:@"%ld", (long)currentInstallation.badge];
                
                currentInstallation.badge = [tabBarItem.badgeValue intValue];
                
                [currentInstallation saveEventually];
            }
        }
    }

    [[FBSession activeSession] handleDidBecomeActive];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
    if ([PFUser currentUser]) {
        if ([self.tabBarController viewControllers].count > PAPActivityTabBarItemIndex) {
            UITabBarItem *tabBarItem = [[self.tabBarController.viewControllers objectAtIndex:PAPActivityTabBarItemIndex] tabBarItem];
            
            PFInstallation *currentInstallation = [PFInstallation currentInstallation];
            
            NSLog(@"applicationDidEnterBackground");
            
            NSLog(@"Current badge is %d", [tabBarItem.badgeValue intValue]);
            
            currentInstallation.badge = [tabBarItem.badgeValue intValue];
            
            [currentInstallation saveEventually];
        }
    }
}

#pragma mark - UITabBarControllerDelegate

- (BOOL)tabBarController:(UITabBarController *)aTabBarController shouldSelectViewController:(UIViewController *)viewController {
    
    // The empty UITabBarItem behind our Camera button should not load a view controller
    return ![viewController isEqual:aTabBarController.viewControllers[PAPEmptyTabBarItemIndex]];
}

#pragma mark - PFLoginViewController

- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    
    // user has logged in - we need to fetch all of their Facebook data before we let them in
    if (![self shouldProceedToMainInterface:user]) {
        self.hud = [MBProgressHUD showHUDAddedTo:self.navController.presentedViewController.view animated:YES];
        self.hud.labelText = @"Loading...";
        self.hud.dimBackground = YES;
    }
    
    // Subscribe to private push channel
    if (user) {
        
        NSString *privateChannelName = [NSString stringWithFormat:@"user_%@", [user objectId]];
        // Add the user to the installation so we can track the owner of the device
        [[PFInstallation currentInstallation] setObject:[PFUser currentUser] forKey:kPAPInstallationUserKey];
        // Subscribe user to private channel
        [[PFInstallation currentInstallation] addUniqueObject:privateChannelName forKey:kPAPInstallationChannelsKey];
        // Save installation object
        [[PFInstallation currentInstallation] saveEventually];
        
        [user setObject:privateChannelName forKey:kPAPUserPrivateChannelKey];
    }

    [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        
        if (!error) {
            [self facebookRequestDidLoad:result];
        } else {
            [self facebookRequestDidFailWithError:error];
        }
    }];
}

#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
   
    _data = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    [_data appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    [Utility processFacebookProfilePictureData:_data];
}

#pragma mark - AppDelegate

- (BOOL)isParseReachable {
    
    return self.networkStatus != NotReachable;
}

- (void)presentLoginViewControllerAnimated:(BOOL)animated {
   
    LogInViewController *loginViewController = [[LogInViewController alloc] init];
    [loginViewController setDelegate:self];
    loginViewController.fields = PFLogInFieldsFacebook;
    loginViewController.facebookPermissions = @[ @"user_about_me" ];
    
    [self.welcomeViewController presentViewController:loginViewController animated:YES completion:nil];
}

- (void)presentLoginViewController {
    
    [self presentLoginViewControllerAnimated:YES];
}

- (void)presentTabBarController {
    
    self.tabBarController = [[TabBarController alloc] init];
    self.homeViewController = [[HomeViewController alloc] initWithStyle:UITableViewStylePlain];
    [self.homeViewController setFirstLaunch:firstLaunch];
    self.activityViewController = [[ActivityFeedViewController alloc] initWithStyle:UITableViewStylePlain];
    self.searchUser = [[SearchUserViewController alloc]initWithStyle:UITableViewStylePlain];
    
    UINavigationController *homeNavigationController = [[UINavigationController alloc] initWithRootViewController:self.homeViewController];
    UINavigationController *emptyNavigationController = [[UINavigationController alloc] init];
    UINavigationController *activityFeedNavigationController = [[UINavigationController alloc] initWithRootViewController:self.activityViewController];
    UINavigationController *searchUsers = [[UINavigationController alloc] initWithRootViewController:self.searchUser];
    
    [Utility addBottomDropShadowToNavigationBarForNavigationController:homeNavigationController];
    [Utility addBottomDropShadowToNavigationBarForNavigationController:emptyNavigationController];
    [Utility addBottomDropShadowToNavigationBarForNavigationController:activityFeedNavigationController];
    [Utility addBottomDropShadowToNavigationBarForNavigationController:searchUsers];
    
    NSString *home_label = @"Timeline";
    
    UITabBarItem *homeTabBarItem = [[UITabBarItem alloc] initWithTitle:home_label image:nil tag:0];
    [homeTabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"iconHome.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"iconHomeSel.png"]];
    [homeTabBarItem setTitleTextAttributes: @{ UITextAttributeTextColor: [UIColor grayColor] } forState:UIControlStateNormal];
    [homeTabBarItem setTitleTextAttributes: @{ UITextAttributeTextColor: [UIColor whiteColor] } forState:UIControlStateSelected];
    
    NSString *activity_label = @"Activity";
   
    UITabBarItem *activityFeedTabBarItem = [[UITabBarItem alloc] initWithTitle:activity_label image:nil tag:0];
    [activityFeedTabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"iconActivity.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"iconActivitySel.png"]];
    [activityFeedTabBarItem setTitleTextAttributes:@{ UITextAttributeTextColor: [UIColor grayColor] } forState:UIControlStateNormal];
    [activityFeedTabBarItem setTitleTextAttributes:@{ UITextAttributeTextColor: [UIColor whiteColor] } forState:UIControlStateSelected];
    
    [homeNavigationController setTabBarItem:homeTabBarItem];
    [activityFeedNavigationController setTabBarItem:activityFeedTabBarItem];
    [searchUsers setTabBarItem:activityFeedTabBarItem];
    
    self.tabBarController.delegate = self;
    self.tabBarController.tabBar.barStyle = UIBarStyleBlack;
    
    self.tabBarController.viewControllers = @[ homeNavigationController, emptyNavigationController, activityFeedNavigationController];
    
    [self.navController setViewControllers:@[ self.welcomeViewController, self.tabBarController ] animated:NO];
    
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge|
     UIRemoteNotificationTypeAlert|
     UIRemoteNotificationTypeSound];
    
    // Download user's profile picture
    NSURL *profilePictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", [[PFUser currentUser] objectForKey:kPAPUserFacebookIDKey]]];
    NSURLRequest *profilePictureURLRequest = [NSURLRequest requestWithURL:profilePictureURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0f]; // Facebook profile picture cache policy: Expires in 2 weeks
    [NSURLConnection connectionWithRequest:profilePictureURLRequest delegate:self];
}

- (void)logOut {
    
    // clear cache
    [[Cache sharedCache] clear];
    
    // clear NSUserDefaults
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kPAPUserDefaultsCacheFacebookFriendsKey];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kPAPUserDefaultsActivityFeedViewControllerLastRefreshKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
        
    // Clear all caches
    [PFQuery clearAllCachedResults];
    
    // Log out
    [PFUser logOut];
    
    // clear out cached data, view controllers, etc
    [self.navController popToRootViewControllerAnimated:NO];
    
    [self presentLoginViewController];
    
    self.homeViewController = nil;
    self.activityViewController = nil;
}

- (void)setupAppearance {
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlack];
    
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    NSDictionary *textTitleOptions = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, [UIFont fontWithName:@"HelveticaNeue-Thin" size:24.0], NSFontAttributeName, nil];
    [[UINavigationBar appearance] setTitleTextAttributes:textTitleOptions];
}

- (void)monitorReachability {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:ReachabilityChangedNotification object:nil];
    
    self.hostReach = [Reachability reachabilityWithHostName:@"api.parse.com"];
    [self.hostReach startNotifier];
    
    self.internetReach = [Reachability reachabilityForInternetConnection];
    [self.internetReach startNotifier];
    
    self.wifiReach = [Reachability reachabilityForLocalWiFi];
    [self.wifiReach startNotifier];
}

- (void)handlePush:(NSDictionary *)launchOptions {
    
    // If the app was launched in response to a push notification, we'll handle the payload here
    NSDictionary *remoteNotificationPayload = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (remoteNotificationPayload) {
        [[NSNotificationCenter defaultCenter] postNotificationName:PAPAppDelegateApplicationDidReceiveRemoteNotification object:nil userInfo:remoteNotificationPayload];
        
        if (![PFUser currentUser]) {
            return;
        }
        
        // If the push notification payload references a photo, we will attempt to push this view controller into view
        NSString *photoObjectId = [remoteNotificationPayload objectForKey:kPAPPushPayloadPhotoObjectIdKey];
        if (photoObjectId && photoObjectId.length > 0) {
            [self shouldNavigateToPhoto:[PFObject objectWithoutDataWithClassName:kPAPPhotoClassKey objectId:photoObjectId]];
            return;
        }
        
        // If the push notification payload references a user, we will attempt to push their profile into view
        NSString *fromObjectId = [remoteNotificationPayload objectForKey:kPAPPushPayloadFromUserObjectIdKey];
        if (fromObjectId && fromObjectId.length > 0) {
            PFQuery *query = [PFUser query];
            query.cachePolicy = kPFCachePolicyCacheElseNetwork;
            [query getObjectInBackgroundWithId:fromObjectId block:^(PFObject *user, NSError *error) {
                if (!error) {
                    UINavigationController *homeNavigationController = self.tabBarController.viewControllers[PAPHomeTabBarItemIndex];
                    self.tabBarController.selectedViewController = homeNavigationController;
                    
                    AccountViewController *accountViewController = [[AccountViewController alloc] initWithStyle:UITableViewStylePlain];
                    accountViewController.user = (PFUser *)user;
                    [homeNavigationController pushViewController:accountViewController animated:YES];
                }
            }];
        }
    }
}

- (void)autoFollowTimerFired:(NSTimer *)aTimer {
    
    [MBProgressHUD hideHUDForView:self.navController.presentedViewController.view animated:YES];
    [MBProgressHUD hideHUDForView:self.homeViewController.view animated:YES];
    [self.homeViewController loadObjects];
}

- (BOOL)shouldProceedToMainInterface:(PFUser *)user {
    
    if ([Utility userHasValidFacebookData:[PFUser currentUser]]) {
        [MBProgressHUD hideHUDForView:self.navController.presentedViewController.view animated:YES];
        [self presentTabBarController];
        
        [self.navController dismissViewControllerAnimated:YES completion:nil];
        return YES;
    }
    
    return NO;
}

- (BOOL)handleActionURL:(NSURL *)url {
    
    if ([[url host] isEqualToString:kPAPLaunchURLHostTakePicture]) {
        if ([PFUser currentUser]) {
            return [self.tabBarController shouldPresentPhotoCaptureController];
        }
    } else {
        if ([[url fragment] rangeOfString:@"^pic/[A-Za-z0-9]{10}$" options:NSRegularExpressionSearch].location != NSNotFound) {
            NSString *photoObjectId = [[url fragment] substringWithRange:NSMakeRange(4, 10)];
            if (photoObjectId && photoObjectId.length > 0) {
                [self shouldNavigateToPhoto:[PFObject objectWithoutDataWithClassName:kPAPPhotoClassKey objectId:photoObjectId]];
                return YES;
            }
        }
    }
    
    return NO;
}

// Called by Reachability whenever status changes.
- (void)reachabilityChanged:(NSNotification* )note {
    
    Reachability *curReach = (Reachability *)[note object];
    NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
    
    networkStatus = [curReach currentReachabilityStatus];
    
    if (networkStatus == NotReachable) {
        NSLog(@"Network not reachable.");
    }
    
    if ([self isParseReachable] && [PFUser currentUser] && self.homeViewController.objects.count == 0) {
        // Refresh home timeline on network restoration. Takes care of a freshly installed app that failed to load the main timeline under bad network conditions.
        // In this case, they'd see the empty timeline placeholder and have no way of refreshing the timeline unless they followed someone.
        [self.homeViewController loadObjects];
    }
}

- (void)shouldNavigateToPhoto:(PFObject *)targetPhoto {
    
    for (PFObject *photo in self.homeViewController.objects) {
        if ([photo.objectId isEqualToString:targetPhoto.objectId]) {
            targetPhoto = photo;
            break;
        }
    }
    
    // if we have a local copy of this photo, this won't result in a network fetch
    [targetPhoto fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error) {
            UINavigationController *homeNavigationController = [[self.tabBarController viewControllers] objectAtIndex:PAPHomeTabBarItemIndex];
            [self.tabBarController setSelectedViewController:homeNavigationController];
            
            PhotoDetailsViewController *detailViewController = [[PhotoDetailsViewController alloc] initWithPhoto:object];
            [homeNavigationController pushViewController:detailViewController animated:YES];
        }
    }];
}

- (void)facebookRequestDidLoad:(id)result {
    
    // This method is called twice - once for the user's / me profile, and a second time when obtaining their friends. We will try and handle both scenarios in a single method.
    PFUser *user = [PFUser currentUser];
    
    NSArray *data = [result objectForKey:@"data"];
    
    if (data) {
        // we have friends data
        NSMutableArray *facebookIds = [[NSMutableArray alloc] initWithCapacity:[data count]];
        for (NSDictionary *friendData in data) {
            if (friendData[@"id"]) {
                [facebookIds addObject:friendData[@"id"]];
            }
        }
        
        // cache friend data
        [[Cache sharedCache] setFacebookFriends:facebookIds];
        
        if (user) {
            if (![user objectForKey:kPAPUserAlreadyAutoFollowedFacebookFriendsKey]) {
                self.hud.labelText = @"Following Friends...";
                firstLaunch = YES;
                
                [user setObject:@YES forKey:kPAPUserAlreadyAutoFollowedFacebookFriendsKey];
                NSError *error = nil;
                
                // find common Facebook friends already using Anypic
                PFQuery *facebookFriendsQuery = [PFUser query];
                [facebookFriendsQuery whereKey:kPAPUserFacebookIDKey containedIn:facebookIds];
                
                // auto-follow Parse employees
                PFQuery *autoFollowAccountsQuery = [PFUser query];
                [autoFollowAccountsQuery whereKey:kPAPUserFacebookIDKey containedIn:kPAPAutoFollowAccountFacebookIds];
                
                // combined query
                PFQuery *query = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:autoFollowAccountsQuery,facebookFriendsQuery, nil]];
                
                NSArray *anypicFriends = [query findObjects:&error];
                
                if (!error) {
                    [anypicFriends enumerateObjectsUsingBlock:^(PFUser *newFriend, NSUInteger idx, BOOL *stop) {
                        PFObject *joinActivity = [PFObject objectWithClassName:kPAPActivityClassKey];
                        [joinActivity setObject:user forKey:kPAPActivityFromUserKey];
                        [joinActivity setObject:newFriend forKey:kPAPActivityToUserKey];
                        [joinActivity setObject:kPAPActivityTypeJoined forKey:kPAPActivityTypeKey];
                        
                        PFACL *joinACL = [PFACL ACL];
                        [joinACL setPublicReadAccess:YES];
                        joinActivity.ACL = joinACL;
                        
                        // make sure our join activity is always earlier than a follow
                        [joinActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                            [Utility followUserInBackground:newFriend block:^(BOOL succeeded, NSError *error) {
                                // This block will be executed once for each friend that is followed.
                                // We need to refresh the timeline when we are following at least a few friends
                                // Use a timer to avoid refreshing innecessarily
                                if (self.autoFollowTimer) {
                                    [self.autoFollowTimer invalidate];
                                }
                                
                                self.autoFollowTimer = [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(autoFollowTimerFired:) userInfo:nil repeats:NO];
                            }];
                        }];
                    }];
                }
                
                if (![self shouldProceedToMainInterface:user]) {
                    [self logOut];
                    return;
                }
                
                if (!error) {
                    [MBProgressHUD hideHUDForView:self.navController.presentedViewController.view animated:NO];
                    if (anypicFriends.count > 0) {
                        self.hud = [MBProgressHUD showHUDAddedTo:self.homeViewController.view animated:NO];
                        self.hud.dimBackground = YES;
                        self.hud.labelText = @"Following Friends...";
                    } else {
                        [self.homeViewController loadObjects];
                    }
                }
            }
            
            [user saveEventually];
        } else {
            NSLog(@"No user session found. Forcing logOut.");
            [self logOut];
        }
    } else {
        self.hud.labelText = @"Creating Profile...";
        
        if (user) {
            NSString *facebookName = result[@"name"];
            if (facebookName && [facebookName length] != 0) {
                [user setObject:facebookName forKey:kPAPUserDisplayNameKey];
            } else {
                [user setObject:@"Someone" forKey:kPAPUserDisplayNameKey];
            }
            
            NSString *facebookId = result[@"id"];
            if (facebookId && [facebookId length] != 0) {
                [user setObject:facebookId forKey:kPAPUserFacebookIDKey];
            }
            
            [user saveEventually];
        }
        
        [FBRequestConnection startForMyFriendsWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            if (!error) {
                [self facebookRequestDidLoad:result];
            } else {
                [self facebookRequestDidFailWithError:error];
            }
        }];
    }
}

- (void)facebookRequestDidFailWithError:(NSError *)error {
   
    NSLog(@"Facebook error: %@", error);
    
    if ([PFUser currentUser]) {
        if ([[error userInfo][@"error"][@"type"] isEqualToString:@"OAuthException"]) {
            NSLog(@"The Facebook token was invalidated. Logging out.");
            [self logOut];
        }
    }
}

@end
