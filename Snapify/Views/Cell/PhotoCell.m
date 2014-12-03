//
//  PhotoCell.m
//  Snapify (from original AnyPic)
//
//  Modified by Christopher Coudriet on 12/31/13 (Created by Héctor Ramos on 5/04/12)
//  Copyright (c) 2013 Christopher Coudriet / 2012 Héctor Ramos. All rights reserved.
//

#import "PhotoCell.h"
#import "Utility.h"

@implementation PhotoCell
@synthesize photoButton;

#pragma mark - NSObject

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        // Initialization code
        self.opaque = NO;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryNone;
        self.clipsToBounds = NO;
        
        self.imageView.frame = CGRectMake( 0.0f, 0.0f, 320.0f, 320.0f);
        self.imageView.backgroundColor = [UIColor blackColor];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        self.photoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.photoButton.frame = CGRectMake( 0.0f, 0.0f, 320.0f, 320.0f);
        self.photoButton.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.photoButton];
        
        [self.contentView addSubview:self.imageView];
    }
    
    return self;
}

#pragma mark - UIView

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    self.imageView.frame = CGRectMake( 0.0f, 0.0f, 320.0f, 320.0f);
    self.photoButton.frame = CGRectMake( 0.0f, 0.0f, 320.0f, 320.0f);
}

@end
