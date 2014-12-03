//
//  PhotoDetailsViewController.h
//  Snapify (from original AnyPic)
//
//  Modified by Christopher Coudriet on 12/31/13 (Created by Héctor Ramos on 5/04/12)
//  Copyright (c) 2013 Christopher Coudriet / 2012 Héctor Ramos. All rights reserved.
//

#import "PhotoDetailsHeaderView.h"
#import "BaseTextCell.h"

@interface PhotoDetailsViewController : PFQueryTableViewController <UITextFieldDelegate, UIActionSheetDelegate, PhotoDetailsHeaderViewDelegate, BaseTextCellDelegate, UIAlertViewDelegate> {
    
    NSArray *parseAdminCreds;
    NSString *adminObjectId;
    NSString *adminPushChannel;
}

@property (nonatomic, strong) PFObject *photo;

// Parse Admin
@property (nonatomic, strong) NSArray *parseAdminCreds;
@property (nonatomic, strong) NSString *adminObjectId;
@property (nonatomic, strong) NSString *adminPushChannel;

- (id)initWithPhoto:(PFObject*)aPhoto;

@end

