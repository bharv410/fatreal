//
//  FindFriendsCell.m
//  Snapify (from original AnyPic)
//
//  Modified by Christopher Coudriet on 12/31/13 (Created by Héctor Ramos on 5/04/12)
//  Copyright (c) 2013 Christopher Coudriet / 2012 Héctor Ramos. All rights reserved.
//

#import "FindFriendsCell.h"
#import "ProfileImageView.h"

@interface FindFriendsCell ()

// The cell's views. These shouldn't be modified but need to be exposed for the subclass
@property (nonatomic, strong) UIButton *avatarImageButton;
@property (nonatomic, strong) ProfileImageView *avatarImageView;

@end

@implementation FindFriendsCell
@synthesize delegate;
@synthesize user;
@synthesize avatarImageView;
@synthesize avatarImageButton;
@synthesize nameButton;
@synthesize photoLabel;
@synthesize followButton;
@synthesize currentUserButton;

#pragma mark - NSObject

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier ];
    if (self) {
        [self.contentView setBackgroundColor:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1]];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        self.avatarImageView = [[ProfileImageView alloc] init];
        [self.avatarImageView setFrame:CGRectMake( 10.0f, 12.0f, 35.0f, 35.0f)];
        [self.contentView addSubview:self.avatarImageView];
        
        self.avatarImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.avatarImageButton setBackgroundColor:[UIColor clearColor]];
        [self.avatarImageButton setFrame:CGRectMake( 10.0f, 12.0f, 35.0f, 35.0f)];
        [self.avatarImageButton addTarget:self action:@selector(didTapUserButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.avatarImageButton];
        
        self.nameButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.nameButton setBackgroundColor:[UIColor clearColor]];
        [self.nameButton.titleLabel setFont:[UIFont boldSystemFontOfSize:13.0f]];
        [self.nameButton.titleLabel setLineBreakMode:NSLineBreakByTruncatingTail];
        [self.nameButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.nameButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
        [self.nameButton.titleLabel setShadowOffset:CGSizeMake( 0.0f, 1.0f)];
        [self.nameButton addTarget:self action:@selector(didTapUserButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.nameButton];
        
        self.photoLabel = [[UILabel alloc] init];
        [self.photoLabel setFont:[UIFont systemFontOfSize:11.0f]];
        [self.photoLabel setTextColor:[UIColor grayColor]];
        [self.photoLabel setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:self.photoLabel];
        
        self.currentUserButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.currentUserButton.titleLabel setFont:[UIFont boldSystemFontOfSize:15.0f]];
        [self.currentUserButton setTitleEdgeInsets:UIEdgeInsetsMake( 0.0f, 10.0f, 0.0f, 0.0f)];
        [self.currentUserButton setTitle:@"Me" forState:UIControlStateNormal]; // space added for centering
        [self.currentUserButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [self.currentUserButton.titleLabel setShadowOffset:CGSizeMake( 0.0f, -1.0f)];
        [self.contentView addSubview:self.currentUserButton];
        
        self.followButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.followButton.titleLabel setFont:[UIFont boldSystemFontOfSize:15.0f]];
        [self.followButton setTitleEdgeInsets:UIEdgeInsetsMake( 0.0f, 10.0f, 0.0f, 0.0f)];
        [self.followButton setTitle:@"Follow" forState:UIControlStateNormal]; // space added for centering
        [self.followButton setTitle:@"Following" forState:UIControlStateSelected];
        [self.followButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [self.followButton setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
        [self.followButton.titleLabel setShadowOffset:CGSizeMake( 0.0f, -1.0f)];
        [self.followButton addTarget:self action:@selector(didTapFollowButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.followButton];
    }
    
    return self;
}

#pragma mark - PAPFindFriendsCell

- (void)setUser:(PFUser *)aUser {
   
    user = aUser;
    
    // Configure the cell
    [avatarImageView setFile:[self.user objectForKey:kPAPUserProfilePicSmallKey]];
    
    // Set name
    NSString *nameString = [self.user objectForKey:kPAPUserDisplayNameKey];
    CGSize nameSize = [nameString sizeWithFont:[UIFont boldSystemFontOfSize:13.0f] forWidth:144.0f lineBreakMode:NSLineBreakByTruncatingTail];
    [nameButton setTitle:[self.user objectForKey:kPAPUserDisplayNameKey] forState:UIControlStateNormal];
    [nameButton setTitle:[self.user objectForKey:kPAPUserDisplayNameKey] forState:UIControlStateHighlighted];
    
    [nameButton setFrame:CGRectMake( 50.0f, 15.0f, nameSize.width, nameSize.height)];
    
    // Set photo number label
    CGSize photoLabelSize = [@"Photos" sizeWithFont:[UIFont systemFontOfSize:11.0f] forWidth:144.0f lineBreakMode:NSLineBreakByTruncatingTail];
    [photoLabel setFrame:CGRectMake( 50.0f, 15.0f + nameSize.height, 140.0f, photoLabelSize.height)];
    
    // Set follow button
    PFUser *currentUser = [PFUser currentUser];
    
    NSString *title = self.nameButton.titleLabel.text;
    
    if([title isEqualToString:[currentUser objectForKey:@"displayName"]])
    {
        // NSLog(@"%@", title);
        
        [currentUserButton setFrame:CGRectMake( 208.0f, 13.0f, 103.0f, 32.0f)];
    }
    else
    {
        [followButton setFrame:CGRectMake( 208.0f, 13.0f, 103.0f, 32.0f)];
    }
}

+ (CGFloat)heightForCell {
    
    return 60.0f;
}

// Inform delegate that a user image or name was tapped
- (void)didTapUserButtonAction:(id)sender {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(cell:didTapUserButton:)]) {
        
         [self.delegate cell:self didTapUserButton:self.user];
    }
}

- (void)didTapFollowButtonAction:(id)sender {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(cell:didTapFollowButton:)]) {
        
        [self.delegate cell:self didTapFollowButton:self.user];
    }
}

@end
