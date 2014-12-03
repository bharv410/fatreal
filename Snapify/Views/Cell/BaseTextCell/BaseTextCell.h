//
//  BaseTextCell.h
//  Snapify (from original AnyPic)
//
//  Modified by Christopher Coudriet on 12/31/13 (Created by Héctor Ramos on 5/04/12)
//  Copyright (c) 2013 Christopher Coudriet / 2012 Héctor Ramos. All rights reserved.
//

@class ProfileImageView;
@protocol BaseTextCellDelegate;

@interface BaseTextCell : UITableViewCell {
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
#define vertBorderSpacing 6.0f
#define vertElemSpacing 3.0f

#define horiBorderSpacing 8.0f
#define horiBorderSpacingBottom 9.0f
#define horiElemSpacing 6.0f

#define vertTextBorderSpacing 7.0f

#define avatarX horiBorderSpacing
#define avatarY vertBorderSpacing
#define avatarDim 35.0f

#define nameX avatarX+avatarDim+horiElemSpacing
#define nameY vertTextBorderSpacing
#define nameMaxWidth 200.0f

#define timeX avatarX+avatarDim+horiElemSpacing

@protocol BaseTextCellDelegate <NSObject>
@optional

- (void)cell:(BaseTextCell *)cellView didTapUserButton:(PFUser *)aUser;

@end


