//
//  AccountViewController.m
//  Snapify (from original AnyPic)
//
//  Modified by Christopher Coudriet on 12/31/13 (Created by Héctor Ramos on 5/04/12)
//  Copyright (c) 2013 Christopher Coudriet / 2012 Héctor Ramos. All rights reserved.
//

#import "AccountViewController.h"
#import "PhotoCell.h"
#import "TTTTimeIntervalFormatter.h"
#import "LoadMoreCell.h"
#import "UIImage+ResizeAdditions.h"

@interface AccountViewController()
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIActionSheet *editprofile;
@property (nonatomic, strong) UIActionSheet *editphoto;
@property (nonatomic, strong) UILabel *userDisplayNameLabel;
@property (nonatomic, strong) PFImageView *profilePictureImageView;
@end

@implementation AccountViewController
@synthesize headerView;
@synthesize user;
@synthesize photopr;
@synthesize profimage;


- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.navigationItem.title = @"Profile";
    
    if (!self.user) {
        
        [NSException raise:NSInvalidArgumentException format:@"user cannot be nil"];
    }
    
    // TO DO: Properly handle saving new profile image and display name
    // self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editMyProfile)];
    
    UIView *texturedBackgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    [texturedBackgroundView setBackgroundColor:[UIColor blackColor]];
    self.tableView.backgroundView = texturedBackgroundView;

    self.headerView = [[UIView alloc] initWithFrame:CGRectMake( 0.0f, 0.0f, self.tableView.bounds.size.width, 237.0f)];
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        CGSize result = [[UIScreen mainScreen] bounds].size;
        if(result.height == 480)
        {
            // NSLog(@"Classic iPhone/iPod Support");
            
            UIImageView *profileBackgroundImageView = [[UIImageView alloc] initWithImage:nil];
            [profileBackgroundImageView setImage:[UIImage imageNamed:@"profileBg.png"]];
            [profileBackgroundImageView setFrame:CGRectMake( 0.0f, -4.0f, 320.0f, 237.0f)];
            [self.headerView addSubview:profileBackgroundImageView];
        }
        if(result.height == 568)
        {
            // NSLog(@"iPhone 5 Support");
            
            UIImageView *profileBackgroundImageView = [[UIImageView alloc] initWithImage:nil];
            [profileBackgroundImageView setImage:[UIImage imageNamed:@"profileBg.png"]];
            [profileBackgroundImageView setFrame:CGRectMake( 0.0f, -3.0f, 320.0f, 237.0f)];
            [self.headerView addSubview:profileBackgroundImageView];
        }
    }

    UIView *profilePictureBackgroundView = [[UIView alloc] initWithFrame:CGRectMake( 94.0f, 2.0f, 100.0f, 100.0f)];
    profilePictureBackgroundView.alpha = 0.0f;
    CALayer *layer = [profilePictureBackgroundView layer];
    _profilePictureImageView = [[PFImageView alloc] initWithFrame:CGRectMake( 110.0f, 15.0f, 100.0f, 100.0f)];
    [self.headerView addSubview:_profilePictureImageView];
    [_profilePictureImageView setContentMode:UIViewContentModeScaleAspectFill];
    layer = [_profilePictureImageView layer];
    layer.cornerRadius = 50.0f;
    
    layer.masksToBounds = YES;
    _profilePictureImageView.alpha = 0.0f;
    
    PFFile *imageFile = [self.user objectForKey:kPAPUserProfilePicMediumKey];
    if (imageFile) {
        [_profilePictureImageView setFile:imageFile];
        [_profilePictureImageView loadInBackground:^(UIImage *image, NSError *error) {
            if (!error) {
                [UIView animateWithDuration:0.900f animations:^{
                   
                    _profilePictureImageView.alpha = 1.0f;
                }];
            }
        }];
    
    }
    
    UIImageView *photoCountIconImageView = [[UIImageView alloc] initWithImage:nil];
    [photoCountIconImageView setImage:[UIImage imageNamed:@"iconPics.png"]];
    [photoCountIconImageView setFrame:CGRectMake( 30.0f, 170.0f, 35.0f, 24.0f)];
    [self.headerView addSubview:photoCountIconImageView];
    
    UIImageView *followersIconImageView = [[UIImageView alloc] initWithImage:nil];
    [followersIconImageView setImage:[UIImage imageNamed:@"iconFollowers.png"]];
    [followersIconImageView setFrame:CGRectMake( 140.0f, 170.0f, 35.0f, 24.0f)];
    [self.headerView addSubview:followersIconImageView];
    
    UIImageView *followersIconImageView1 = [[UIImageView alloc] initWithImage:nil];
    [followersIconImageView1 setImage:[UIImage imageNamed:@"iconFollowers.png"]];
    [followersIconImageView1 setFrame:CGRectMake( 250.0f, 170.0f, 35.0f, 24.0f)];
    [self.headerView addSubview:followersIconImageView1];
    
    UILabel *photoCountLabel = [[UILabel alloc] initWithFrame:CGRectMake( 22.0f, 185.0f, 50.f, 50.0f)];
    [photoCountLabel setNumberOfLines:2];
    [photoCountLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [photoCountLabel setTextAlignment:NSTextAlignmentCenter];
    [photoCountLabel setBackgroundColor:[UIColor clearColor]];
    [photoCountLabel setTextColor:[UIColor whiteColor]];
    [photoCountLabel setShadowOffset:CGSizeMake( 0.0f, -1.0f)];
    [photoCountLabel setFont:[UIFont boldSystemFontOfSize:12.0f]];
    [self.headerView addSubview:photoCountLabel];

    UILabel *followerCountLabel = [[UILabel alloc] initWithFrame:CGRectMake( 129.0f, 185.0f, 60.0f, 50.0f)];
    [followerCountLabel setNumberOfLines:2];
    [followerCountLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [followerCountLabel setTextAlignment:NSTextAlignmentCenter];
    [followerCountLabel setBackgroundColor:[UIColor clearColor]];
    [followerCountLabel setTextColor:[UIColor whiteColor]];
    [followerCountLabel setShadowOffset:CGSizeMake( 0.0f, -1.0f)];
    [followerCountLabel setFont:[UIFont boldSystemFontOfSize:12.0f]];
    [self.headerView addSubview:followerCountLabel];
    
    UILabel *followingCountLabel = [[UILabel alloc] initWithFrame:CGRectMake( 238.0f, 185.0f, 60.0f, 50.0f)];
    [followingCountLabel setNumberOfLines:2];
    [followingCountLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [followingCountLabel setTextAlignment:NSTextAlignmentCenter];
    [followingCountLabel setBackgroundColor:[UIColor clearColor]];
    [followingCountLabel setTextColor:[UIColor whiteColor]];
    [followingCountLabel setShadowOffset:CGSizeMake( 0.0f, -1.0f)];
    [followingCountLabel setFont:[UIFont boldSystemFontOfSize:12.0f]];
    [self.headerView addSubview:followingCountLabel];
    
    _userDisplayNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 125.0f, 320.f, 20.0f)];
    [_userDisplayNameLabel setTextAlignment:NSTextAlignmentCenter];
    [_userDisplayNameLabel setBackgroundColor:[UIColor clearColor]];
    [_userDisplayNameLabel setTextColor:[UIColor whiteColor]];
    [_userDisplayNameLabel setShadowOffset:CGSizeMake( 0.0f, -1.0f)];
    [_userDisplayNameLabel setText:[self.user objectForKey:@"displayName"]];
    [_userDisplayNameLabel setFont:[UIFont boldSystemFontOfSize:18.0f]];
    [self.headerView addSubview:_userDisplayNameLabel];
    
    NSString *photos = @"Photos";
    [photoCountLabel setText:[NSString stringWithFormat:(@"%@ 0"), photos]];
    
    PFQuery *queryPhotoCount = [PFQuery queryWithClassName:@"Photo"];
    [queryPhotoCount whereKey:kPAPPhotoUserKey equalTo:self.user];
    [queryPhotoCount setCachePolicy:kPFCachePolicyCacheThenNetwork];
    [queryPhotoCount countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (!error) {
            
            [photoCountLabel setText:[NSString stringWithFormat:@"%@ %d", photos, number]];
            [[Cache sharedCache] setPhotoCount:[NSNumber numberWithInt:number] user:self.user];
        }
    }];
    
    NSString *followers = @"Followers";
    [followerCountLabel setText:[NSString stringWithFormat:(@"%@ 0"), followers]];
    
    PFQuery *queryFollowerCount = [PFQuery queryWithClassName:kPAPActivityClassKey];
    [queryFollowerCount whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeFollow];
    [queryFollowerCount whereKey:kPAPActivityToUserKey equalTo:self.user];
    [queryFollowerCount setCachePolicy:kPFCachePolicyCacheThenNetwork];
    [queryFollowerCount countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (!error) {
            
            [followerCountLabel setText:[NSString stringWithFormat:@"%@ %d", followers, number]];
        }
    }];
    
    NSString *following = @"Following";
    NSDictionary *followingDictionary = [[PFUser currentUser] objectForKey:@"following"];
    [followingCountLabel setText:[NSString stringWithFormat:(@"%@ 0"), following]];
    if (followingDictionary) {
        
        [followingCountLabel setText:[NSString stringWithFormat:@"%@ %d", following, [[followingDictionary allValues] count]]];
    }
    
    PFQuery *queryFollowingCount = [PFQuery queryWithClassName:kPAPActivityClassKey];
    [queryFollowingCount whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeFollow];
    [queryFollowingCount whereKey:kPAPActivityFromUserKey equalTo:self.user];
    [queryFollowingCount setCachePolicy:kPFCachePolicyCacheThenNetwork];
    [queryFollowingCount countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (!error) {
            
            [followingCountLabel setText:[NSString stringWithFormat:@"%@ %d", following, number]];
        }
    }];
    
    if (![[self.user objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
        UIActivityIndicatorView *loadingActivityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [loadingActivityIndicatorView startAnimating];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:loadingActivityIndicatorView];
        
        // check if the currentUser is following this user
        PFQuery *queryIsFollowing = [PFQuery queryWithClassName:kPAPActivityClassKey];
        [queryIsFollowing whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeFollow];
        [queryIsFollowing whereKey:kPAPActivityToUserKey equalTo:self.user];
        [queryIsFollowing whereKey:kPAPActivityFromUserKey equalTo:[PFUser currentUser]];
        [queryIsFollowing setCachePolicy:kPFCachePolicyCacheThenNetwork];
        [queryIsFollowing countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
            if (error && [error code] != kPFErrorCacheMiss) {
                NSLog(@"Couldn't determine follow relationship: %@", error);
                self.navigationItem.rightBarButtonItem = nil;
            } else {
                if (number == 0) {
                    [self configureFollowButton];
                } else {
                    [self configureUnfollowButton];
                }
            }
        }];
    }
}

#pragma mark - PFQueryTableViewController

- (void)objectsDidLoad:(NSError *)error {
    
    [super objectsDidLoad:error];
    
    self.tableView.tableHeaderView = headerView;
}

- (PFQuery *)queryForTable {
    
    if (!self.user) {
        PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
        [query setLimit:0];
        return query;
    }
    
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    query.cachePolicy = kPFCachePolicyNetworkOnly;
    if (self.objects.count == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    [query whereKey:kPAPPhotoUserKey equalTo:self.user];
    [query orderByDescending:@"createdAt"];
    [query includeKey:kPAPPhotoUserKey];
    
    return query;
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

- (void)followButtonAction:(id)sender {
    
    UIActivityIndicatorView *loadingActivityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [loadingActivityIndicatorView startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:loadingActivityIndicatorView];
    
    [self configureUnfollowButton];
    
    [Utility followUserEventually:self.user block:^(BOOL succeeded, NSError *error) {
        if (error) {
            [self configureFollowButton];
        }
    }];
}

- (void)unfollowButtonAction:(id)sender {
    
    UIActivityIndicatorView *loadingActivityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [loadingActivityIndicatorView startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:loadingActivityIndicatorView];
    
    [self configureFollowButton];
    
    [Utility unfollowUserEventually:self.user];
}

- (void)configureFollowButton {
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Follow" style:UIBarButtonItemStyleBordered target:self action:@selector(followButtonAction:)];
    [[Cache sharedCache] setFollowStatus:NO user:self.user];
}

- (void)configureUnfollowButton {
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Unfollow" style:UIBarButtonItemStyleBordered target:self action:@selector(unfollowButtonAction:)];
    [[Cache sharedCache] setFollowStatus:YES user:self.user];
}

- (void)editMyProfile {
    
    _editprofile = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Edit Profile Photo", @"Edit Display Name", nil];
    
    [_editprofile showFromTabBar:self.tabBarController.tabBar];
    [self.profilePictureImageView setNeedsDisplay];
}

- (void)editPhoto {
    
    _editphoto = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo", @"Choose album", nil];
    
    [_editphoto showFromTabBar:self.tabBarController.tabBar];
    
    [self.profilePictureImageView setNeedsDisplay];
}

- (void)editName {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Please enter a new display name." message:nil delegate:self cancelButtonTitle:@"Done" otherButtonTitles:nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if(actionSheet == _editprofile){
        
        if(buttonIndex == 0){
            
            [self editPhoto];
            
        }else if (buttonIndex == 1){
            
            [self editName];
            
        }else if (buttonIndex == 2){
            
            return;
        }
        
    } else if (actionSheet == _editphoto){
        
        if (buttonIndex == 0) {
            
            [self shouldStartCameraController];
            
        }else if (buttonIndex == 1) {
            
            [self shouldStartPhotoLibraryPickerController];
            
        }else if (buttonIndex == 2) {
            
            return;
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    NSString *name =  [alertView textFieldAtIndex:0].text;
    
    NSLog(@"My new name - %@",name);
    
    [[PFUser currentUser] setObject:name forKey:kPAPUserDisplayNameKey];
    [[PFUser currentUser] saveEventually];
    
    [_userDisplayNameLabel setText:name];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {

    [self dismissModalViewControllerAnimated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    [self dismissModalViewControllerAnimated:NO];
    
    photopr = [info objectForKey:UIImagePickerControllerEditedImage];
    
    // Section upload photo profile and resize
    UIImage *image = photopr;
    
    UIImage *mediumImage = [image thumbnailImage:280 transparentBorder:0 cornerRadius:0 interpolationQuality:kCGInterpolationHigh];
    UIImage *smallRoundedImage = [image thumbnailImage:64 transparentBorder:0 cornerRadius:9 interpolationQuality:kCGInterpolationLow];
    
    NSData *mediumImageData = UIImageJPEGRepresentation(mediumImage, 0.5); // using JPEG for larger pictures
    NSData *smallRoundedImageData = UIImagePNGRepresentation(smallRoundedImage);
    
    if (mediumImageData.length > 0) {
        PFFile *fileMediumImage = [PFFile fileWithData:mediumImageData];
        [fileMediumImage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                [[PFUser currentUser] setObject:fileMediumImage forKey:kPAPUserProfilePicMediumKey];
                [[PFUser currentUser] saveEventually];
            }
        }];
    }
    
    if (smallRoundedImageData.length > 0) {
        PFFile *fileSmallRoundedImage = [PFFile fileWithData:smallRoundedImageData];
        [fileSmallRoundedImage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                [[PFUser currentUser] setObject:fileSmallRoundedImage forKey:kPAPUserProfilePicSmallKey];
                [[PFUser currentUser] saveEventually];
            }
        }];
    }
    
    [self.profilePictureImageView setImage:photopr];
}

- (BOOL)shouldPresentPhotoCaptureController {
    
    BOOL presentedPhotoCaptureController = [self shouldStartCameraController];
    
    if (!presentedPhotoCaptureController) {
        presentedPhotoCaptureController = [self shouldStartPhotoLibraryPickerController];
    }
    
    return presentedPhotoCaptureController;
}

- (BOOL)shouldStartCameraController {
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO) {
        return NO;
    }
    
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]
        && [[UIImagePickerController availableMediaTypesForSourceType:
             UIImagePickerControllerSourceTypeCamera] containsObject:(NSString *)kUTTypeImage]) {
        
        cameraUI.mediaTypes = [NSArray arrayWithObject:(NSString *) kUTTypeImage];
        cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]) {
            cameraUI.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        } else if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) {
            cameraUI.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        }
        
    } else {
        return NO;
    }
    
    cameraUI.allowsEditing = YES;
    cameraUI.showsCameraControls = YES;
    cameraUI.delegate = self;
    
    [self presentModalViewController:cameraUI animated:YES];
    
    return YES;
}

- (BOOL)shouldStartPhotoLibraryPickerController {
    
    if (([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] == NO
         && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO)) {
        return NO;
    }
    
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]
        && [[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary] containsObject:(NSString *)kUTTypeImage]) {
        
        cameraUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        cameraUI.mediaTypes = [NSArray arrayWithObject:(NSString *) kUTTypeImage];
        
    } else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]
               && [[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum] containsObject:(NSString *)kUTTypeImage]) {
        
        cameraUI.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        cameraUI.mediaTypes = [NSArray arrayWithObject:(NSString *) kUTTypeImage];
        
    } else {
        return NO;
    }
    
    cameraUI.allowsEditing = YES;
    cameraUI.delegate = self;
    
    [self presentModalViewController:cameraUI animated:YES];
    
    return YES;
}

- (void)handleGesture:(UIGestureRecognizer *)gestureRecognizer {
    
    [self shouldPresentPhotoCaptureController];
}

@end