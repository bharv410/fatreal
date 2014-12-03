//
//  PhotoHeaderView.h
//  Snapify (from original AnyPic)
//
//  Modified by Christopher Coudriet on 12/31/13 (Created by Héctor Ramos on 5/04/12)
//  Copyright (c) 2013 Christopher Coudriet / 2012 Héctor Ramos. All rights reserved.
//

typedef enum {
    PAPPhotoHeaderButtonsNone = 0,
    PAPPhotoHeaderButtonsLike = 1 << 0,
    PAPPhotoHeaderButtonsComment = 1 << 1,
    PAPPhotoHeaderButtonsUser = 1 << 2,
    
    PAPPhotoHeaderButtonsDefault = PAPPhotoHeaderButtonsLike | PAPPhotoHeaderButtonsComment | PAPPhotoHeaderButtonsUser
}   PAPPhotoHeaderButtons;

@protocol PhotoHeaderViewDelegate;

@interface PhotoHeaderView : UIView

- (id)initWithFrame:(CGRect)frame buttons:(PAPPhotoHeaderButtons)otherButtons;

// The photo associated with this view
@property (nonatomic, strong) PFObject *photo;

// The bitmask which specifies the enabled interaction elements in the view
@property (nonatomic, readonly, assign) PAPPhotoHeaderButtons buttons;

// The Like Photo button
@property (nonatomic, readonly) UIButton *likeButton;

// The Comment On Photo button
@property (nonatomic, readonly) UIButton *commentButton;

// Delegate
@property (nonatomic, weak) id <PhotoHeaderViewDelegate> delegate;

- (void)setLikeStatus:(BOOL)liked;

- (void)shouldEnableLikeButton:(BOOL)enable;

@end


@protocol PhotoHeaderViewDelegate <NSObject>
@optional

- (void)photoHeaderView:(PhotoHeaderView *)photoHeaderView didTapUserButton:(UIButton *)button user:(PFUser *)user;

- (void)photoHeaderView:(PhotoHeaderView *)photoHeaderView didTapLikePhotoButton:(UIButton *)button photo:(PFObject *)photo;

- (void)photoHeaderView:(PhotoHeaderView *)photoHeaderView didTapCommentOnPhotoButton:(UIButton *)button photo:(PFObject *)photo;

@end