//
//  PhotoHeaderView.m
//  Snapify (from original AnyPic)
//
//  Modified by Christopher Coudriet on 12/31/13 (Created by Héctor Ramos on 5/04/12)
//  Copyright (c) 2013 Christopher Coudriet / 2012 Héctor Ramos. All rights reserved.
//

#import "PhotoHeaderView.h"
#import "ProfileImageView.h"
#import "TTTTimeIntervalFormatter.h"
#import "Utility.h"

@interface PhotoHeaderView ()

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) ProfileImageView *avatarImageView;
@property (nonatomic, strong) UIButton *userButton;
@property (nonatomic, strong) UILabel *timestampLabel;
@property (nonatomic, strong) TTTTimeIntervalFormatter *timeIntervalFormatter;
@end

@implementation PhotoHeaderView

@synthesize containerView;
@synthesize avatarImageView;
@synthesize userButton;
@synthesize timestampLabel;
@synthesize timeIntervalFormatter;
@synthesize photo;
@synthesize buttons;
@synthesize likeButton;
@synthesize commentButton;
@synthesize delegate;


- (id)initWithFrame:(CGRect)frame buttons:(PAPPhotoHeaderButtons)otherButtons {
    
    self = [super initWithFrame:frame];
    if (self) {
        [PhotoHeaderView validateButtons:otherButtons];
        buttons = otherButtons;
        
        self.clipsToBounds = NO;
        self.containerView.clipsToBounds = NO;
        self.superview.clipsToBounds = NO;
        [self setBackgroundColor:[UIColor blackColor]];
        
        // translucent portion
        self.containerView = [[UIView alloc] initWithFrame:CGRectMake( 0.0f, 0.0f, self.bounds.size.width - 20.0f * 2.0f+40.0f, self.bounds.size.height)];
        [self addSubview:self.containerView];
        
        self.avatarImageView = [[ProfileImageView alloc] init];
        self.avatarImageView.frame = CGRectMake( 8.0f, 6.0f, 35.0f, 35.0f);
        [self.avatarImageView.profileButton addTarget:self action:@selector(didTapUserButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.containerView addSubview:self.avatarImageView];
        
        if (self.buttons & PAPPhotoHeaderButtonsComment) {
            // comments button
            commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [containerView addSubview:self.commentButton];
            [self.commentButton setFrame:CGRectMake( 280.0f, 6.0f, 35.0f, 35.0f)];
            [self.commentButton setBackgroundColor:[UIColor clearColor]];
            [self.commentButton setTitle:@"" forState:UIControlStateNormal];
            [self.commentButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [self.commentButton setTitleEdgeInsets:UIEdgeInsetsMake( -4.0f, 1.0f, 0.0f, 0.0f)];
            [[self.commentButton titleLabel] setShadowOffset:CGSizeMake( 0.0f, 1.0f)];
            [[self.commentButton titleLabel] setFont:[UIFont systemFontOfSize:10.0f]];
            [[self.commentButton titleLabel] setAdjustsFontSizeToFitWidth:YES];
            [self.commentButton setBackgroundImage:[UIImage imageNamed:@"iconComment.png"] forState:UIControlStateNormal];
            [self.commentButton setSelected:NO];
        }
        
        if (self.buttons & PAPPhotoHeaderButtonsLike) {
            // like button
            likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [containerView addSubview:self.likeButton];
            [self.likeButton setFrame:CGRectMake(240.0f, 6.0f, 35.0f, 35.0f)];
            [self.likeButton setBackgroundColor:[UIColor clearColor]];
            [self.likeButton setTitle:@"" forState:UIControlStateNormal];
            [self.likeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [self.likeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
            [self.likeButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
            [[self.likeButton titleLabel] setShadowOffset:CGSizeMake(0.0f, 1.0f)];
            [[self.likeButton titleLabel] setFont:[UIFont systemFontOfSize:10.0f]];
            [[self.likeButton titleLabel] setAdjustsFontSizeToFitWidth:YES];
            [self.likeButton setAdjustsImageWhenHighlighted:NO];
            [self.likeButton setAdjustsImageWhenDisabled:NO];
            [self.likeButton setBackgroundImage:[UIImage imageNamed:@"buttonLike.png"] forState:UIControlStateNormal];
            [self.likeButton setSelected:NO];
        }
        
        if (self.buttons & PAPPhotoHeaderButtonsUser) {
            // This is the user's display name, on a button so that we can tap on it
            self.userButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [containerView addSubview:self.userButton];
            [self.userButton setBackgroundColor:[UIColor clearColor]];
            [[self.userButton titleLabel] setFont:[UIFont boldSystemFontOfSize:15.0f]];
            [self.userButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [self.userButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
            [[self.userButton titleLabel] setLineBreakMode:NSLineBreakByTruncatingTail];
        }
        
        self.timeIntervalFormatter = [[TTTTimeIntervalFormatter alloc] init];
        
        // Timestamp
        self.timestampLabel = [[UILabel alloc] initWithFrame:CGRectMake( 50.0f, 24.0f, containerView.bounds.size.width - 50.0f - 72.0f, 18.0f)];
        [containerView addSubview:self.timestampLabel];
        [self.timestampLabel setTextColor:[UIColor grayColor]];
        [self.timestampLabel setFont:[UIFont systemFontOfSize:11.0f]];
        [self.timestampLabel setBackgroundColor:[UIColor clearColor]];
    }
    
    return self;
}

#pragma mark - PAPPhotoHeaderView

- (void)setPhoto:(PFObject *)aPhoto {
    
    photo = aPhoto;
    
    // user's avatar
    PFUser *user = [self.photo objectForKey:kPAPPhotoUserKey];
    PFFile *profilePictureSmall = [user objectForKey:kPAPUserProfilePicSmallKey];
    [self.avatarImageView setFile:profilePictureSmall];
    
    NSString *authorName = [user objectForKey:kPAPUserDisplayNameKey];
    [self.userButton setTitle:authorName forState:UIControlStateNormal];
    
    CGFloat constrainWidth = containerView.bounds.size.width;
    
    if (self.buttons & PAPPhotoHeaderButtonsUser) {
        [self.userButton addTarget:self action:@selector(didTapUserButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (self.buttons & PAPPhotoHeaderButtonsComment) {
        constrainWidth = self.commentButton.frame.origin.x;
        [self.commentButton addTarget:self action:@selector(didTapCommentOnPhotoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (self.buttons & PAPPhotoHeaderButtonsLike) {
        constrainWidth = self.likeButton.frame.origin.x;
        [self.likeButton addTarget:self action:@selector(didTapLikePhotoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    // we resize the button to fit the user's name to avoid having a huge touch area
    CGPoint userButtonPoint = CGPointMake(50.0f, 6.0f);
    constrainWidth -= userButtonPoint.x;
    CGSize constrainSize = CGSizeMake(constrainWidth, containerView.bounds.size.height - userButtonPoint.y*2.0f);
    CGSize userButtonSize = [self.userButton.titleLabel.text sizeWithFont:self.userButton.titleLabel.font constrainedToSize:constrainSize lineBreakMode:NSLineBreakByTruncatingTail];
    CGRect userButtonFrame = CGRectMake(userButtonPoint.x, userButtonPoint.y, userButtonSize.width, userButtonSize.height);
    [self.userButton setFrame:userButtonFrame];
    
    NSTimeInterval timeInterval = [[self.photo createdAt] timeIntervalSinceNow];
    NSString *timestamp = [self.timeIntervalFormatter stringForTimeInterval:timeInterval];
    [self.timestampLabel setText:timestamp];
    
    [self setNeedsDisplay];
}

- (void)setLikeStatus:(BOOL)liked {
    
    [self.likeButton setSelected:liked];
    
    if (liked) {
        [self.likeButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0f, 1.0f, 0.0f, 0.0f)];
        [[self.likeButton titleLabel] setShadowOffset:CGSizeMake(0.0f, 1.0f)];
    } else {
        [self.likeButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0f, 1.0f, 0.0f, 0.0f)];
        [[self.likeButton titleLabel] setShadowOffset:CGSizeMake(0.0f, 1.0f)];
    }
}

- (void)shouldEnableLikeButton:(BOOL)enable {
    
    if (enable) {
        [self.likeButton removeTarget:self action:@selector(didTapLikePhotoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        PFQuery *query = [Utility queryForActivitiesOnPhoto:photo cachePolicy:kPFCachePolicyNetworkOnly];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            // This will hold the channels we send the notification
            NSMutableSet *likers = [NSMutableSet setWithCapacity:objects.count];

            for (PFObject *activity in objects) {
                
                if ([[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeLike] && [activity objectForKey:kPAPActivityToUserKey]) {
                    
                    if ([[[activity objectForKey:kPAPActivityToUserKey] objectId] isEqualToString:[[PFUser currentUser] objectId]])
                    {
                        
                    }
                    else
                    {
                        NSString *privateChannelName = [NSString stringWithFormat:@"user_%@", [[activity objectForKey:kPAPActivityToUserKey] objectId]];
                        [likers addObject:privateChannelName];
                    }
                }
            }
            
            // NSLog(@"Send like push to users %@", likers);
            
            if (likers.count > 0) {
                
                // Create notification message
                NSString *userFirstName = [Utility firstNameForDisplayName:[[PFUser currentUser] objectForKey:kPAPUserDisplayNameKey]];
                NSString *message = [NSString stringWithFormat:@"%@: Liked your photo.", userFirstName];
                
                NSDictionary *payload =
                [NSDictionary dictionaryWithObjectsAndKeys:
                kAPNSSoundKey1,kAPNSSoundKey,kAPNSBadgeKey1,kAPNSBadgeKey, message, kAPNSAlertKey,
                kPAPPushPayloadPayloadTypeActivityKey, kPAPPushPayloadPayloadTypeKey,
                kPAPPushPayloadActivityLikeKey, kPAPPushPayloadActivityTypeKey,
                [[PFUser currentUser]objectId], kPAPPushPayloadFromUserObjectIdKey,
                [self.photo objectId], kPAPPushPayloadPhotoObjectIdKey,
                nil];
                
                // NSLog(@"%@", payload);
                
                // Send the push
                PFPush *push = [[PFPush alloc] init];
                [push setChannels:[likers allObjects]];
                [push setData:payload];
                [push sendPushInBackground];
            }
        }];

    } else {
        [self.likeButton addTarget:self action:@selector(didTapLikePhotoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
}

+ (void)validateButtons:(PAPPhotoHeaderButtons)buttons {
    
    if (buttons == PAPPhotoHeaderButtonsNone) {
        [NSException raise:NSInvalidArgumentException format:@"Buttons must be set before initializing PAPPhotoHeaderView."];
    }
}

- (void)didTapUserButtonAction:(UIButton *)sender {
    
    if (delegate && [delegate respondsToSelector:@selector(photoHeaderView:didTapUserButton:user:)]) {
        [delegate photoHeaderView:self didTapUserButton:sender user:[self.photo objectForKey:kPAPPhotoUserKey]];
    }
}

- (void)didTapLikePhotoButtonAction:(UIButton *)button {
   
    if (delegate && [delegate respondsToSelector:@selector(photoHeaderView:didTapLikePhotoButton:photo:)]) {
        [delegate photoHeaderView:self didTapLikePhotoButton:button photo:self.photo];
    }
}

- (void)didTapCommentOnPhotoButtonAction:(UIButton *)sender {
    
    if (delegate && [delegate respondsToSelector:@selector(photoHeaderView:didTapCommentOnPhotoButton:photo:)]) {
        [delegate photoHeaderView:self didTapCommentOnPhotoButton:sender photo:self.photo];
    }
}

@end

