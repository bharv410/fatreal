//
//  PhotoDetailsFooterView.m
//  Snapify (from original AnyPic)
//
//  Modified by Christopher Coudriet on 12/31/13 (Created by Héctor Ramos on 5/04/12)
//  Copyright (c) 2013 Christopher Coudriet / 2012 Héctor Ramos. All rights reserved.
//

#import "PhotoDetailsFooterView.h"
#import "Utility.h"

@interface PhotoDetailsFooterView ()
@property (nonatomic, strong) UIView *mainView;
@property (nonatomic, strong) UIView *mainViewStop;
@end

@implementation PhotoDetailsFooterView

@synthesize commentField;
@synthesize mainView;
@synthesize mainViewStop;
@synthesize hideDropShadow;

#pragma mark - NSObject

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        
        mainView = [[UIView alloc] initWithFrame:CGRectMake( 0.0f, 0.0f, 320.0f, 51.0f)];
        mainView.backgroundColor = [UIColor colorWithRed:244.0/255.0 green:244.0/255.0 blue:244.0/255.0 alpha:1.0f];
        [self addSubview:mainView];
        
        UIImageView *messageIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"iconComment.png"]];
        messageIcon.frame = CGRectMake( 9.0f, 17.0f, 19.0f, 17.0f);
        [mainView addSubview:messageIcon];
        
        UIImageView *commentBox = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"textfieldComment.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(20.0f, 10.0f, 5.0f, 10.0f)]];
        commentBox.frame = CGRectMake(35.0f, 8.0f, 280.0f, 35.0f);
        [mainView addSubview:commentBox];
        
        commentField = [[UITextField alloc] initWithFrame:CGRectMake( 50.0f, 10.0f, 227.0f, 31.0f)];
        commentField.font = [UIFont systemFontOfSize:14.0f];
        commentField.placeholder = @"Write a comment...";
        commentField.returnKeyType = UIReturnKeySend;
        commentField.textColor = [UIColor blackColor];
        commentField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        [commentField setValue:[UIColor grayColor] forKeyPath:@"_placeholderLabel.textColor"];
        [mainView addSubview:commentField];
    }
    
    return self;
}

#pragma mark - UIView

- (void)drawRect:(CGRect)rect {
    
    [super drawRect:rect];
    
    if (!hideDropShadow) {
        [Utility drawSideAndBottomDropShadowForRect:mainView.frame inContext:UIGraphicsGetCurrentContext()];
    }
}

#pragma mark - PAPPhotoDetailsFooterView

+ (CGRect)rectForView {
    
    return CGRectMake( 0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, 69.0f);
}

@end

