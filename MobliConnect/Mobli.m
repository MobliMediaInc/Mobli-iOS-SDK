/*
 * Copyright 2011 Mobli
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0

 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "Mobli.h"
#import "MobliRequest.h"
#import <ImageIO/ImageIO.h>


static NSString *requestFinishedKeyPath = @"state";
static void *finishedContext = @"finishedContext";
///////////////////////////////////////////////////////////////////////////////////////////////////

@interface Mobli ()

// private properties
@property(nonatomic, retain) NSArray* permissions;
@property(nonatomic, copy) NSString* appId;

@end

// private methods
@interface Mobli (Private)

- (MobliRequest*)requestWithResourcePath:(NSString *)resourcePath
                               andParams:(NSMutableDictionary *)params
                           andHttpMethod:(NSString *)httpMethod
                             andDelegate:(id <MobliRequestDelegate>)delegate;

- (MobliRequest*)openUrl:(NSString *)url
                  params:(NSMutableDictionary *)params
              httpMethod:(NSString *)httpMethod
                delegate:(id<MobliRequestDelegate>)delegate 
                 andName:(NSString *)aRequestName;

- (void)mobliDialogLogin:(NSString*)aAccesstoken refreshToken:(NSString *)aRefreshToken userID:(NSString *)aUserID expirationDate:(NSDate*)anExpirationDate;

- (void)mobliDialogNotLogin:(BOOL)cancelled;

- (UIImage *)prepareImageForUpload:(UIImage *)anImage;


@end

@implementation Mobli (Private)

/**
 * Make a request to Mobli's REST API with the given resource path and
 * parameters.
 *
 * See 
 *
 *
 * @param methodName
 *             a valid REST server API method.
 * @param parameters
 *            Key-value pairs of parameters to the request. Refer to the
 *            documentation: one of the parameters must be "method". 
 * @param delegate
 *            Callback interface for notifying the calling application when
 *            the request has received response
 * @param aRequestName
 *            A convenience paramter, naming the request
 *
 * @return MobliRequest *
 *            Returns a pointer to the FBRequest object.
 */

- (MobliRequest *)requestWithResourcePath:(NSString *)resourcePath 
                                andParams:(NSMutableDictionary *)params 
                            andHttpMethod:(NSString *)httpMethod 
                              andDelegate:(id<MobliRequestDelegate>)delegate {
    NSString *fullURL = [kMobliRestserverBaseURL stringByAppendingFormat:resourcePath];

    return [self openUrl:fullURL
                  params:params 
              httpMethod:httpMethod
                delegate:delegate
                 andName:resourcePath];
}

/**
 * Set the access token, refresh token,expiration date, and user ID after login succeed
 */

- (void)mobliDialogLogin:(NSString *)aAccesstoken refreshToken:(NSString *)aRefreshToken userID:(NSString *)aUserID expirationDate:(NSDate *)anExpirationDate {
    self.accessToken = aAccesstoken;
    self.refreshToken = aRefreshToken;
    self.expirationDate = anExpirationDate;
    self.userID = aUserID;
    if ([self.sessionDelegate respondsToSelector:@selector(mobliDidLogin)]) {
        [_sessionDelegate mobliDidLogin];
    }
}

/**
 * Did not login call the not login delegate
 */
- (void)mobliDialogNotLogin:(BOOL)cancelled {
    if ([self.sessionDelegate respondsToSelector:@selector(mobliDidNotLogin:)]) {
        [_sessionDelegate mobliDidNotLogin:cancelled];
    }
}

- (UIImage *)prepareImageForUpload:(UIImage *)anImage {
    // No-op if the orientation is already correct
    if (anImage.imageOrientation == UIImageOrientationUp) return anImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (anImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, anImage.size.width, anImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, anImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, anImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (anImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, anImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, anImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, anImage.size.width, anImage.size.height,
                                             CGImageGetBitsPerComponent(anImage.CGImage), 0,
                                             CGImageGetColorSpace(anImage.CGImage),
                                             CGImageGetBitmapInfo(anImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (anImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,anImage.size.height,anImage.size.width), anImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,anImage.size.width,anImage.size.height), anImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;    
}

/**
 * A private helper function for sending HTTP requests.
 *
 * @param url
 *            url to send http request
 * @param params
 *            parameters to append to the url
 * @param httpMethod
 *            http method @"GET" or @"POST"
 * @param delegate
 *            Callback interface for notifying the calling application when
 *            the request has received response
 * @param aRequestName
 *            A convenience paramter, naming the request
 */

- (MobliRequest*)openUrl:(NSString *)url
                  params:(NSMutableDictionary *)params
              httpMethod:(NSString *)httpMethod
                delegate:(id<MobliRequestDelegate>)delegate 
                 andName:(NSString *)aRequestName {
    
    // We add the access token to the request's url query only for GET requests
    if ([self isSessionValid] && [httpMethod isEqualToString:@"GET"]) {
        [params setValue:self.accessToken forKey:@"access_token"];
    }
    
    MobliRequest *_request = [[MobliRequest getRequestWithParams:params
                                                      httpMethod:httpMethod
                                                        delegate:delegate
                                                      requestURL:url
                                                            name:aRequestName] retain];
    [_requests addObject:_request];
    [_request addObserver:self forKeyPath:requestFinishedKeyPath options:0 context:finishedContext];
    [_request connect];
    return _request;
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation Mobli

@synthesize accessToken =                       _accessToken,
           refreshToken =                       _refreshToken,
         expirationDate =                       _expirationDate,
                 userID =                       _userID,
        sessionDelegate =                       _sessionDelegate,
            permissions =                       _permissions,
        urlSchemeSuffix =                       _urlSchemeSuffix,
                  appId =                       _appId;


///////////////////////////////////////////////////////////////////////////////////////////////////


- (id)initWithAppId:(NSString *)appId
        andDelegate:(id<MobliSessionDelegate>)delegate {
  self = [self initWithAppId:appId urlSchemeSuffix:nil andDelegate:delegate];
  return self;
}

/**
 * Initialize the Mobli object with application ID.
 *
 * @param appId the mobli app id
 * @param urlSchemeSuffix
 *   urlSchemeSuffix is a string of lowercase letters that is
 *   appended to the base URL scheme used for SSO. For example,
 *   if your Mobli ID is "350685531728" and you set urlSchemeSuffix to
 *   "abcd", the Mobli app will expect your application to bind to
 *   the following URL scheme: "mobli350685531728abcd".
 *   This is useful if your have multiple iOS applications that
 *   share a single Mobli application id (for example, if you
 *   have a free and a paid version on the same app) and you want
 *   to use SSO with both apps. Giving both apps different
 *   urlSchemeSuffix values will allow the Mobli app to disambiguate
 *   their URL schemes and always redirect the user back to the
 *   correct app, even if both the free and the app is installed
 *   on the device.
 *   urlSchemeSuffix is currently not supported on the Mobli
 *   app. If the user has an older version of the Mobli app
 *   installed and your app uses urlSchemeSuffix parameter, the SDK will
 *   proceed as if the Mobli app isn't installed on the device
 *   and redirect the user to Safari.
 *
 * @param delegate the MobliSessionDelegate
 */
- (id)initWithAppId:(NSString *)appId
    urlSchemeSuffix:(NSString *)urlSchemeSuffix
        andDelegate:(id<MobliSessionDelegate>)delegate {
  
  self = [super init];
  if (self) {
    _requests = [[NSMutableSet alloc] init];
    self.appId = appId;
    self.sessionDelegate = delegate;
    self.urlSchemeSuffix = urlSchemeSuffix;
  }
  return self;
}

/**
 * Override NSObject : free the space
 */
- (void)dealloc {
    for (MobliRequest *_request in _requests) {
        [_request removeObserver:self forKeyPath:requestFinishedKeyPath];
    }
    [_accessToken release];
    [_expirationDate release];
    [_userID release];
    [_requests release];
    [_appId release];
    [_permissions release];
    [_urlSchemeSuffix release];
    [super dealloc];
}

- (void)invalidateSession {
    self.accessToken = nil;
    self.refreshToken = nil;
    self.expirationDate = nil;
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == finishedContext) {
        MobliRequest *_request = (MobliRequest *)object;
        MobliRequestState requestState = [_request state];
        if (requestState == kMobliRequestStateComplete) {
            if ([_request sessionDidExpire]) {
                [self invalidateSession];
                if ([self.sessionDelegate respondsToSelector:@selector(mobliSessionInvalidated)]) {
                    [self.sessionDelegate mobliSessionInvalidated];
                }
            }
            [_request removeObserver:self forKeyPath:requestFinishedKeyPath];
            [_requests removeObject:_request];
        }
    }
}

/**
 * A private function for getting the app's base url.
 */
- (NSString *)getOwnBaseUrl {
  return [NSString stringWithFormat:@"%@%@://%@",kMobliWebAuthURLScheme, 
          _appId,kMobliAppAuthURLPath];
}

/**
 * A private function for opening the authorization dialog.
 */
- (void)authorizeWithMobliAppAuth:(BOOL)tryMobliAppAuth
                    safariAuth:(BOOL)trySafariAuth {
    
// response_type can be "code" (explicit) instead of "token" (implicit)
  NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                         _appId, @"client_id",
                                        kMobliResponseTypeToken, @"response_type",
                                                                 nil];

  NSString *loginDialogURL = [kMobliDialogBaseURL stringByAppendingString:kMobliAppAuthURLPath];

  if (_permissions != nil) {
    NSString* scope = [_permissions componentsJoinedByString:@" "];
    [params setValue:scope forKey:@"scope"];
  }

  if (_urlSchemeSuffix) {
    [params setValue:_urlSchemeSuffix forKey:@"local_client_id"];
  }
  
  // If the device is running a version of iOS that supports multitasking,
  // try to obtain the access token from the Facebook app installed
  // on the device.
  // If the Mobli app isn't installed or it doesn't support
  // the moblioauth:// URL scheme, fall back on Safari for obtaining the access token.
  // This minimizes the chance that the user will have to enter his or
  // her credentials in order to authorize the application.
    
  BOOL didOpenOtherApp = NO;
  UIDevice *device = [UIDevice currentDevice];
  if ([device respondsToSelector:@selector(isMultitaskingSupported)] && [device isMultitaskingSupported]) {
    if (tryMobliAppAuth) {
      NSString *scheme = kMobliAppAuthURLScheme;
      if (_urlSchemeSuffix) {
        scheme = [scheme stringByAppendingString:@"2"];
      }
        NSString *urlPrefix = [NSString stringWithFormat:@"%@://%@", scheme, kMobliAppAuthURLPath];
        NSString *mobliAppUrl = [MobliRequest serializeURL:urlPrefix params:params];
        didOpenOtherApp = [[UIApplication sharedApplication] openURL:[NSURL URLWithString:mobliAppUrl]];
    }

    if (trySafariAuth && !didOpenOtherApp) {
        NSString *nextUrl = [self getOwnBaseUrl];
        [params setValue:nextUrl forKey:@"redirect_uri"];
        NSString *mobliAppUrl = [MobliRequest serializeURL:loginDialogURL params:params];
        didOpenOtherApp = [[UIApplication sharedApplication] openURL:[NSURL URLWithString:mobliAppUrl]];
        }
    }
}

/**
 * A function for parsing URL parameters.
 */
- (NSDictionary*)parseURLParams:(NSString *)query {
	NSArray *pairs = [query componentsSeparatedByString:@"&"];
	NSMutableDictionary *params = [[[NSMutableDictionary alloc] init] autorelease];
	for (NSString *pair in pairs) {
		NSArray *kv = [pair componentsSeparatedByString:@"="];
		NSString *val =
    [[kv objectAtIndex:1]
     stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

		[params setObject:val forKey:[kv objectAtIndex:0]];
	}
  return params;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
//public

/**
 * Starts a dialog which prompts the user to log in to Mobli and grant
 * the requested permissions to the application.
 *
 * If the device supports multitasking, we use fast app switching to show
 * the dialog in the Mobli app or, if the Mobli app isn't installed,
 * in Safari (this enables single sign-on by allowing multiple apps on
 * the device to share the same user session).
 * When the user grants or denies the permissions, the app that
 * showed the dialog (the Mobli app or Safari) redirects back to
 * the calling application, passing in the URL the access token
 * and/or any other parameters the Mobli backend includes in
 * the result (such as an error code if an error occurs).
 *
 * See (link unavailable) for more details.
 *
 * Also note that requests may be made to the API without calling
 * authorize() first, in which case only public information is returned.
 *
 * @param permissions
 *            A list of permission required for this application: e.g.
 *            "shared", "login", or "advanced". see (link unavailable) 
 *            This parameter should not be null -- if you do not require any
 *            permissions, then pass in an empty String array.
 * @param delegate
 *            Callback interface for notifying the calling application when
 *            the user has logged in.
 */
- (void)login:(NSArray *)permissions {
  self.permissions = permissions;

// You can choose not to use app auth or safari auth by setting the below arguments accordingly
  [self authorizeWithMobliAppAuth:YES safariAuth:YES];
}

- (void)loginWithPermissions:(NSArray *)permissions asGuest:(BOOL)guest withDelegate:(id<MobliRequestDelegate>)delegate {
    self.permissions = permissions;
    if (guest) {
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:kMobliPublicCredentials,@"grant_type",
                                                                                                    kMobliAppId,@"client_id",
                                                                                                kMobliAppSecret,@"client_secret",
                                                                                                                nil];
        
        // Setting request URL
        NSString *requestURL = [NSString stringWithFormat:@"%@%@",kMobliDialogBaseURL,kMobliAppSharedEndpoint];
                
        // Initializing the MobliRequest with the parameters (params), URL (requestURL), "POST" http method and MobliRequestDelegate
        MobliRequest *request = [MobliRequest getRequestWithParams:params 
                                                        httpMethod:@"POST" 
                                                          delegate:delegate 
                                                        requestURL:requestURL 
                                                              name:@"getPublicToken"];
        
        [request connect];
        
        
    }
    else {
        [self authorizeWithMobliAppAuth:YES safariAuth:YES];
    }
}

/**
 * This function processes the URL the Mobli application or Safari used to
 * open your application during a single sign-on flow.
 *
 * You MUST call this function in your UIApplicationDelegate's handleOpenURL
 * method (see
 * http://developer.apple.com/library/ios/#documentation/uikit/reference/UIApplicationDelegate_Protocol/Reference/Reference.html
 * for more info).
 *
 * This will ensure that the authorization process will proceed smoothly once the
 * Mobli application or Safari redirects back to your application.
 *
 * @param URL the URL that was passed to the application delegate's handleOpenURL method.
 *
 * @return YES if the URL starts with 'mobli[app_id]://authorize and hence was handled
 *   by SDK, NO otherwise.
 *
 * You will need to add the redirect uri scheme of your application to the URL types in the plist file.
 * See http://developer.apple.com/library/ios/#documentation/iphone/conceptual/iphoneosprogrammingguide/AdvancedAppTricks/AdvancedAppTricks.html (Under 'Registering Custom URL Schemes')
 */


- (BOOL)handleOpenURL:(NSURL *)url {
    // If the URL's structure doesn't match the structure used for Mobli authorization, abort.
    if (![[url absoluteString] hasPrefix: [self getOwnBaseUrl]]) {
    return NO;
    }

    NSString *query = [url query];
    NSDictionary *params = [self parseURLParams:query];
    NSString *accessToken = [params valueForKey:@"access_token"];
    NSString *refreshToken = [params valueForKey:@"refresh_token"];
    NSString *expTime = [params valueForKey:@"expires_in"];
    NSString *user_ID = [params valueForKey:@"user_id"];
    
    // If the URL doesn't contain the access token, an error has occurred.
    if (!accessToken) {
        NSString *errorReason = [params valueForKey:@"error"];
        
        // If the error response indicates that we should try again using Safari, open
        // the authorization dialog in Safari.
        if (errorReason && [errorReason isEqualToString:@"service_disabled_use_browser"]) {
            [self authorizeWithMobliAppAuth:NO safariAuth:YES];
            return YES;
        }
        // The mobli app may return an error_code parameter in case it
        // encounters a UIWebViewDelegate error. This should not be treated
        // as a cancel.
        NSString *errorCode = [params valueForKey:@"error_code"];
        
        BOOL userDidCancel = !errorCode && (!errorReason || [errorReason isEqualToString:@"access_denied"]);
        [self mobliDialogNotLogin:userDidCancel];
        return YES;
    }
    
    // We have an access token, so parse the expiration date.
    NSDate *expirationDate = [NSDate distantFuture];
    if (expTime != nil) {
        int expVal = [expTime intValue];
        if (expVal != 0) {
            expirationDate = [NSDate dateWithTimeIntervalSinceNow:expVal];
        }
    }
    
    [self mobliDialogLogin:accessToken refreshToken:refreshToken userID:user_ID expirationDate:expirationDate];
    return YES;
}

/**
 * Invalidate the current user session by removing the access token in
 * memory and clearing the browser cookie.
 *
 * Note that this method dosen't unauthorize the application --
 * it just removes the access token. To unauthorize the application,
 * the user must remove the app in the app settings page under the privacy
 * settings screen on facebook.com.
 *
 * @param delegate
 *            Callback interface for notifying the calling application when
 *            the application has logged out
 */
- (void)logout:(id<MobliSessionDelegate>)delegate {

    self.sessionDelegate = delegate;
    [_accessToken release];
    _accessToken = nil;
    [_refreshToken release];
    _refreshToken = nil;
    [_expirationDate release];
    _expirationDate = nil;
    [_userID release];
    _userID = nil;

    if ([self.sessionDelegate respondsToSelector:@selector(mobliDidLogout)]) {
    [_sessionDelegate mobliDidLogout];
    }
}


/**
 * @return boolean - whether this object has an non-expired session token
 */
- (BOOL)isSessionValid {
  return (self.accessToken      != nil &&
          self.expirationDate   != nil && 
          NSOrderedDescending   == [self.expirationDate compare:[NSDate date]]);

}

- (MobliRequest *)get:(NSString *)resourcePath 
               params:(NSMutableDictionary *)params 
             delegate:(id<MobliRequestDelegate>)delegate {
    return [self requestWithResourcePath:resourcePath andParams:params andHttpMethod:@"GET" andDelegate:delegate];
}

- (MobliRequest *)post:(NSString *)resourcePath 
                params:(NSMutableDictionary *)params 
              delegate:(id<MobliRequestDelegate>)delegate {
    return [self requestWithResourcePath:resourcePath andParams:params andHttpMethod:@"POST" andDelegate:delegate];
}

- (MobliRequest *)postImage:(UIImage *)image 
                     params:(NSMutableDictionary *)params 
                   delegate:(id<MobliRequestDelegate>)delegate {

    // Fix image orientation if needed
    UIImage *imgForUpload   = [self prepareImageForUpload:image];
    NSString *imgWidth      = [NSString stringWithFormat:@"%.0f",imgForUpload.size.width];
    NSString *imgHeight     = [NSString stringWithFormat:@"%.0f",imgForUpload.size.height];
    
    [params setValue:imgForUpload   forKey:@"file"];
    [params setValue:@"photo"       forKey:@"type"];
    [params setValue:imgWidth       forKey:@"width"];
    [params setValue:imgHeight      forKey:@"height"];
    
    return [self requestWithResourcePath:@"media" 
                               andParams:params 
                           andHttpMethod:@"POST" 
                             andDelegate:delegate];
    
}

- (MobliRequest *)delete:(NSString *)resourcePath 
                delegate:(id<MobliRequestDelegate>)delegate {
    return [self requestWithResourcePath:resourcePath andParams:nil andHttpMethod:@"DELETE" andDelegate:delegate];
    
}


///////////////////////////////////////////////////////////////////////////////////////////////////

// MobliRequestDelegate

/**
 * Handle the auth.ExpireSession api call failure
 */
- (void)request:(MobliRequest*)request didFailWithError:(NSError*)error{
    NSString *alertTitle = [NSString stringWithFormat: @"Error code %i",[error code]];
    NSString *alertMessage = [NSString stringWithFormat:@"%@",[error userInfo]];
    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:alertTitle
                                                         message:alertMessage 
                                                        delegate:nil 
                                               cancelButtonTitle:@"OK" 
                                               otherButtonTitles:nil];
    [errorAlert show];
    [errorAlert release];
}

@end
