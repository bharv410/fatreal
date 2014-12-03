//
//  SettingsActionSheetDelegate.m
//  Snapify (from original AnyPic)
//
//  Modified by Christopher Coudriet on 12/31/13 (Created by Héctor Ramos on 5/04/12)
//  Copyright (c) 2013 Christopher Coudriet / 2012 Héctor Ramos. All rights reserved.
//

#import "SettingsActionSheetDelegate.h"
#import "AccountViewController.h"
#import "AppDelegate.h"

// ActionSheet button indexes
typedef enum {
	kPAPSettingsProfile = 0,
	kPAPSettingsFindFriends,
	kPAPSettingsLogout,
    kPAPSettingsNumberOfButtons
}   kPAPSettingsActionSheetButtons;

@implementation SettingsActionSheetDelegate

@synthesize navController;


- (id)initWithNavigationController:(UINavigationController *)navigationController {
    
    self = [super init];
    if (self) {
        navController = navigationController;
    }
    return self;
}

- (id)init {
    
    return [self initWithNavigationController:nil];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (!self.navController) {
        [NSException raise:NSInvalidArgumentException format:@"navController cannot be nil"];
        return;
    }
    
    switch ((kPAPSettingsActionSheetButtons)buttonIndex) {
        case kPAPSettingsProfile:
        {
            AccountViewController *accountViewController = [[AccountViewController alloc] initWithStyle:UITableViewStylePlain];
            [accountViewController setUser:[PFUser currentUser]];
            [navController pushViewController:accountViewController animated:YES];
            break;
        }
        case kPAPSettingsFindFriends:
        {
            [self performSelector:@selector(inviteFriendsButtonAction:) withObject:nil];
            break;
        }
        case kPAPSettingsLogout:
            // Log out user and present the login view controller
            [(AppDelegate *)[[UIApplication sharedApplication] delegate] logOut];
            break;
        default:
            break;
    }
}

#pragma mark - ABPeoplePickerDelegate

/* Called when the user cancels the address book view controller. We simply dismiss it. */
- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
    
    [navController dismissModalViewControllerAnimated:YES];
}

/* Called when a member of the address book is selected, we return YES to display the member's details. */
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person {
    
    return YES;
}

/* Called when the user selects a property of a person in their address book (ex. phone, email, location,...)
 This method will allow them to send a text or email inviting them to Anypic.  */
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:

(ABMultiValueIdentifier)identifier {
    
    if (property == kABPersonEmailProperty) {
        
        ABMultiValueRef emailProperty = ABRecordCopyValue(person,property);
        NSString *email = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(emailProperty,identifier);
        self.selectedEmailAddress = email;
        
        if ([MFMailComposeViewController canSendMail] && [MFMessageComposeViewController canSendText]) {
            // ask user
            
            UIAlertView *message = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Please choose how to send."]
                                                              message:@""
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                                    otherButtonTitles:@"Mail", @"iMessage", nil];
            [message show];
            
        }
        else if ([MFMailComposeViewController canSendMail]) {
            [self presentMailComposeViewController:email];
        }
        
    }
    else if (property == kABPersonPhoneProperty) {
        ABMultiValueRef phoneProperty = ABRecordCopyValue(person,property);
        NSString *phone = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(phoneProperty,identifier);
        
        if ([MFMessageComposeViewController canSendText]) {
            
            [self presentMessageComposeViewController:phone];
        }
    }
    
    return NO;
}

#pragma mark - MFMailComposeDelegate

/* Simply dismiss the MFMailComposeViewController when the user sends an email or cancels */
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    NSDictionary *textTitleOptions = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, [UIFont fontWithName:@"HelveticaNeue-Thin" size:24.0], NSFontAttributeName, nil];
    [[UINavigationBar appearance] setTitleTextAttributes:textTitleOptions];

    [navController dismissModalViewControllerAnimated:YES];
}

#pragma mark - MFMessageComposeDelegate

/* Simply dismiss the MFMessageComposeViewController when the user sends a text or cancels */
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    NSDictionary *textTitleOptions = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, [UIFont fontWithName:@"HelveticaNeue-Thin" size:24.0], NSFontAttributeName, nil];
    [[UINavigationBar appearance] setTitleTextAttributes:textTitleOptions];

    [navController dismissModalViewControllerAnimated:YES];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)message clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    NSString *title = [message buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"Cancel"])
    {
       return;
    }
    else if([title isEqualToString:@"Mail"])
    {
        [self presentMailComposeViewController:self.selectedEmailAddress];
    }
    else if([title isEqualToString:@"iMessage"])
    {
        [self presentMessageComposeViewController:self.selectedEmailAddress];
    }
}

- (void)inviteFriendsButtonAction:(id)sender {
    
    ABPeoplePickerNavigationController *addressBook = [[ABPeoplePickerNavigationController alloc] init];
    addressBook.peoplePickerDelegate = self;
    
    if ([MFMailComposeViewController canSendMail] && [MFMessageComposeViewController canSendText]) {
        addressBook.displayedProperties = [NSArray arrayWithObjects:[NSNumber numberWithInt:kABPersonEmailProperty], [NSNumber numberWithInt:kABPersonPhoneProperty], nil];
    } else if ([MFMailComposeViewController canSendMail]) {
        addressBook.displayedProperties = [NSArray arrayWithObject:[NSNumber numberWithInt:kABPersonEmailProperty]];
    } else if ([MFMessageComposeViewController canSendText]) {
        addressBook.displayedProperties = [NSArray arrayWithObject:[NSNumber numberWithInt:kABPersonPhoneProperty]];
    }
    
    [navController presentModalViewController:addressBook animated:YES];
}

- (void)presentMailComposeViewController:(NSString *)recipient {
    
    NSDictionary *textTitleOptions = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor], NSForegroundColorAttributeName, [UIFont fontWithName:@"HelveticaNeue-Thin" size:24.0], NSFontAttributeName, nil];
    [[UINavigationBar appearance] setTitleTextAttributes:textTitleOptions];

    // Create the compose email view controller
    MFMailComposeViewController *composeEmailViewController = [[MFMailComposeViewController alloc] init];
    
    // Set the recipient to the selected email and a default text
    [composeEmailViewController setMailComposeDelegate:self];
    [composeEmailViewController setSubject:@"Join me on Snapify"];
    [composeEmailViewController setToRecipients:[NSArray arrayWithObjects:recipient, nil]];
    
    // Attach an image to the email
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Icon-120" ofType:@"png"];
    NSData *myData = [NSData dataWithContentsOfFile:path];
    [composeEmailViewController addAttachmentData:myData mimeType:@"image/png" fileName:@"Icon-120"];
    
    // Attach App Store link
    NSString *iTunesLink = @"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=791071132&mt=8";
    
    // Fill out the email body text
    NSString *appDesc = [NSString stringWithFormat: @"<h2>Share your pictures, share your story.</h2><p><a href = '%@'>Download</a> the app now and start sharing your amazing photos with the world! See you soon!", iTunesLink];
    
    NSString *emailBody =
    [NSString stringWithFormat:@"<font color=black>%@</font><p>Sent from Snapify on my iPhone.", appDesc];
    
    [composeEmailViewController setMessageBody:emailBody isHTML:YES];

    composeEmailViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    composeEmailViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    [navController dismissModalViewControllerAnimated:NO];
    
    composeEmailViewController.navigationBar.tintColor = [UIColor blackColor];
    
    [composeEmailViewController.navigationBar setTranslucent:YES];
    
    [navController presentViewController:composeEmailViewController animated:YES completion:^{
        
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }];
}

- (void)presentMessageComposeViewController:(NSString *)recipient {
    
    NSDictionary *textTitleOptions = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor], NSForegroundColorAttributeName, [UIFont fontWithName:@"HelveticaNeue-Thin" size:24.0], NSFontAttributeName, nil];
    [[UINavigationBar appearance] setTitleTextAttributes:textTitleOptions];

    // Create the compose text message view controller
    MFMessageComposeViewController *composeTextViewController = [[MFMessageComposeViewController alloc] init];
    
    // Send the destination phone number and a default text
    [composeTextViewController setMessageComposeDelegate:self];
    [composeTextViewController setRecipients:[NSArray arrayWithObjects:recipient, nil]];
    
    [composeTextViewController setBody:@"Check out Snapify! http://goo.gl/bQp1pS"];
    
    // Attach an image to the email
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Icon-120" ofType:@"png"];
    NSData *myData = [NSData dataWithContentsOfFile:path];
    [composeTextViewController addAttachmentData:myData typeIdentifier:@"public.data" filename:@"image.png"];
    
    [navController dismissModalViewControllerAnimated:NO];
    
    composeTextViewController.navigationBar.tintColor = [UIColor blackColor];
    
    [composeTextViewController.navigationBar setTranslucent:YES];
    
    [navController presentViewController:composeTextViewController animated:NO completion:^{
        
       [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        
    }];
}

@end
