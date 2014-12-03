//
//  AccountViewController.h
//  Snapify (from original AnyPic)
//
//  Modified by Christopher Coudriet on 12/31/13 (Created by Héctor Ramos on 5/04/12)
//  Copyright (c) 2013 Christopher Coudriet / 2012 Héctor Ramos. All rights reserved.
//

#import "PhotoTimelineViewController.h"

@interface AccountViewController : PhotoTimelineViewController <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIAlertViewDelegate>{
    
    UIImage *photopr;
    UIImage *profimage;
}

@property (nonatomic, strong) PFUser *user;
@property (nonatomic, strong) UIImage *photopr;
@property (nonatomic, strong) UIImage *profimage;

- (BOOL)shouldPresentPhotoCaptureController;

@end
