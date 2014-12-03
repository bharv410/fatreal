//
//  BaseTextCell.h
//  Snapify (from original AnyPic)
//
//  Modified by Christopher Coudriet on 12/31/13 (Created by Héctor Ramos on 5/04/12)
//  Copyright (c) 2013 Christopher Coudriet / 2012 Héctor Ramos. All rights reserved.
//

@class ProfileImageView;
@protocol BaseTextCellDelegate2;

@interface BaseTextCell2 : UITableViewCell {
    NSUInteger horizontalTextSpace;
    id _delegate;
}

@property (nonatomic, strong) id delegate;

// The user represented in the cell
@property (nonatomic, strong) PFUser *user;

// The cell's views. These shouldn't be modified but need to be exposed for the subclass
@property (nonatomic, strong) UIView *mainView;
@property (nonatomic, strong) UIButton *nameButton;
@property (nonatomic, strong) UIButton *avatarImageButton;
@property (nonatomic, strong) ProfileImageView *avatarImageView;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UILabel *timeLabel;

// The horizontal inset of the cell
@property (nonatomic) CGFloat cellInsetWidth;

// Setters for the cell's content
- (void)setContentText:(NSString *)contentString;
- (void)setDate:(NSDate *)date;

- (void)setCellInsetWidth:(CGFloat)insetWidth;

// Static Helper methods
+ (CGFloat)heightForCellWithName:(NSString *)name contentString:(NSString *)content;
+ (CGFloat)heightForCellWithName:(NSString *)name contentString:(NSString *)content cellInsetWidth:(CGFloat)cellInset;
+ (NSString *)padString:(NSString *)string withFont:(UIFont *)font toWidth:(CGFloat)width;

@end

// Layout constants
#define vertBorderSpacing2 13.0f
#define vertElemSpacing2 0.0f

#define horiBorderSpacing2 8.0f
#define horiBorderSpacingBottom2 9.0f
#define horiElemSpacing2 5.0f

#define vertTextBorderSpacing2 7.0f

#define avatarX2 horiBorderSpacing2
#define avatarY2 vertBorderSpacing2
#define avatarDim2 35.0f

#define nameX2 avatarX2+avatarDim2+horiElemSpacing2
#define nameY2 vertTextBorderSpacing2
#define nameMaxWidth2 200.0f

#define timeX2 avatarX2+avatarDim2+horiElemSpacing2

@protocol BaseTextCellDelegate2 <NSObject>
@optional

- (void)cell:(BaseTextCell2 *)cellView didTapUserButton:(PFUser *)aUser;

@end


