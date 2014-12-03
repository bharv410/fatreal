//
//  LoadMoreCell.m
//  Snapify (from original AnyPic)
//
//  Modified by Christopher Coudriet on 12/31/13 (Created by Héctor Ramos on 5/04/12)
//  Copyright (c) 2013 Christopher Coudriet / 2012 Héctor Ramos. All rights reserved.
//

#import "LoadMoreCell.h"
#import "Utility.h"

@implementation LoadMoreCell

@synthesize cellInsetWidth;
@synthesize mainView;
@synthesize loadMoreImageView;
@synthesize hideSeparatorTop;
@synthesize hideSeparatorBottom;

#pragma mark - NSObject

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        // Initialization code
        self.cellInsetWidth = 0.0f;
        hideSeparatorTop = NO;
        hideSeparatorBottom = NO;
        
        self.opaque = YES;
        self.selectionStyle = UITableViewCellSelectionStyleGray;
        self.accessoryType = UITableViewCellAccessoryNone;
        self.backgroundColor = [UIColor clearColor];
        
        mainView = [[UIView alloc] initWithFrame:self.contentView.frame];
        
        self.loadMoreImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loadMoreCell.png"]];
        
        self.loadMoreImageView.frame = CGRectMake( 0.0f, 5.0f, 320.0f, 31.0f);
        
        [mainView addSubview:self.loadMoreImageView];
        
        [self.contentView addSubview:mainView];
    }
    
    return self;
}

#pragma mark - UIView

- (void)layoutSubviews {
    
    [mainView setFrame:CGRectMake( self.cellInsetWidth, self.contentView.frame.origin.y, self.contentView.frame.size.width-2*self.cellInsetWidth, self.contentView.frame.size.height)];
}

- (void)drawRect:(CGRect)rect {
    
    [super drawRect:rect];
    if (self.cellInsetWidth != 0.0f) {
        [Utility drawSideDropShadowForRect:mainView.frame inContext:UIGraphicsGetCurrentContext()];
    }
}

#pragma mark - PAPLoadMoreCell

- (void)setCellInsetWidth:(CGFloat)insetWidth {
    
    cellInsetWidth = insetWidth;
    [mainView setFrame:CGRectMake( insetWidth, mainView.frame.origin.y, mainView.frame.size.width - 2.0f * insetWidth, mainView.frame.size.height)];
    [self setNeedsDisplay];
}

@end
