//
//  ProfileImageView.m
//  Snapify (from original AnyPic)
//
//  Modified by Christopher Coudriet on 12/31/13 (Created by Héctor Ramos on 5/04/12)
//  Copyright (c) 2013 Christopher Coudriet / 2012 Héctor Ramos. All rights reserved.
//

#import "ProfileImageView.h"

@interface ProfileImageView ()
@end

@implementation ProfileImageView

@synthesize profileImageView;
@synthesize profileButton;

#pragma mark - NSObject

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        self.profileImageView = [[PFImageView alloc] initWithFrame:frame];
        [self addSubview:self.profileImageView];
        
        self.profileButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:self.profileButton];
    }
    
    return self;
}

#pragma mark - UIView

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    self.profileImageView.frame = CGRectMake( 0.0f, 0.0f, self.frame.size.width, self.frame.size.height);
    self.profileButton.frame = CGRectMake( 0.0f, 0.0f, self.frame.size.width, self.frame.size.height);
}

#pragma mark - PAPProfileImageView

- (void)setFile:(PFFile *)file {
    
    if (!file) {
        return;
    }
    
    self.profileImageView.file = file;
    [self.profileImageView loadInBackground];
}

@end
