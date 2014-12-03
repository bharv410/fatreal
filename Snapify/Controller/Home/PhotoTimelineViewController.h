//
//  PhotoTimelineViewController.h
//  Snapify (from original AnyPic)
//
//  Modified by Christopher Coudriet on 12/31/13 (Created by Héctor Ramos on 5/04/12)
//  Copyright (c) 2013 Christopher Coudriet / 2012 Héctor Ramos. All rights reserved.
//

#import "PhotoHeaderView.h"

@interface PhotoTimelineViewController : PFQueryTableViewController <PhotoHeaderViewDelegate>

- (PhotoHeaderView *)dequeueReusableSectionHeaderView;

@end
