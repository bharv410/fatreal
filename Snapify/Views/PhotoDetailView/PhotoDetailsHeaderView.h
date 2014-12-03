//
//  PhotoDetailsHeaderView.h
//  Snapify (from original AnyPic)
//
//  Modified by Christopher Coudriet on 12/31/13 (Created by Héctor Ramos on 5/04/12)
//  Copyright (c) 2013 Christopher Coudriet / 2012 Héctor Ramos. All rights reserved.
//

@protocol PhotoDetailsHeaderViewDelegate;

@interface PhotoDetailsHeaderView : UIView

// The photo displayed in the view
@property (nonatomic, strong, readonly) PFObject *photo;

// The user that took the photo
@property (nonatomic, strong, readonly) PFUser *photographer;

// Array of the users that liked the photo
@property (nonatomic, strong) NSArray *likeUsers;

// Heart-shaped like button
@property (nonatomic, strong, readonly) UIButton *likeButton;

// Objectionable indicator
@property (nonatomic, strong) UILabel *objectionable;

// Delegate
@property (nonatomic, strong) id<PhotoDetailsHeaderViewDelegate> delegate;

+ (CGRect)rectForView;

- (id)initWithFrame:(CGRect)frame photo:(PFObject*)aPhoto;
- (id)initWithFrame:(CGRect)frame photo:(PFObject*)aPhoto photographer:(PFUser*)aPhotographer likeUsers:(NSArray*)theLikeUsers;

- (void)setLikeButtonState:(BOOL)selected;
- (void)reloadLikeBar;

@end


@protocol PhotoDetailsHeaderViewDelegate <NSObject>
@optional

- (void)photoDetailsHeaderView:(PhotoDetailsHeaderView *)headerView didTapUserButton:(UIButton *)button user:(PFUser *)user;

@end
