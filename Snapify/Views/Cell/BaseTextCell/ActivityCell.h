//
//  ActivityCell.h
//  Snapify (from original AnyPic)
//
//  Modified by Christopher Coudriet on 12/31/13 (Created by Héctor Ramos on 5/04/12)
//  Copyright (c) 2013 Christopher Coudriet / 2012 Héctor Ramos. All rights reserved.
//

#import "BaseTextCell2.h"
@protocol ActivityCellDelegate;

@interface ActivityCell : BaseTextCell2

// Setter for the activity associated with this cell
@property (nonatomic, strong) PFObject *activity;

// Set the new state. This changes the background of the cell
- (void)setIsNew:(BOOL)isNew;

@end

@protocol ActivityCellDelegate <BaseTextCellDelegate2>
@optional

- (void)cell:(ActivityCell *)cellView didTapActivityButton:(PFObject *)activity;

@end
