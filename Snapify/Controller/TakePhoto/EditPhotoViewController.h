//
//  EditPhotoViewController.h
//  Snapify (from original AnyPic)
//
//  Modified by Christopher Coudriet on 12/31/13 (Created by Héctor Ramos on 5/04/12)
//  Copyright (c) 2013 Christopher Coudriet / 2012 Héctor Ramos. All rights reserved.
//

#import "AFPhotoEditorController.h"

@interface EditPhotoViewController : UIViewController <UITextFieldDelegate, UIScrollViewDelegate, AFPhotoEditorControllerDelegate> {
    
    UIImageView *fotoView;
    UIImage *editImage;
    UIImage *editImagePub;
    NSString *tapImage;
    
    NSArray *parseAdminCreds;
    NSString *adminObjectId;
    NSString *adminPushChannel;
}

@property (nonatomic, strong) UIImageView *fotoView;
@property (nonatomic, strong) UIImage *editImage;
@property (nonatomic, strong) UIImage *editImagePub;
@property (nonatomic, strong) NSData *videoData;
@property (nonatomic, strong) NSString *tapImage;

// Parse Admin
@property (nonatomic, strong) NSArray *parseAdminCreds;
@property (nonatomic, strong) NSString *adminObjectId;
@property (nonatomic, strong) NSString *adminPushChannel;

- (id)initWithImage:(UIImage *)aImage;

@end

