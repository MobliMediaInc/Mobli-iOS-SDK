

Mobli iOS SDK v.1.0
05/2012 Mobli Media inc.


What is the Mobli iOS SDK?

The developer’s iOS SDK provides support for accessing and utilizing Mobli’s API. This access includes authentication via the OAuth 2.0 protocol and various REST requests.
The SDK is open source and is available on GitHub.

SDK Contents

MobliConnect.h
Header file used to reference the SDK’s interface files and constants.

MobliConstants.h
Header file used to store SDK related constants (URLs, Client ID, Client secret, etc.)

Mobli.h
Main Mobli interface for interacting with the Mobli developer API. Provides methods to log in and log out a user, and to make requests using the REST API. Implementation in Mobli.m.

MobliRequest.h
Interface for initialization and handling of all API requests. Implementation in MobliRequest.m.

JSON (Folder)
Contains framework for parsing and generating JSON.  Copyright (C) 2009 Stig Brautaset. All rights reserved.
Learn more on the http://code.google.com/p/json-framework project site.

Installation

1. Drag the SDK folder titled 'MobliConnect' into your project folder.
2. Add custom URL scheme to allow single sign-on from mobile safari:
    a) Open your app Info.plist file
    b) If 'URL Types' is not already there, right click and "Add Row" of 'URL Types', then select 'Item 0' and 'Add Row' of 'URL Schemes', edit the value of 'Item 0' to: 'mobli<client_id>'. (your client id from Mobli API site)

Usage

#import MobliConnect.h to whatever class will be implementing the SDK methods and/or protocols

Perform all the actions (authentication, API requests) through the Mobli.h interface.

--------------------------------------------------------------------------
Begin with initializing the Mobli object with your client ID, client secret, and session delegate:

- (id)initWithClientId:(NSString *)clientId
          clientSecret:(NSString *)clientSecret
           andDelegate:(id<MobliSessionDelegate>)delegate;


--------------------------------------------------------------------------
In order to request a public access token ('mobli_shared') use either:

- (void)loginAsGuest; 
Which will request a public access token with scope 'shared'

--------------------------------------------------------------------------
In order to request a private access token ('mobli_user_related') use either:

- (void)loginWithPermissions:(NSArray *)permissions;

--------------------------------------------------------------------------
The session delegate will receive the response to the above login requests using the protocol methods:

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
 * Called when the session was invalidated.
 */
- (void)mobliSessionInvalidated;

--------------------------------------------------------------------------
In order to logout from Moboi use the following method:

- (void)logout:(id<MobliSessionDelegate>)delegate;

Note, this method only erases the data stored locally in Mobli and notifies the (new) session delegate of the change

--------------------------------------------------------------------------
In order to make REST requests to Mobli's API use the following methods:

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


For more info regarding API requests and endpoints please refer to http://developers.mobli.com/documentation

--------------------------------------------------------------------------

Sample app

The SDK comes with a sample app titled Connector.app.
It is a basic tab bar application showing by example the following:

- Getting a public token
- Getting a private token
- Making various API GET requests ('live', 'popular', 'nearby', and 'me' feeds)
- Uploading an image to authenticated user's channel (POST)

