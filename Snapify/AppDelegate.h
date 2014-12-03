//
//  AppDelegate.h
//  Snapify (from original AnyPic)
//
//  Modified by Christopher Coudriet on 12/31/13 (Created by Héctor Ramos on 5/04/12)
//  Copyright (c) 2013 Christopher Coudriet / 2012 Héctor Ramos. All rights reserved.
//

#import "TabBarController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, NSURLConnectionDataDelegate, UITabBarControllerDelegate, PFLogInViewControllerDelegate> {
    
    NSDictionary *adminData;
}

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) TabBarController *tabBarController;
@property (nonatomic, strong) UINavigationController *navController;
@property (nonatomic, strong) NSDictionary *adminData;
@property (nonatomic, readonly) int networkStatus;

- (BOOL)isParseReachable;

- (void)presentLoginViewController;
- (void)presentLoginViewControllerAnimated:(BOOL)animated;
- (void)presentTabBarController;

- (void)logOut;

- (void)facebookRequestDidLoad:(id)result;
- (void)facebookRequestDidFailWithError:(NSError *)error;

@end
