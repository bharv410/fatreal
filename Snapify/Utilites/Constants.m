//
//  Constants.m
//  Snapify (from original AnyPic)
//
//  Modified by Christopher Coudriet on 12/31/13 (Created by Héctor Ramos on 5/04/12)
//  Copyright (c) 2013 Christopher Coudriet / 2012 Héctor Ramos. All rights reserved.
//

#import "Constants.h"

NSString *const kPAPUserDefaultsActivityFeedViewControllerLastRefreshKey    = @"com.developer.snapify.userDefaults.activityFeedViewController.lastRefresh";
NSString *const kPAPUserDefaultsCacheFacebookFriendsKey                     = @"com.developer.snapify.userDefaults.cache.facebookFriends";


#pragma mark - Launch URLs
// Field keys
NSString *const kPAPLaunchURLHostTakePicture = @"camera";


#pragma mark - NSNotification
// Field keys
NSString *const PAPAppDelegateApplicationDidReceiveRemoteNotification           = @"com.developer.snapify.appDelegate.applicationDidReceiveRemoteNotification";
NSString *const PAPUtilityUserFollowingChangedNotification                      = @"com.developer.snapify.utility.userFollowingChanged";
NSString *const PAPUtilityUserLikedUnlikedPhotoCallbackFinishedNotification     = @"com.developer.snapify.utility.userLikedUnlikedPhotoCallbackFinished";
NSString *const PAPUtilityDidFinishProcessingProfilePictureNotification         = @"com.developer.snapify.utility.didFinishProcessingProfilePictureNotification";
NSString *const PAPTabBarControllerDidFinishEditingPhotoNotification            = @"com.developer.snapify.tabBarController.didFinishEditingPhoto";
NSString *const PAPTabBarControllerDidFinishImageFileUploadNotification         = @"com.developer.snapify.tabBarController.didFinishImageFileUploadNotification";
NSString *const PAPPhotoDetailsViewControllerUserDeletedPhotoNotification       = @"com.developer.snapify.photoDetailsViewController.userDeletedPhoto";
NSString *const PAPPhotoDetailsViewControllerUserLikedUnlikedPhotoNotification  = @"com.developer.snapify.photoDetailsViewController.userLikedUnlikedPhotoInDetailsViewNotification";
NSString *const PAPPhotoDetailsViewControllerUserCommentedOnPhotoNotification   = @"com.developer.snapify.photoDetailsViewController.userCommentedOnPhotoInDetailsViewNotification";


#pragma mark - User Info Keys
// Field keys
NSString *const PAPPhotoDetailsViewControllerUserLikedUnlikedPhotoNotificationUserInfoLikedKey = @"liked";
NSString *const kPAPEditPhotoViewControllerUserInfoCommentKey = @"comment";


#pragma mark - Installation Class
// Field keys
NSString *const kPAPInstallationUserKey = @"user";
NSString *const kPAPInstallationChannelsKey = @"channels";


#pragma mark - Activity Class
// Class key
NSString *const kPAPActivityClassKey = @"Activity";

// Field keys
NSString *const kPAPActivityTypeKey     = @"type";
NSString *const kPAPActivityFromUserKey = @"fromUser";
NSString *const kPAPActivityToUserKey   = @"toUser";
NSString *const kPAPActivityContentKey  = @"content";
NSString *const kPAPActivityPhotoKey    = @"photo";
NSString *const kPAPPhotoObjectionable  = @"alert";

// Type values
NSString *const kPAPActivityTypeLike       = @"like";
NSString *const kPAPActivityTypeFollow     = @"follow";
NSString *const kPAPActivityTypeComment    = @"comment";
NSString *const kPAPActivityTypeJoined     = @"joined";
NSString *const kPAPActivityTypeReport     = @"report";


#pragma mark - User Class
// Field keys
NSString *const kPAPUserDisplayNameKey                          = @"displayName";
NSString *const kPAPUserFacebookIDKey                           = @"facebookId";
NSString *const kPAPUserPhotoIDKey                              = @"photoId";
NSString *const kPAPUserProfilePicSmallKey                      = @"profilePictureSmall";
NSString *const kPAPUserProfilePicMediumKey                     = @"profilePictureMedium";
NSString *const kPAPUserFacebookFriendsKey                      = @"facebookFriends";
NSString *const kPAPUserAlreadyAutoFollowedFacebookFriendsKey   = @"userAlreadyAutoFollowedFacebookFriends";
NSString *const kPAPUserPrivateChannelKey                       = @"channel";


#pragma mark - Photo Class
// Class key
NSString *const kPAPPhotoClassKey = @"Photo";

// Field keys
NSString *const kPAPPhotoPictureKey         = @"image";
NSString *const kPAPPhotoThumbnailKey       = @"thumbnail";
NSString *const kPAPPhotoUserKey            = @"user";
NSString *const kPAPPhotoOpenGraphIDKey     = @"fbOpenGraphID";


#pragma mark - Cached Photo Attributes
// Field keys
NSString *const kPAPPhotoAttributesIsLikedByCurrentUserKey = @"isLikedByCurrentUser";
NSString *const kPAPPhotoAttributesLikeCountKey            = @"likeCount";
NSString *const kPAPPhotoAttributesLikersKey               = @"likers";
NSString *const kPAPPhotoAttributesCommentCountKey         = @"commentCount";
NSString *const kPAPPhotoAttributesCommentersKey           = @"commenters";


#pragma mark - Cached User Attributes
// Field keys
NSString *const kPAPUserAttributesPhotoCountKey                 = @"photoCount";
NSString *const kPAPUserAttributesIsFollowedByCurrentUserKey    = @"isFollowedByCurrentUser";


#pragma mark - Push Notification Payload Keys
// Field keys
NSString *const kAPNSAlertKey = @"alert";
NSString *const kAPNSBadgeKey = @"badge";
NSString *const kAPNSSoundKey = @"sound";
NSString *const kAPNSBadgeKey1 = @"Increment";
NSString *const kAPNSSoundKey1 = @"";

// the following keys are intentionally kept short, APNS has a maximum payload limit
NSString *const kPAPPushPayloadPayloadTypeKey          = @"p";
NSString *const kPAPPushPayloadPayloadTypeActivityKey  = @"a";

NSString *const kPAPPushPayloadActivityTypeKey     = @"t";
NSString *const kPAPPushPayloadActivityLikeKey     = @"l";
NSString *const kPAPPushPayloadActivityCommentKey  = @"c";
NSString *const kPAPPushPayloadActivityFollowKey   = @"f";

NSString *const kPAPPushPayloadFromUserObjectIdKey = @"fu";
NSString *const kPAPPushPayloadToUserObjectIdKey   = @"tu";
NSString *const kPAPPushPayloadPhotoObjectIdKey    = @"pid";
