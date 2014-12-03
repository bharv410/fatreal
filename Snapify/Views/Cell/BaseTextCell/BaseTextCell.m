//
//  BaseTextCell.m
//  Snapify (from original AnyPic)
//
//  Modified by Christopher Coudriet on 12/31/13 (Created by Héctor Ramos on 5/04/12)
//  Copyright (c) 2013 Christopher Coudriet / 2012 Héctor Ramos. All rights reserved.
//

#import "BaseTextCell.h"
#import "TTTTimeIntervalFormatter.h"
#import "ProfileImageView.h"
#import "Utility.h"

static TTTTimeIntervalFormatter *timeFormatter;

@interface BaseTextCell ()
    

// Private static helper to obtain the horizontal space left for name and content after taking the inset and image in consideration
+ (CGFloat)horizontalTextSpaceForInsetWidth:(CGFloat)insetWidth;
@end

@implementation BaseTextCell

@synthesize mainView;
@synthesize cellInsetWidth;
@synthesize avatarImageView;
@synthesize avatarImageButton;
@synthesize nameButton;
@synthesize contentLabel;
@synthesize timeLabel;
@synthesize delegate;
@synthesize user;


#pragma mark - NSObject

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        // Initialization code
        if (!timeFormatter) {
            timeFormatter = [[TTTTimeIntervalFormatter alloc] init];
        }
        
        cellInsetWidth = 0.0f;
        self.clipsToBounds = YES;
        horizontalTextSpace =  [BaseTextCell horizontalTextSpaceForInsetWidth:cellInsetWidth];
        
        self.opaque = YES;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryNone;
        self.backgroundColor = [UIColor whiteColor];
        
        mainView = [[UIView alloc] initWithFrame:self.contentView.frame];
        [mainView setBackgroundColor:[UIColor whiteColor]];
        
        self.avatarImageView = [[ProfileImageView alloc] init];
        [self.avatarImageView setBackgroundColor:[UIColor clearColor]];
        [self.avatarImageView setOpaque:YES];
        [mainView addSubview:self.avatarImageView];
        
        self.nameButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.nameButton setBackgroundColor:[UIColor clearColor]];
        [self.nameButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.nameButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
        [self.nameButton.titleLabel setFont:[UIFont boldSystemFontOfSize:13.0f]];
        [self.nameButton.titleLabel setLineBreakMode:NSLineBreakByTruncatingTail];
        [self.nameButton addTarget:self action:@selector(didTapUserButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [mainView addSubview:self.nameButton];
        
        self.contentLabel = [[UILabel alloc] init];
        [self.contentLabel setFont:[UIFont systemFontOfSize:13.0f]];
        [self.contentLabel setTextColor:[UIColor blackColor]];
        [self.contentLabel setNumberOfLines:0];
        [self.contentLabel setLineBreakMode:NSLineBreakByTruncatingTail];
        [self.contentLabel setBackgroundColor:[UIColor clearColor]];
        [self.contentLabel setShadowOffset:CGSizeMake( 0.0f, 1.0f)];
        [mainView addSubview:self.contentLabel];
        
        self.timeLabel = [[UILabel alloc] init];
        [self.timeLabel setFont:[UIFont systemFontOfSize:11]];
        [self.timeLabel setTextColor:[UIColor grayColor]];
        [self.timeLabel setBackgroundColor:[UIColor clearColor]];
        [mainView addSubview:self.timeLabel];
        
        self.avatarImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.avatarImageButton setBackgroundColor:[UIColor clearColor]];
        [self.avatarImageButton addTarget:self action:@selector(didTapUserButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [mainView addSubview:self.avatarImageButton];
        
        [self.contentView addSubview:mainView];
    }
    
    return self;
}

#pragma mark - UIView

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    [mainView setFrame:CGRectMake(cellInsetWidth, self.contentView.frame.origin.y, self.contentView.frame.size.width-2*cellInsetWidth, self.contentView.frame.size.height)];
    
    // Layout avatar image
    [self.avatarImageView setFrame:CGRectMake(avatarX, avatarY, avatarDim, avatarDim)];
    [self.avatarImageButton setFrame:CGRectMake(avatarX, avatarY, avatarDim, avatarDim)];
    
    // Layout the name button
    CGSize nameSize = [self.nameButton.titleLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:13] forWidth:nameMaxWidth lineBreakMode:NSLineBreakByTruncatingTail];
    [self.nameButton setFrame:CGRectMake(nameX, nameY, nameSize.width, nameSize.height)];
    
    // Layout the content
    CGSize contentSize = [self.contentLabel.text sizeWithFont:[UIFont systemFontOfSize:13] constrainedToSize:CGSizeMake(horizontalTextSpace, CGFLOAT_MAX) lineBreakMode:NSLineBreakByTruncatingTail];
    [self.contentLabel setFrame:CGRectMake(nameX, vertTextBorderSpacing, contentSize.width, contentSize.height)];
    
    // Layout the timestamp label
    CGSize timeSize = [self.timeLabel.text sizeWithFont:[UIFont systemFontOfSize:11] forWidth:horizontalTextSpace lineBreakMode:NSLineBreakByTruncatingTail];
    [self.timeLabel setFrame:CGRectMake(timeX, contentLabel.frame.origin.y + contentLabel.frame.size.height + vertElemSpacing, timeSize.width, timeSize.height)];
}

- (void)drawRect:(CGRect)rect {
    
    // Add a drop shadow in core graphics on the sides of the cell
    [super drawRect:rect];
    if (self.cellInsetWidth != 0) {
        [Utility drawSideDropShadowForRect:mainView.frame inContext:UIGraphicsGetCurrentContext()];
    }
}

#pragma mark - Delegate methods

// Inform delegate that a user image or name was tapped
- (void)didTapUserButtonAction:(id)sender {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(cell:didTapUserButton:)]) {
        [self.delegate cell:self didTapUserButton:self.user];
    }
}

#pragma mark - PAPBaseTextCell

// Static helper to get the height for a cell if it had the given name and content
+ (CGFloat)heightForCellWithName:(NSString *)name contentString:(NSString *)content {
    
    return [BaseTextCell heightForCellWithName:name contentString:content cellInsetWidth:0];
}

// Static helper to get the height for a cell if it had the given name, content and horizontal inset
+ (CGFloat)heightForCellWithName:(NSString *)name contentString:(NSString *)content cellInsetWidth:(CGFloat)cellInset {
    
    CGSize nameSize = [name sizeWithFont:[UIFont boldSystemFontOfSize:13] forWidth:nameMaxWidth lineBreakMode:NSLineBreakByTruncatingTail];
    NSString *paddedString = [BaseTextCell padString:content withFont:[UIFont systemFontOfSize:13] toWidth:nameSize.width];
    CGFloat horizontalTextSpace = [BaseTextCell horizontalTextSpaceForInsetWidth:cellInset];
    
    CGSize contentSize = [paddedString sizeWithFont:[UIFont systemFontOfSize:13] constrainedToSize:CGSizeMake(horizontalTextSpace, CGFLOAT_MAX) lineBreakMode:NSLineBreakByTruncatingTail];
    CGFloat singleLineHeight = [@"test" sizeWithFont:[UIFont systemFontOfSize:13]].height;
    
    // Calculate the added height necessary for multiline text. Ensure value is not below 0.
    CGFloat multilineHeightAddition = (contentSize.height - singleLineHeight) > 0 ? (contentSize.height - singleLineHeight) : 0;
    
    return horiBorderSpacing + avatarDim + horiBorderSpacingBottom + multilineHeightAddition;
}

// Static helper to obtain the horizontal space left for name and content after taking the inset and image in consideration
+ (CGFloat)horizontalTextSpaceForInsetWidth:(CGFloat)insetWidth {
    
    return (320-(insetWidth*2)) - (horiBorderSpacing+avatarDim+horiElemSpacing+horiBorderSpacing);
}

// Static helper to pad a string with spaces to a given beginning offset
+ (NSString *)padString:(NSString *)string withFont:(UIFont *)font toWidth:(CGFloat)width {
    
    // Find number of spaces to pad
    NSMutableString *paddedString = [[NSMutableString alloc] init];
    while (true) {
        [paddedString appendString:@" "];
        if ([paddedString sizeWithFont:font].width >= width) {
            break;
        }
    }
    
    // Add final spaces to be ready for first word
    [paddedString appendString:[NSString stringWithFormat:@" %@", string]];
    return paddedString;
}

- (void)setUser:(PFUser *)aUser {
    
    user = aUser;

    // Set name button properties and avatar image
    [self.avatarImageView setFile:[self.user objectForKey:kPAPUserProfilePicSmallKey]];
    [self.nameButton setTitle:[self.user objectForKey:kPAPUserDisplayNameKey] forState:UIControlStateNormal];
    [self.nameButton setTitle:[self.user objectForKey:kPAPUserDisplayNameKey] forState:UIControlStateHighlighted];
    
    // If user is set after the contentText, we reset the content to include padding
    if (self.contentLabel.text) {
        [self setContentText:self.contentLabel.text];
    }
    [self setNeedsDisplay];
}

- (void)setContentText:(NSString *)contentString {
   
    // If we have a user we pad the content with spaces to make room for the name
    if (self.user) {
        CGSize nameSize = [self.nameButton.titleLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:13] forWidth:nameMaxWidth lineBreakMode:NSLineBreakByTruncatingTail];
        NSString *paddedString = [BaseTextCell padString:contentString withFont:[UIFont systemFontOfSize:13] toWidth:nameSize.width];
        [self.contentLabel setText:paddedString];
    } else { // Otherwise we ignore the padding and we'll add it after we set the user
        [self.contentLabel setText:contentString];
    }
    [self setNeedsDisplay];
}

- (void)setDate:(NSDate *)date {
    
    // Set the label with a human readable time
    [self.timeLabel setText:[timeFormatter stringForTimeIntervalFromDate:[NSDate date] toDate:date]];
    [self setNeedsDisplay];
}

- (void)setCellInsetWidth:(CGFloat)insetWidth {
    
    // Change the mainView's frame to be insetted by insetWidth and update the content text space
    cellInsetWidth = insetWidth;
    [mainView setFrame:CGRectMake(insetWidth, mainView.frame.origin.y, mainView.frame.size.width-2*insetWidth, mainView.frame.size.height)];
    horizontalTextSpace = [BaseTextCell horizontalTextSpaceForInsetWidth:insetWidth];
    [self setNeedsDisplay];
}

- (id<BaseTextCellDelegate>)delegate {
    
    return (id<BaseTextCellDelegate>)delegate;
}

- (void)setDelegate:(id<BaseTextCellDelegate>)aDelegate {
    
    if (delegate != aDelegate) {
        delegate = aDelegate;
    }
}

@end
