//
//  FindFriendsCell.h
//  Snapify (from original AnyPic)
//
//  Modified by Christopher Coudriet on 12/31/13 (Created by Héctor Ramos on 5/04/12)
//  Copyright (c) 2013 Christopher Coudriet / 2012 Héctor Ramos. All rights reserved.
//

@class ProfileImageView;
@protocol FindFriendsCellDelegate;

@interface FindFriendsCell : UITableViewCell {
    id _delegate;
}

@property (nonatomic, strong) id<FindFriendsCellDelegate> delegate;

// The user represented in the cell
@property (nonatomic, strong) PFUser *user;
@property (nonatomic, strong) UILabel *photoLabel;
@property (nonatomic, strong) UIButton *nameButton;
@property (nonatomic, strong) UIButton *followButton;
@property (nonatomic, strong) UIButton *currentUserButton;

// Setters for the cell's content
- (void)setUser:(PFUser *)user;

- (void)didTapUserButtonAction:(id)sender;
- (void)didTapFollowButtonAction:(id)sender;

// Static Helper methods
+ (CGFloat)heightForCell;

@end

@protocol FindFriendsCellDelegate <NSObject>
@optional

- (void)cell:(FindFriendsCell *)cellView didTapUserButton:(PFUser *)aUser;

- (void)cell:(FindFriendsCell *)cellView didTapFollowButton:(PFUser *)aUser;

@end

