

/* Copyright 2012 Mobli Media inc.
 *
 *  The following code is derived from Facebook iOS sdk.
 *  Modifications were made to all original methods by Ariel Krieger, Mobli, 05/16/2012
 *

 
 ********** Original Facebook License *************************************
  
         * Copyright 2010 Facebook
         *
         * Licensed under the Apache License, Version 2.0 (the "License");
         * you may not use this file except in compliance with the License.
         * You may obtain a copy of the License at
         *
         *    http://www.apache.org/licenses/LICENSE-2.0
         *
         * Unless required by applicable law or agreed to in writing, software
         * distributed under the License is distributed on an "AS IS" BASIS,
         * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
         * See the License for the specific language governing permissions and
         * limitations under the License.
  
********** Original Facebook License *************************************/
 


#import "MobliRequest.h"

@protocol MobliSessionDelegate;

/**
 * Main Mobli interface for interacting with the Mobli developer API.
 * Provides methods to log in and log out a user, and to make requests using the REST API.
 */

@interface Mobli : NSObject <MobliRequestDelegate> 

// It is your responsibility to store these properties in persistence store when the user logs in, and re-load them when instantiating Mobli.
@property(nonatomic, copy) NSString                     *accessToken;
@property(nonatomic, copy) NSDate                       *expirationDate;
@property(nonatomic, copy) NSString                     *refreshToken;
@property(nonatomic, copy) NSString                     *userID;
@property(nonatomic, retain) NSArray                    *permissions;
@property(nonatomic, assign) id<MobliSessionDelegate> sessionDelegate;


/**
 * Initialize the Mobli object
 *
 * @param aClientId: The mobli client id
 * @param aClientSecret: The mobli client secret
 * @param delegate: The MobliSessionDelegate
 */
- (id)initWithClientId:(NSString *)aClientId
          clientSecret:(NSString *)aClientSecret
           andDelegate:(id<MobliSessionDelegate>)delegate;


/**
 * Login as a guest allows only to use limited GET api requests such as popular 
 *
 * No parameters, default scope='shared'
 */
- (void)loginAsGuest;


/**
 * Login with a mobli user: allows posting images, comments, etc..
 *
 * @param aPermissions: The desired scopes
 */
- (void)loginWithPermissions:(NSArray *)aPermissions;



/**
 * Logout. Note, this method only erases the data stored locally in Mobli and notifies the (new) session delegate of the change
 *
 * @param delegate: Setting a new session delegate
 */
- (void)logout:(id<MobliSessionDelegate>)delegate;


/**
 * This function processes the URL Safari used to open your application after authentication
 * You MUST call this function in your UIApplicationDelegate's handleOpenURL method 
 * (see
 * http://developer.apple.com/library/ios/#documentation/uikit/reference/UIApplicationDelegate_Protocol/Reference/Reference.html
 * for more info).
 *
 * This will ensure that the authorization process will proceed smoothly once the
 * Mobli application or Safari redirects back to your application.
 *
 * @param url the URL that was passed to the application delegate's handleOpenURL method.
 * @return YES if the URL starts with 'mobli[app_id]://authorize and hence was handled by SDK, NO otherwise.
 *
 * You will need to add the redirect uri scheme of your application to the URL types in the plist file.
 * See http://developer.apple.com/library/ios/#documentation/iphone/conceptual/iphoneosprogrammingguide/AdvancedAppTricks/AdvancedAppTricks.html (Under 'Registering Custom URL Schemes')
 */
- (BOOL)handleOpenURL:(NSURL *)url;


/**
 * @return boolean - whether this object has an non-expired session token
 */
- (BOOL)isSessionValid;


///////////////////////////////////////////////////////////////////////////////////////////////////////////
// API Requests
///////////////////////////////////////////////////////////////////////////////////////////////////////////

// Initiaite a GET request
- (MobliRequest *)get:(NSString *)resourcePath
               params:(NSMutableDictionary *)params 
             delegate:(id <MobliRequestDelegate>)delegate;
// Initiaite a POST request
- (MobliRequest *)post:(NSString *)resourcePath
                params:(NSMutableDictionary *)params
              delegate:(id <MobliRequestDelegate>)delegate;
// Initiaite a POST request to upload an image
- (MobliRequest *)postImage:(UIImage *)image
                     params:(NSMutableDictionary *)params
                   delegate:(id <MobliRequestDelegate>)delegate;
// Initiaite a DELETE request
- (MobliRequest *)delete:(NSString *)resourcePath
                delegate:(id <MobliRequestDelegate>)delegate;


@end

////////////////////////////////////////////////////////////////////////////////

/**
 * Your application should implement this delegate to receive session callbacks.
 */
@protocol MobliSessionDelegate <NSObject>

@optional

/**
 * Called when the user successfully logged in.
 */
- (void)mobliDidLogin;

/**
 * Called when the user dismissed the dialog without logging in.
 */
- (void)mobliDidNotLogin:(BOOL)cancelled;

/**
 * Called when the user logged out.
 */
- (void)mobliDidLogout;

@end
