//
//  EditPhotoViewController.m
//  Snapify (from original AnyPic)
//
//  Modified by Christopher Coudriet on 12/31/13 (Created by Héctor Ramos on 5/04/12)
//  Copyright (c) 2013 Christopher Coudriet / 2012 Héctor Ramos. All rights reserved.
//

#import "EditPhotoViewController.h"
#import "PhotoDetailsFooterView.h"
#import "UIImage+ResizeAdditions.h"
#import "AppDelegate.h"

@interface EditPhotoViewController ()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImage *image;

@property (nonatomic, strong) UITextField *commentTextField;
@property (nonatomic, strong) PFFile *photoFile;
@property (nonatomic, strong) PFFile *thumbnailFile;
@property (nonatomic, assign) UIBackgroundTaskIdentifier fileUploadBackgroundTaskId;
@property (nonatomic, assign) UIBackgroundTaskIdentifier photoPostBackgroundTaskId;

@end

@implementation EditPhotoViewController
@synthesize scrollView;
@synthesize image;
@synthesize commentTextField;
@synthesize photoFile;
@synthesize thumbnailFile;
@synthesize fileUploadBackgroundTaskId;
@synthesize photoPostBackgroundTaskId;

@synthesize fotoView;
@synthesize editImage;
@synthesize editImagePub;
@synthesize tapImage;
@synthesize parseAdminCreds;
@synthesize adminObjectId;
@synthesize adminPushChannel;


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (id)initWithImage:(UIImage *)aImage
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        if (!aImage) {
            return nil;
        }
        
        self.image = aImage;
        self.editImagePub = aImage;
        self.fileUploadBackgroundTaskId = UIBackgroundTaskInvalid;
        self.photoPostBackgroundTaskId = UIBackgroundTaskInvalid;
    }
    
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    NSLog(@"Memory warning on Edit");
}

// Aviary Photo Editor

- (void)displayEditorForImage:(UIImage *)imageToEdit
{
    NSArray * toolOrder = @[kAFEnhance, kAFEffects, kAFAdjustments, kAFFocus,  kAFStickers,  kAFOrientation, kAFCrop,  kAFSplash, kAFDraw, kAFText, kAFRedeye, kAFWhiten, kAFBlemish, kAFMeme , kAFFrames];
    [AFPhotoEditorCustomization setToolOrder:toolOrder];
    
    AFPhotoEditorController *editorController = [[AFPhotoEditorController alloc] initWithImage:editImagePub];
    
    [editorController setDelegate:self];
    [self presentViewController:editorController animated:YES completion:nil];
}

- (void)photoEditor:(AFPhotoEditorController *)editor finishedWithImage:(UIImage *)imageEdited
{
    [fotoView setImage:imageEdited];
    editImagePub = imageEdited;
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)photoEditorCanceled:(AFPhotoEditorController *)editor
{
    // Handle cancelation here
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)loadView
{
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 320.0f, 320.0f, 500.0f)];
    self.scrollView.alwaysBounceVertical = YES;
    self.scrollView.delegate = self;
    self.scrollView.backgroundColor = [UIColor whiteColor];
    self.view = self.scrollView;
    
    fotoView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 320.0f)];
    [fotoView setBackgroundColor:[UIColor blackColor]];
    [fotoView setImage:self.editImagePub];
    [fotoView setContentMode:UIViewContentModeScaleAspectFit];
    
    CALayer *layer = fotoView.layer;
    layer.masksToBounds = NO;
    layer.shadowRadius = 3.0f;
    layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
    layer.shadowOpacity = 0.25f;
    layer.shouldRasterize = YES;
    
    [self.scrollView addSubview:fotoView];
    
    UIButton *openEditor = [[UIButton alloc] initWithFrame:CGRectMake(0, 320, 320, 40)];
    [openEditor setBackgroundColor:[UIColor grayColor]];
    [openEditor setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [openEditor setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [openEditor setTitle:@"Open in Photo Editor" forState:UIControlStateNormal];
    [openEditor addTarget:self action:@selector(displayEditorForImage:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:openEditor];
    
    CGRect footerRect = [PhotoDetailsFooterView rectForView];
    footerRect.origin.y = fotoView.frame.origin.y + fotoView.frame.size.height +40;
    
    PhotoDetailsFooterView *footerView = [[PhotoDetailsFooterView alloc] initWithFrame:footerRect];
    self.commentTextField = footerView.commentField;
    self.commentTextField.delegate = self;
    [self.scrollView addSubview:footerView];
    
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.bounds.size.width, fotoView.frame.origin.y + fotoView.frame.size.height + footerView.frame.size.height)];
}

- (void)viewDidLoad
{
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
        adminObjectId = @"Not Found!";
        NSLog(@"adminObjectId = %@", adminObjectId);
        
        adminPushChannel = @"Not Found!";
        NSLog(@"adminPushChannel = %@", adminPushChannel);
    }
    
    
    self.navigationItem.title = @"Find A Trainer";
    
    [self.navigationController.navigationBar setTranslucent:YES];
    
    [self.navigationItem setHidesBackButton:YES];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelButtonAction:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Publish" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonAction:)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self doneButtonAction:textField];
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.commentTextField resignFirstResponder];
}

- (BOOL)shouldUploadImage:(UIImage *)anImage
{
    UIImage *resizedImage = [editImagePub resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(640.0f, 640.0f) interpolationQuality:kCGInterpolationHigh];
    UIImage *thumbnailImage = [editImagePub thumbnailImage:86.0f transparentBorder:0.0f cornerRadius:10.0f interpolationQuality:kCGInterpolationDefault];
    
    // JPEG to decrease file size and enable faster uploads & downloads
    NSData *imageData = UIImageJPEGRepresentation(resizedImage, 0.8f);
    NSData *thumbnailImageData = UIImagePNGRepresentation(thumbnailImage);
    
    if (!imageData || !thumbnailImageData) {
        return NO;
    }
    
    self.photoFile = [PFFile fileWithData:imageData];
    self.thumbnailFile = [PFFile fileWithData:thumbnailImageData];
    
    // Request a background execution task to allow us to finish uploading the photo even if the app is backgrounded
    self.fileUploadBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
    }];
    
    NSLog(@"Requested background expiration task with id %d for Snapify photo upload", self.fileUploadBackgroundTaskId);
    [self.photoFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"Photo uploaded successfully");
            [self.thumbnailFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    NSLog(@"Thumbnail uploaded successfully");
                }
                [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
            }];
        } else {
            [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
        }
    }];
    
    return YES;
}

- (void)keyboardWillShow:(NSNotification *)note
{
    CGRect keyboardFrameEnd = [[note.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGSize scrollViewContentSize = self.scrollView.bounds.size;
    scrollViewContentSize.height += keyboardFrameEnd.size.height;
    [self.scrollView setContentSize:scrollViewContentSize];
    
    CGPoint scrollViewContentOffset = self.scrollView.contentOffset;
    // Align the bottom edge of the photo with the keyboard
    scrollViewContentOffset.y = scrollViewContentOffset.y + keyboardFrameEnd.size.height*3.0f - [UIScreen mainScreen].bounds.size.height+43.0f;
    
    [self.scrollView setContentOffset:scrollViewContentOffset animated:YES];
}

- (void)keyboardWillHide:(NSNotification *)note
{
    CGRect keyboardFrameEnd = [[note.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGSize scrollViewContentSize = self.scrollView.bounds.size;
    scrollViewContentSize.height -= keyboardFrameEnd.size.height;
    [UIView animateWithDuration:0.200f animations:^{
        [self.scrollView setContentSize:scrollViewContentSize];
    }];
}

- (void)doneButtonAction:(id)sender
{
    NSLog(@"Comment - %@",self.commentTextField.text);
    
    if (commentTextField.text.length < 1){
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Please add a comment before publishing your photo." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
        
        return;
    }
    
    [self shouldUploadImage:image];
    NSDictionary *userInfo = [NSDictionary dictionary];
    NSString *trimmedComment = [self.commentTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (trimmedComment.length != 0) {
        userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                    trimmedComment,kPAPEditPhotoViewControllerUserInfoCommentKey,
                    nil];
    }
    
    if (!self.photoFile || !self.thumbnailFile) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Something went wrong. Could not post your photo. Please try again." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
        return;
    }
    
    // both files have finished uploading
    
    // create a photo object
    NSString *tagAlert = @"Photo";
    
    PFObject *photo = [PFObject objectWithClassName:kPAPPhotoClassKey];
    [photo setObject:[PFUser currentUser] forKey:kPAPPhotoUserKey];
    [photo setObject:self.photoFile forKey:kPAPPhotoPictureKey];
    [photo setObject:self.thumbnailFile forKey:kPAPPhotoThumbnailKey];
    [photo setObject:tagAlert forKey:@"alert"];
    
    // photos are public, but may only be modified by the user who uploaded them
    PFACL *photoACL = [PFACL ACLWithUser:[PFUser currentUser]];
    [photoACL setPublicReadAccess:YES];
    [photoACL setWriteAccess:YES forUserId:adminObjectId];
    
    photo.ACL = photoACL;
    
    // Request a background execution task to allow us to finish uploading the photo even if the app is backgrounded
    self.photoPostBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.photoPostBackgroundTaskId];
    }];
    
    // save
    [photo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            // NSLog(@"Photo uploaded");
            
            [[Cache sharedCache] setAttributesForPhoto:photo likers:[NSArray array] commenters:[NSArray array] likedByCurrentUser:NO];
            
            // userInfo might contain any caption which might have been posted by the uploader
            if (userInfo) {
                NSString *commentText = [userInfo objectForKey:kPAPEditPhotoViewControllerUserInfoCommentKey];
                
                if (commentText && commentText.length != 0) {
                    // create and save photo caption
                    PFObject *comment = [PFObject objectWithClassName:kPAPActivityClassKey];
                    [comment setObject:kPAPActivityTypeComment forKey:kPAPActivityTypeKey];
                    [comment setObject:photo forKey:kPAPActivityPhotoKey];
                    [comment setObject:[PFUser currentUser] forKey:kPAPActivityFromUserKey];
                    [comment setObject:[PFUser currentUser] forKey:kPAPActivityToUserKey];
                    [comment setObject:commentText forKey:kPAPActivityContentKey];
                    
                    PFACL *ACL = [PFACL ACLWithUser:[PFUser currentUser]];
                    [ACL setPublicReadAccess:YES];
                    comment.ACL = ACL;
                    
                    [comment saveEventually];
                    [[Cache sharedCache] incrementCommentCountForPhoto:photo];
                }
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:PAPTabBarControllerDidFinishEditingPhotoNotification object:photo];
        
        } else {
            
            NSLog(@"Photo failed to save: %@", error);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Something went wrong. Could not post your photo. Please try again." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alert show];
        }
        
        [[UIApplication sharedApplication] endBackgroundTask:self.photoPostBackgroundTaskId];
    }];
    
    [self.parentViewController dismissModalViewControllerAnimated:YES];
}

- (void)cancelButtonAction:(id)sender
{
    [self.parentViewController dismissModalViewControllerAnimated:YES];
}

@end