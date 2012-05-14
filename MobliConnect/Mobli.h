/*
 * Copyright 2011 Mobli
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
 */

#import "MobliRequest.h"

@protocol MobliSessionDelegate;

/**
 * Main Mobli interface for interacting with the Mobli developer API.
 * Provides methods to log in and log out a user, and to make requests using the REST API.
 */

@interface Mobli : NSObject  {
    NSString                                    *_accessToken;
    NSString                                    *_refreshToken;
    NSDate                                      *_expirationDate;
    NSString                                    *userID;
    id<MobliSessionDelegate>                    _sessionDelegate;
    NSMutableSet                                *_requests;
    NSString                                    *_appId;
    NSString                                    *_appSecret;
    NSString                                    *_urlSchemeSuffix;
    NSArray                                     *_permissions;
    
}

@property(nonatomic, copy) NSString             *accessToken;
@property(nonatomic, copy) NSString             *refreshToken;
@property(nonatomic, copy) NSDate               *expirationDate;
@property(nonatomic, copy) NSString             *userID;
@property(nonatomic, assign) id<MobliSessionDelegate> sessionDelegate;
@property(nonatomic, copy) NSString             *urlSchemeSuffix;


// Initializing the mobli object
- (id)initWithAppId:(NSString *)appId
        andDelegate:(id<MobliSessionDelegate>)delegate;

- (id)initWithAppId:(NSString *)appId
    urlSchemeSuffix:(NSString *)urlSchemeSuffix
        andDelegate:(id<MobliSessionDelegate>)delegate;

- (void)login:(NSArray *)permissions;

- (void)loginWithPermissions:(NSArray *)permissions asGuest:(BOOL)guest withDelegate:(id<MobliRequestDelegate>)delegate;

- (BOOL)handleOpenURL:(NSURL *)url;

- (void)logout:(id<MobliSessionDelegate>)delegate;

- (BOOL)isSessionValid;



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

//
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

/**
*
*/
- (void)mobliSessionInvalidated;


@end
