//
//  SettingsActionSheetDelegate.h
//  Snapify (from original AnyPic)
//
//  Modified by Christopher Coudriet on 12/31/13 (Created by Héctor Ramos on 5/04/12)
//  Copyright (c) 2013 Christopher Coudriet / 2012 Héctor Ramos. All rights reserved.
//

#import <AddressBookUI/AddressBookUI.h>
#import <MessageUI/MessageUI.h>
#import <Foundation/Foundation.h>

@interface SettingsActionSheetDelegate : NSObject <UIActionSheetDelegate, ABPeoplePickerNavigationControllerDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate>

// Navigation controller of calling view controller
@property (nonatomic, strong) NSString *selectedEmailAddress;
@property (nonatomic, strong) UINavigationController *navController;

- (id)initWithNavigationController:(UINavigationController *)navigationController;

@end
