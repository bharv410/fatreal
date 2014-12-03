//
//  PhotoDetailsViewController.m
//  Snapify (from original AnyPic)
//
//  Modified by Christopher Coudriet on 12/31/13 (Created by Héctor Ramos on 5/04/12)
//  Copyright (c) 2013 Christopher Coudriet / 2012 Héctor Ramos. All rights reserved.
//

#import "PhotoDetailsViewController.h"
#import "ActivityCell.h"
#import "PhotoDetailsFooterView.h"
#import "Constants.h"
#import "AccountViewController.h"
#import "LoadMoreCell.h"
#import "Utility.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"

enum ActionSheetTags {
    
    MainActionSheetTag = 0,
    AltActionSheetTag = 1,
    ConfirmDeleteActionSheetTag = 2
};

@interface PhotoDetailsViewController ()
@property (nonatomic, strong) UITextField *commentTextField;
@property (nonatomic, strong) PhotoDetailsHeaderView *headerView;
@property (nonatomic, assign) BOOL likersQueryInProgress;
@end

static const CGFloat kPAPCellInsetWidth = 0.0f;

@implementation PhotoDetailsViewController

@synthesize commentTextField;
@synthesize headerView;
@synthesize parseAdminCreds;
@synthesize adminObjectId;
@synthesize adminPushChannel;


- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PAPUtilityUserLikedUnlikedPhotoCallbackFinishedNotification object:self.photo];
}

- (id)initWithPhoto:(PFObject *)aPhoto {
    
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        // The className to query on
        self.parseClassName = kPAPActivityClassKey;
        
        // Whether the built-in pull-to-refresh is enabled
        if (NSClassFromString(@"UIRefreshControl")) {
            self.pullToRefreshEnabled = NO;
        } else {
            self.pullToRefreshEnabled = YES;
        }
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = YES;
        
        // The number of comments to show per page
        self.objectsPerPage = 30;
        
        self.photo = aPhoto;
        
        self.likersQueryInProgress = NO;
    }
    
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style {
   
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    
    self.loadingViewEnabled = NO;
    
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    parseAdminCreds = [appDelegate.adminData objectForKey:@"adminCreds"];
    
    if (parseAdminCreds.count > 0)
    {
        adminObjectId = [parseAdminCreds objectAtIndex:0];
        NSLog(@"adminObjectId = %@", adminObjectId);
        
        adminPushChannel = [parseAdminCreds objectAtIndex:1];
        NSLog(@"adminPushChannel = %@", adminPushChannel);
    }
    else
    {
        adminObjectId = @"xK7SmtvCX4";
        NSLog(@"adminObjectId = %@", adminObjectId);
        
        adminPushChannel = @"user_xK7SmtvCX4";
        NSLog(@"adminPushChannel = %@", adminPushChannel);
    }

    
    self.navigationItem.title = @"Find A Trainer";
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]
                                             initWithTitle:@""
                                             style:UIBarButtonItemStyleBordered
                                             target:nil
                                             action:nil];

    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        CGSize result = [[UIScreen mainScreen] bounds].size;
        if(result.height == 480)
        {
            // NSLog(@"Classic iPhone/iPod Support");
            
            // Manully set contentInset.
            UIEdgeInsets currentInset = self.tableView.contentInset;
            currentInset.top = self.navigationController.navigationBar.bounds.size.height;
            currentInset.bottom = 31;
            
            self.automaticallyAdjustsScrollViewInsets = NO;
            
            currentInset.top += 21;
            
            self.tableView.contentInset = currentInset;
        }
        if(result.height == 568)
        {
            // NSLog(@"iPhone 5 Support");
            
            // Manully set contentInset.
            UIEdgeInsets currentInset = self.tableView.contentInset;
            currentInset.top = self.navigationController.navigationBar.bounds.size.height;
            currentInset.bottom = 31;
            
            self.automaticallyAdjustsScrollViewInsets = NO;
            
            currentInset.top += 20;
            
            self.tableView.contentInset = currentInset;
        }
    }

    // Set table view properties
    UIView *texturedBackgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    texturedBackgroundView.backgroundColor = [UIColor blackColor];
    self.tableView.backgroundView = texturedBackgroundView;
    
    // Set table header
    self.headerView = [[PhotoDetailsHeaderView alloc] initWithFrame:[PhotoDetailsHeaderView rectForView] photo:self.photo];
    self.headerView.delegate = self;
    
    self.tableView.tableHeaderView = self.headerView;
    
    // Set table footer
    PhotoDetailsFooterView *footerView = [[PhotoDetailsFooterView alloc] initWithFrame:[PhotoDetailsFooterView rectForView]];
    commentTextField = footerView.commentField;
    commentTextField.delegate = self;
    self.tableView.tableFooterView = footerView;
    
    NSString *alert = self.photo.objectId;
    PFQuery *query = [PFQuery queryWithClassName:@"Photo"];
    [query getObjectInBackgroundWithId:alert block:^(PFObject *alertLabel, NSError *error) {
        
        // NSLog(@"%@", alertLabel);
        NSString *label = alertLabel[@"alert"];
        
        if([label isEqual: @"Objectionable"]){
            
            // NSLog(@"alertLabel = Objectionable");
            NSString *userAd = [[PFUser currentUser] objectForKey:@"channel"];
            // NSLog(@"Admin = %@",userAd);
            if([userAd isEqual:adminPushChannel]){
                
                NSString *markObjectionable = @"This photo has been reported as being objectionable.";
                
                CGSize textSize = [markObjectionable sizeWithFont:[UIFont fontWithName:@"HelveticaNeue" size:18.0f] constrainedToSize:CGSizeMake( 255.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
                UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake( ([UIScreen mainScreen].bounds.size.width - textSize.width)/2.0f, 180.0f, textSize.width, textSize.height)];
                [textLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:18.0f]];
                [textLabel setLineBreakMode:NSLineBreakByWordWrapping];
                [textLabel setNumberOfLines:0];
                [textLabel setText:markObjectionable];
                [textLabel setTextColor:[UIColor whiteColor]];
                [textLabel setBackgroundColor:[UIColor blackColor]];
                [textLabel setTextAlignment:NSTextAlignmentCenter];
            
                [self.tableView addSubview:textLabel];
            }
        }
    }];
    
    if (![self currentUserOwnsPhoto]) {
        
        // Use UIActivityViewController if it is available (iOS 6 +)
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(altActionButtonAction:)];
    
    }  else if ([self currentUserOwnsPhoto]){
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionButtonAction:)];
    }
    
    NSString *userAd = [[PFUser currentUser] objectForKey:@"channel"];
    // NSLog(@"User - %@",userAd);
    if([userAd  isEqual: adminPushChannel]){
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionButtonAction:)];
    }
    
    if (NSClassFromString(@"UIRefreshControl")) {
        // Use the new iOS 6 refresh control.
        UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
        self.refreshControl = refreshControl;
        self.refreshControl.tintColor = [UIColor whiteColor];
        [self.refreshControl addTarget:self action:@selector(refreshControlValueChanged:) forControlEvents:UIControlEventValueChanged];
        self.pullToRefreshEnabled = NO;
        self.refreshControl.layer.zPosition = self.tableView.backgroundView.layer.zPosition + 1;
    }
    
    // Register to be notified when the keyboard will be shown to scroll the view
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLikedOrUnlikedPhoto:) name:PAPUtilityUserLikedUnlikedPhotoCallbackFinishedNotification object:self.photo];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    [self.headerView reloadLikeBar];
    
    // we will only hit the network if we have no cached data for this photo
    BOOL hasCachedLikers = [[Cache sharedCache] attributesForPhoto:self.photo] != nil;
    if (!hasCachedLikers) {
        [self loadLikers];
    }
}

- (void)alertView:(UIAlertView *)message clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 0){
        
        NSLog(@"index-0");
        
        return;
    }
    
    if (buttonIndex == 1){
        
        NSLog(@"index-1");
    }
    
    if (buttonIndex == 2){
        
        NSLog(@"index-2");
    }
    
    if (buttonIndex == 3){
        
        NSLog(@"index-3");
    }
    
    if (buttonIndex == 4){
        
        NSLog(@"index-4");
    }
    
    NSString *reportedViolation = [message buttonTitleAtIndex:buttonIndex];
    NSString *userFirstName = [Utility firstNameForDisplayName:[[PFUser currentUser] objectForKey:kPAPUserDisplayNameKey]];
    NSString *alertMessage = [NSString stringWithFormat:@"%@: %@", userFirstName, reportedViolation];
    
    NSDictionary *payload =
    [NSDictionary dictionaryWithObjectsAndKeys:
    kAPNSSoundKey1,kAPNSSoundKey,kAPNSBadgeKey1,kAPNSBadgeKey, alertMessage, kAPNSAlertKey,
    kPAPPushPayloadPayloadTypeActivityKey, kPAPPushPayloadPayloadTypeKey,
    kPAPPushPayloadActivityCommentKey, kPAPPushPayloadActivityTypeKey,
    [[PFUser currentUser]objectId], kPAPPushPayloadFromUserObjectIdKey,
    [self.photo objectId], kPAPPushPayloadPhotoObjectIdKey,
    nil];
    NSLog(@"%@",payload);
    
    // Send the push
    PFPush *push = [[PFPush alloc] init];
    [push setChannel:adminPushChannel];
    [push setData:payload];
    [push sendPushInBackground];
  
    PFQuery *query = [PFQuery queryWithClassName: kPAPPhotoClassKey];
    NSString *photoObg = self.photo.objectId;
    
    // Retrieve the object by id
    [query getObjectInBackgroundWithId:photoObg block:^(PFObject *alertTag, NSError *error) {
        
        alertTag[@"alert"] = @"Objectionable";
        
        [alertTag saveInBackground];
        
    }];
    
    PFUser *admin = [PFUser objectWithoutDataWithObjectId:adminObjectId];
    NSLog(@"%@",admin);
    PFObject *alertAcive = [PFObject objectWithClassName:kPAPActivityClassKey];
    [alertAcive setObject:alertMessage forKey:kPAPActivityContentKey]; // Set alert text
    [alertAcive setObject:admin forKey:kPAPActivityToUserKey]; // Set toUser
    [alertAcive setObject:[PFUser currentUser] forKey:kPAPActivityFromUserKey]; // Set fromUser
    [alertAcive setObject:kPAPActivityTypeReport forKey:kPAPActivityTypeKey];
    [alertAcive setObject:self.photo forKey:kPAPActivityPhotoKey];
    
    PFACL *ACL = [PFACL ACLWithUser:[PFUser currentUser]];
    [ACL setPublicReadAccess:YES];
    [ACL setWriteAccess:YES forUser:[self.photo objectForKey:kPAPPhotoUserKey]];
    alertAcive.ACL = ACL;
    [alertAcive saveInBackground];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row < self.objects.count) { // A comment row
        PFObject *object = [self.objects objectAtIndex:indexPath.row];
        
        if (object) {
            NSString *commentString = [self.objects[indexPath.row] objectForKey:kPAPActivityContentKey];
            
            PFUser *commentAuthor = (PFUser *)[object objectForKey:kPAPActivityFromUserKey];
            
            NSString *nameString = @"";
            if (commentAuthor) {
                nameString = [commentAuthor objectForKey:kPAPUserDisplayNameKey];
            }
            
            return [ActivityCell heightForCellWithName:nameString contentString:commentString cellInsetWidth:kPAPCellInsetWidth];
        }
    }
    
    return 46.0f;
}

#pragma mark - PFQueryTableViewController

- (PFQuery *)queryForTable {
    
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    [query whereKey:kPAPActivityPhotoKey equalTo:self.photo];
    [query includeKey:kPAPActivityFromUserKey];
    [query whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeComment];
    [query orderByAscending:@"createdAt"];
    
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
    
    [self.headerView reloadLikeBar];
    [self loadLikers];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    static NSString *cellID = @"CommentCell";
    
    // Try to dequeue a cell and create one if necessary
    BaseTextCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[BaseTextCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.cellInsetWidth = kPAPCellInsetWidth;
        cell.delegate = self;
    }
    
    [cell setUser:[object objectForKey:kPAPActivityFromUserKey]];
    [cell setContentText:[object objectForKey:kPAPActivityContentKey]];
    [cell setDate:[object createdAt]];
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"NextPage";
    
    LoadMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[LoadMoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.cellInsetWidth = kPAPCellInsetWidth;
        cell.hideSeparatorTop = YES;
    }
    
    return cell;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    NSString *trimmedComment = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (trimmedComment.length != 0 && [self.photo objectForKey:kPAPPhotoUserKey]) {
        PFObject *comment = [PFObject objectWithClassName:kPAPActivityClassKey];
        [comment setObject:trimmedComment forKey:kPAPActivityContentKey]; // Set comment text
        [comment setObject:[self.photo objectForKey:kPAPPhotoUserKey] forKey:kPAPActivityToUserKey]; // Set toUser
        [comment setObject:[PFUser currentUser] forKey:kPAPActivityFromUserKey]; // Set fromUser
        [comment setObject:kPAPActivityTypeComment forKey:kPAPActivityTypeKey];
        [comment setObject:self.photo forKey:kPAPActivityPhotoKey];
        
        PFACL *ACL = [PFACL ACLWithUser:[PFUser currentUser]];
        [ACL setPublicReadAccess:YES];
        [ACL setWriteAccess:YES forUser:[self.photo objectForKey:kPAPPhotoUserKey]];
        comment.ACL = ACL;
        
        [[Cache sharedCache] incrementCommentCountForPhoto:self.photo];
        
        // Show HUD view
        [MBProgressHUD showHUDAddedTo:self.view.superview animated:YES];
        
        // If more than 5 seconds pass since we post a comment, stop waiting for the server to respond
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(handleCommentTimeout:) userInfo:@{@"comment": comment} repeats:NO];
        
        [comment saveEventually:^(BOOL succeeded, NSError *error) {
            
            [timer invalidate];
            
            if (error && error.code == kPFErrorObjectNotFound) {
                [[Cache sharedCache] decrementCommentCountForPhoto:self.photo];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Could not post your comment. This photo is no longer available." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                [alert show];
                [self.navigationController popViewControllerAnimated:YES];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:PAPPhotoDetailsViewControllerUserCommentedOnPhotoNotification object:self.photo userInfo:@{@"comments": @(self.objects.count + 1)}];
            
            [MBProgressHUD hideHUDForView:self.view.superview animated:YES];
            [self loadObjects];
            
            PFQuery *query = [Utility queryForActivitiesOnPhoto:self.photo cachePolicy:kPFCachePolicyNetworkOnly];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                
                // This will hold the channels we send the notification
                NSMutableSet *commenters = [NSMutableSet setWithCapacity:objects.count];

                for (PFObject *activity in objects) {
                    
                    if ([[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeComment] && [activity objectForKey:kPAPActivityToUserKey]) {
                        
                        if ([[[activity objectForKey:kPAPActivityToUserKey] objectId] isEqualToString:[[PFUser currentUser] objectId]])
                        {
                            
                        }
                        else
                        {
                            NSString *privateChannelName = [NSString stringWithFormat:@"user_%@", [[activity objectForKey:kPAPActivityToUserKey] objectId]];
                            [commenters addObject:privateChannelName];
                        }
                    }
                }
                
                // NSLog(@"Send comment push to users %@", commenters);
                
                if (commenters.count > 0) {
                    
                    // Create notification message
                    NSString *userFirstName = [Utility firstNameForDisplayName:[[PFUser currentUser] objectForKey:kPAPUserDisplayNameKey]];
                    NSString *message = [NSString stringWithFormat:@"%@: %@", userFirstName, trimmedComment];
                    
                    // Truncate message if necessary and ensure we have enough space
                    // for the rest of the payload
                    if (message.length > 100) {
                        message = [message substringToIndex:99];
                        message = [message stringByAppendingString:@"..."];
                    }
                    
                    NSDictionary *payload =
                    [NSDictionary dictionaryWithObjectsAndKeys:
                    kAPNSSoundKey1,kAPNSSoundKey,kAPNSBadgeKey1,kAPNSBadgeKey, message, kAPNSAlertKey,
                    kPAPPushPayloadPayloadTypeActivityKey, kPAPPushPayloadPayloadTypeKey,
                    kPAPPushPayloadActivityCommentKey, kPAPPushPayloadActivityTypeKey,
                    [[PFUser currentUser]objectId], kPAPPushPayloadFromUserObjectIdKey,
                    [self.photo objectId], kPAPPushPayloadPhotoObjectIdKey,
                     nil];
                    
                    // NSLog(@"%@", payload);
                    
                    // Send the push
                    PFPush *push = [[PFPush alloc] init];
                    [push setChannels:[commenters allObjects]];
                    [push setData:payload];
                    [push sendPushInBackground];
                }
            }];
        }];
    }
    
    [textField setText:@""];
    return [textField resignFirstResponder];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (actionSheet.tag == MainActionSheetTag) {
        
        if ([actionSheet destructiveButtonIndex] == buttonIndex) {
            
            // prompt to delete
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Are you sure you want to delete this photo?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Yes, delete photo" otherButtonTitles:nil];
            
            actionSheet.tag = ConfirmDeleteActionSheetTag;
            [actionSheet showFromTabBar:self.tabBarController.tabBar];
        }
        else if ([actionSheet cancelButtonIndex] == buttonIndex) {
            
        }
        else if (buttonIndex == 1) {
            
            [self activityButtonAction:actionSheet];
        }
        else if (buttonIndex == 2) {
            
            UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Report photo."
                                                              message:@""
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                                    otherButtonTitles:@"Photo incites violence", @"Photo contains nudity", @"Photo is offensive", @"Other", nil];
            [message show];
        }
    }
    else if (actionSheet.tag == AltActionSheetTag) {
        
        if ([actionSheet cancelButtonIndex] == buttonIndex) {
            
        }
        else if (buttonIndex == 0) {
            
            [self activityButtonAction:actionSheet];
        }
        else if (buttonIndex == 1) {
            
            UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Report photo."
                                                              message:@""
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                                    otherButtonTitles:@"Photo incites violence", @"Photo contains nudity", @"Photo is offensive", @"Other", nil];
            [message show];
        }
    }
    else if (actionSheet.tag == ConfirmDeleteActionSheetTag) {
        
        if ([actionSheet destructiveButtonIndex] == buttonIndex) {
            
            [self shouldDeletePhoto];
        }
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    [commentTextField resignFirstResponder];
}

#pragma mark - PAPBaseTextCellDelegate

- (void)cell:(BaseTextCell *)cellView didTapUserButton:(PFUser *)aUser {
    
    [self shouldPresentAccountViewForUser:aUser];
}

#pragma mark - PAPPhotoDetailsHeaderViewDelegate

- (void)photoDetailsHeaderView:(PhotoDetailsHeaderView *)headerView didTapUserButton:(UIButton *)button user:(PFUser *)user {
    
    [self shouldPresentAccountViewForUser:user];
}

- (void)actionButtonAction:(id)sender {
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
    actionSheet.delegate = self;
    actionSheet.tag = MainActionSheetTag;
    actionSheet.destructiveButtonIndex = [actionSheet addButtonWithTitle:@"Delete Photo"];
    
    if (NSClassFromString(@"UIActivityViewController")) {
        
        [actionSheet addButtonWithTitle:@"Share Photo"];
    }
    
    [actionSheet addButtonWithTitle:@"Report Photo"];
    
    actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:@"Cancel"];
    
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
}

- (void)altActionButtonAction:(id)sender {
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
    actionSheet.delegate = self;
    actionSheet.tag = AltActionSheetTag;
    
    if (NSClassFromString(@"UIActivityViewController")) {
        
        [actionSheet addButtonWithTitle:@"Share Photo"];
    }
    
    [actionSheet addButtonWithTitle:@"Report Photo"];
    
    actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:@"Cancel"];
    
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
}

- (void)activityButtonAction:(id)sender {
    
    if (NSClassFromString(@"UIActivityViewController")) {
        // TODO: Need to do something when the photo hasn't finished downloading!
        if ([[self.photo objectForKey:kPAPPhotoPictureKey] isDataAvailable]) {
            [self showShareSheet];
        } else {
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [[self.photo objectForKey:kPAPPhotoPictureKey] getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                if (!error) {
                    [self showShareSheet];
                }
            }];
        }
    }
}

- (void)showShareSheet {
    
    [[self.photo objectForKey:kPAPPhotoPictureKey] getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
            
            NSMutableArray *activityItems = [NSMutableArray arrayWithCapacity:3];
            
            // Prefill caption if this is the original poster of the photo, and then only if they added a caption initially.
            if ([[[PFUser currentUser] objectId] isEqualToString:[[self.photo objectForKey:kPAPPhotoUserKey] objectId]] && [self.objects count] > 0) {
                PFObject *firstActivity = self.objects[0];
                if ([[[firstActivity objectForKey:kPAPActivityFromUserKey] objectId] isEqualToString:[[self.photo objectForKey:kPAPPhotoUserKey] objectId]]) {
                    NSString *commentString = [firstActivity objectForKey:kPAPActivityContentKey];
                    [activityItems addObject:commentString];
                }
            }
            
            [activityItems addObject:[UIImage imageWithData:data]];
            
            UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
            
            activityViewController.excludedActivityTypes=@[UIActivityTypeMessage, UIActivityTypeMail];
            
            [self.navigationController presentViewController:activityViewController animated:YES completion:nil];
        }
    }];
}

- (void)handleCommentTimeout:(NSTimer *)aTimer {
   
    [MBProgressHUD hideHUDForView:self.view.superview animated:YES];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Something went wrong. Your comment will be posted the next time there is an internet connection." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alert show];
}

- (void)shouldPresentAccountViewForUser:(PFUser *)user {
    
    AccountViewController *accountViewController = [[AccountViewController alloc] initWithStyle:UITableViewStylePlain];
    [accountViewController setUser:user];
    [self.navigationController pushViewController:accountViewController animated:YES];
}

- (void)userLikedOrUnlikedPhoto:(NSNotification *)note {
    
    [self.headerView reloadLikeBar];
    
    PFQuery *query = [Utility queryForActivitiesOnPhoto:self.photo cachePolicy:kPFCachePolicyNetworkOnly];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        // This will hold the channels we send the notification
        NSMutableSet *likers = [NSMutableSet setWithCapacity:objects.count];

        for (PFObject *activity in objects) {
            
            if ([[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeLike] && [activity objectForKey:kPAPActivityToUserKey]) {
                
                if ([[[activity objectForKey:kPAPActivityToUserKey] objectId] isEqualToString:[[PFUser currentUser] objectId]])
                {
                    
                }
                else
                {
                    NSString *privateChannelName = [NSString stringWithFormat:@"user_%@", [[activity objectForKey:kPAPActivityToUserKey] objectId]];
                    [likers addObject:privateChannelName];
                }
            }
        }
        
        // NSLog(@"Send like push to users %@", likers);
        
        if (likers.count > 0) {
            
            // Create notification message
            NSString *userFirstName = [Utility firstNameForDisplayName:[[PFUser currentUser] objectForKey:kPAPUserDisplayNameKey]];
            NSString *message = [NSString stringWithFormat:@"%@: Liked your photo.", userFirstName];
            
            NSDictionary *payload =
            [NSDictionary dictionaryWithObjectsAndKeys:
            kAPNSSoundKey1,kAPNSSoundKey,kAPNSBadgeKey1,kAPNSBadgeKey, message, kAPNSAlertKey,
            kPAPPushPayloadPayloadTypeActivityKey, kPAPPushPayloadPayloadTypeKey,
            kPAPPushPayloadActivityLikeKey, kPAPPushPayloadActivityTypeKey,
            [[PFUser currentUser]objectId], kPAPPushPayloadFromUserObjectIdKey,
            [self.photo objectId], kPAPPushPayloadPhotoObjectIdKey,
             nil];
            
            // NSLog(@"%@", payload);
            
            // Send the push
            PFPush *push = [[PFPush alloc] init];
            [push setChannels:[likers allObjects]];
            [push setData:payload];
            [push sendPushInBackground];
        }
    }];
}

- (void)keyboardWillShow:(NSNotification*)note {
    // Scroll the view to the comment text box
    
    [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            CGSize result = [[UIScreen mainScreen] bounds].size;
            if(result.height == 480)
            {
                // NSLog(@"Classic iPhone/iPod Support");
            
                // Manully set contentInset.
                UIEdgeInsets currentInset = self.tableView.contentInset;
                currentInset.bottom = 0;
                
                self.tableView.contentInset = currentInset;

                [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentSize.height-282) animated:YES];
            }
            if(result.height == 568)
            {
                // NSLog(@"iPhone 5 Support");
                
                // Manully set contentInset.
                UIEdgeInsets currentInset = self.tableView.contentInset;
                currentInset.bottom = 0;
                
                self.tableView.contentInset = currentInset;

                [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentSize.height-370) animated:YES];
            }
        }

    } completion:^(BOOL finished) {
        
    }];
}

- (void)keyboardWillHide:(NSNotification*)note {
    // Scroll the view to the comment text box
    
    [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            CGSize result = [[UIScreen mainScreen] bounds].size;
            if(result.height == 480)
            {
                // NSLog(@"Classic iPhone/iPod Support");
                
                // Manully set contentInset.
                UIEdgeInsets currentInset;
                currentInset.top = self.navigationController.navigationBar.bounds.size.height;
                currentInset.top += 21;

                currentInset.bottom = 247;
                
                self.tableView.contentInset = currentInset;
            }
            if(result.height == 568)
            {
                // NSLog(@"iPhone 5 Support");
                
                // Manully set contentInset.
                UIEdgeInsets currentInset;
                currentInset.top = self.navigationController.navigationBar.bounds.size.height;
                currentInset.top += 20;

                currentInset.bottom = 247;
                
                self.tableView.contentInset = currentInset;
            }
        }
        
    } completion:^(BOOL finished) {
        
    }];
}

- (void)loadLikers {
    
    if (self.likersQueryInProgress) {
        return;
    }
    
    self.likersQueryInProgress = YES;
    PFQuery *query = [Utility queryForActivitiesOnPhoto:self.photo cachePolicy:kPFCachePolicyNetworkOnly];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        self.likersQueryInProgress = NO;
        if (error) {
            [self.headerView reloadLikeBar];
            return;
        }
        
        NSMutableArray *likers = [NSMutableArray array];
        NSMutableArray *commenters = [NSMutableArray array];
        
        BOOL isLikedByCurrentUser = NO;
        
        for (PFObject *activity in objects) {
            if ([[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeLike] && [activity objectForKey:kPAPActivityFromUserKey]) {
                [likers addObject:[activity objectForKey:kPAPActivityFromUserKey]];
                
            } else if ([[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeComment] && [activity objectForKey:kPAPActivityFromUserKey]) {
                [commenters addObject:[activity objectForKey:kPAPActivityFromUserKey]];
            }
            
            if ([[[activity objectForKey:kPAPActivityFromUserKey] objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
                if ([[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeLike]) {
                    isLikedByCurrentUser = YES;
                }
            }
        }
        
        [[Cache sharedCache] setAttributesForPhoto:self.photo likers:likers commenters:commenters likedByCurrentUser:isLikedByCurrentUser];
        [self.headerView reloadLikeBar];
    }];
}

- (void)refreshControlValueChanged:(UIRefreshControl *)refreshControl {
    
    [self loadObjects];
}

- (BOOL)currentUserOwnsPhoto {
    
    return [[[self.photo objectForKey:kPAPPhotoUserKey] objectId] isEqualToString:[[PFUser currentUser] objectId]];
}

- (void)shouldDeletePhoto {
    
    // Delete all activites related to this photo
    PFQuery *query = [PFQuery queryWithClassName:kPAPActivityClassKey];
    [query whereKey:kPAPActivityPhotoKey equalTo:self.photo];
    [query findObjectsInBackgroundWithBlock:^(NSArray *activities, NSError *error) {
        if (!error) {
            for (PFObject *activity in activities) {
                [activity deleteEventually];
            }
        }
        
        // Delete photo
        [self.photo deleteEventually];
    }];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:PAPPhotoDetailsViewControllerUserDeletedPhotoNotification object:[self.photo objectId]];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
