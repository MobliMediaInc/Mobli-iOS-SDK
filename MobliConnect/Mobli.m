

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



#import "Mobli.h"
#import <ImageIO/ImageIO.h>


#define kMobliResponseTypeToken                 @"token"
#define kMobliResponseTypeCode                  @"code"
#define kMobliWebAuthURLScheme                  @"mobli"
#define kMobliAppAuthEndpoint                   @"authorize"
#define kMobliAppSharedEndpoint                 @"shared"
#define kMobliPublicCredentials                 @"client_credentials"


///////////////////////////////////////////////////////////////////////////////////////////////////

@interface Mobli ()

// private properties

@property(nonatomic, copy) NSString             *clientId;
@property(nonatomic, copy) NSString             *clientSecret;
@property(nonatomic, retain) NSMutableSet       *requests;

@end

// private methods

@interface Mobli (Private)

/**
 * Starts a dialog which prompts the user to log in to Mobli and grant
 * the requested permissions to the application.
 *
 * Also note that requests may be made to the API without calling
 * authorize() first, in which case only public information is returned.
 *
 */
- (void)authorizeWithMobliAppAuth;

/**
 * Make a request to Mobli's REST API with the given resource path and parameters.
 *
 * @param resourcePath: A valid REST server API endpoint
 * @param params: Key-value pairs of parameters to the request
 * @param httpMethod: http method @"GET" or @"POST" 
 * @param delegate: Callback interface for notifying the calling application when the request has received response
 * @return MobliRequest: Returns a pointer to the MobliRequest object.
 */
- (MobliRequest*)requestWithResourcePath:(NSString *)resourcePath
                               andParams:(NSMutableDictionary *)params
                           andHttpMethod:(NSString *)httpMethod
                             andDelegate:(id <MobliRequestDelegate>)delegate;


/**
 * A private helper method for sending HTTP requests.
 *
 * @param url: url to send http request
 * @param params: parameters to append to the url
 * @param httpMethod: http method @"GET" or @"POST"
 * @param delegate: Callback interface for notifying the calling application when the request has received response
 * @param aRequestName: A convenience paramter, naming the request
 */

- (MobliRequest*)openUrl:(NSString *)url
                  params:(NSMutableDictionary *)params
              httpMethod:(NSString *)httpMethod
                delegate:(id<MobliRequestDelegate>)delegate 
                 andName:(NSString *)aRequestName;


/**
 * Set the access token, refresh token,expiration date, and user ID after successful login
 */
- (void)mobliDialogLogin:(NSString*)aAccesstoken refreshToken:(NSString *)aRefreshToken userID:(NSString *)aUserID expirationDate:(NSDate*)anExpirationDate;


/**
 * Did not login call the not login delegate
 */
- (void)mobliDialogNotLogin:(BOOL)cancelled;


/**
 * Check the payload after oauth request ends
 */
- (void)checkOAuthResponseParams:(NSDictionary *)params;


/**
 * Helper method that corrects any orientation issues with images
 */
- (UIImage *)prepareImageForUpload:(UIImage *)anImage;


/**
 * A private method for getting the app's base url.
 */
- (NSString *)getOwnBaseUrl;


/**
 * A private method for parsing URL parameters.
 */
- (NSDictionary*)parseURLParams:(NSString *)query;

@end

@implementation Mobli (Private)

- (void)authorizeWithMobliAppAuth {
    
    // Set up the parameters for the request:
    // Response_type can be "code" (explicit) instead of "token" (implicit). In this example we're using the implicit flow
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   self.clientId, @"client_id",
                                   kMobliResponseTypeToken, @"response_type",
                                   nil];
    
    // Set the URL for the dialog
    NSString *loginDialogURL = [kMobliDialogBaseURL stringByAppendingString:kMobliAppAuthEndpoint];
    
    // Rearrange permissions into correct format (e.g. scope='shared basic advanced')
    if (self.permissions != nil) {
        NSString* scope = [self.permissions componentsJoinedByString:@" "];
        [params setValue:scope forKey:@"scope"];
    }
    
    // If you do not specify a redirect_uri here, you will be redirected to the URI you set when registering your app
    NSString *nextUrl = [self getOwnBaseUrl];
    [params setValue:nextUrl forKey:@"redirect_uri"];
    
    // Serialize the dialog URL along with the parameters and open it using Safari
    NSString *mobliAppUrl = [MobliRequest serializeURL:loginDialogURL params:params];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:mobliAppUrl]];
}

- (MobliRequest *)requestWithResourcePath:(NSString *)resourcePath 
                                andParams:(NSMutableDictionary *)params 
                            andHttpMethod:(NSString *)httpMethod 
                              andDelegate:(id<MobliRequestDelegate>)delegate {
    NSString *fullURL = [kMobliRestserverBaseURL stringByAppendingFormat:resourcePath];
    
    return [self openUrl:fullURL
                  params:params 
              httpMethod:httpMethod
                delegate:delegate
                 andName:resourcePath]; //by default, we name the request the same as the endpoint (resourcePath)
}

- (MobliRequest*)openUrl:(NSString *)url
                  params:(NSMutableDictionary *)params
              httpMethod:(NSString *)httpMethod
                delegate:(id<MobliRequestDelegate>)delegate 
                 andName:(NSString *)aRequestName {
    
    // If no parameters were set in the initial request, params will be nil
    if (!params) {
        params = [NSMutableDictionary dictionary];
    }
    
    // We add the access token to the request's url query
    if ([self isSessionValid]) {
        [params setValue:self.accessToken forKey:@"access_token"];
    }
    
    // For DELETE requests we add the http method name in the request params and change the request's http method to POST
    if ([httpMethod isEqualToString:@"DELETE"]) {
        [params setObject:@"DELETE" forKey:@"http_method"];
        httpMethod = @"POST";
    }
    
    // Initialize the request and get going
    MobliRequest *request = [[MobliRequest getRequestWithParams:params
                                                     httpMethod:httpMethod
                                                       delegate:delegate
                                                     requestURL:url
                                                           name:aRequestName] retain];
    [self.requests addObject:request];
    [request connect];
    return request;
}

- (void)mobliDialogLogin:(NSString *)aAccesstoken 
            refreshToken:(NSString *)aRefreshToken 
                  userID:(NSString *)aUserID 
          expirationDate:(NSDate *)anExpirationDate {
    
    // Set the relevant data
    self.accessToken = aAccesstoken;
    self.refreshToken = aRefreshToken;
    self.expirationDate = anExpirationDate;
    self.userID = aUserID;
    
    // Inform the session delegate login was successful
    if ([self.sessionDelegate respondsToSelector:@selector(mobliDidLogin)]) {
        [self.sessionDelegate mobliDidLogin];
    }
}

- (void)mobliDialogNotLogin:(BOOL)cancelled {
    // Inform the session delegate login was unsuccessful, cancelled == TRUE means the login was canceled by the user
    if ([self.sessionDelegate respondsToSelector:@selector(mobliDidNotLogin:)]) {
        [self.sessionDelegate mobliDidNotLogin:cancelled];
    }
}

- (void)checkOAuthResponseParams:(NSDictionary *)params {
    NSString *anAccessToken = [params valueForKey:@"access_token"];
    NSString *aRefreshToken = [params valueForKey:@"refresh_token"];
    NSString *expTime = [params valueForKey:@"expires_in"];
    NSString *user_ID = [params valueForKey:@"user_id"];
    
    // If the URL doesn't contain the access token, an error has occurred.
    if (!anAccessToken) {
        NSString *errorReason = [params valueForKey:@"error"];
        
        BOOL userCanceled = [errorReason isEqualToString:@"authorization_request_canceled"];
        [self mobliDialogNotLogin:userCanceled];
        
        //        NSString *errorDescription = [params valueForKey:@"error_description"];
        //        NSString *errorUri = [params valueForKey:@"error_uri"];
        
        
        return;
    }
    
    // We have an access token, so parse the expiration date.
    NSDate *anExpirationDate = [NSDate distantFuture];
    if (expTime != nil) {
        int expVal = [expTime intValue];
        if (expVal != 0) {
            anExpirationDate = [NSDate dateWithTimeIntervalSinceNow:expVal];
        }
    }
    
    
    [self mobliDialogLogin:anAccessToken refreshToken:aRefreshToken userID:user_ID expirationDate:anExpirationDate];
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

- (NSString *)getOwnBaseUrl {
    return [NSString stringWithFormat:@"%@%@://%@",kMobliWebAuthURLScheme, 
            self.clientId,kMobliAppAuthEndpoint];
}

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

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation Mobli

@synthesize accessToken;
@synthesize refreshToken;
@synthesize expirationDate;
@synthesize userID;
@synthesize sessionDelegate;
@synthesize permissions;
@synthesize clientId;
@synthesize clientSecret;
@synthesize requests;

- (void)dealloc {
    self.accessToken = nil;
    self.refreshToken = nil;
    self.expirationDate = nil;
    self.userID = nil;
    self.sessionDelegate = nil;
    self.permissions = nil;
    self.clientId = nil;
    self.clientSecret = nil;
    self.requests = nil;
    [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
//public
///////////////////////////////////////////////////////////////////////////////////////////////////

- (id)initWithClientId:(NSString *)aClientId
          clientSecret:(NSString *)aClientSecret
           andDelegate:(id<MobliSessionDelegate>)delegate {
    self = [super init];
    if (self) {
        self.requests = [[[NSMutableSet alloc] init] autorelease];
        self.clientId = aClientId;
        self.clientSecret = aClientSecret;
        self.sessionDelegate = delegate;
    }
    return self;
}

- (void)loginAsGuest {
    [self loginWithPermissions:[NSArray arrayWithObject:@"shared"] asGuest:YES];
}

- (void)loginWithPermissions:(NSArray *)aPermissions {
    [self loginWithPermissions:aPermissions asGuest:NO];
}

- (void)loginWithPermissions:(NSArray *)aPermissions asGuest:(BOOL)asGuest {
    self.permissions = aPermissions;
    // If asGuest == TRUE, we initiate a public token request
    if (asGuest) {
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       kMobliPublicCredentials  ,@"grant_type",
                                       self.clientId            ,@"client_id",
                                       self.clientSecret        ,@"client_secret",
                                       nil];
        
        if (permissions) {
            NSString* scope = [permissions componentsJoinedByString:@" "];
            [params setValue:scope forKey:@"scope"];
        }
        
        NSString *requestURL = [NSString stringWithFormat:@"%@%@",kMobliDialogBaseURL,kMobliAppSharedEndpoint];
        
        // Initializing the MobliRequest with the parameters (params), 
        //                                        http method ("POST"), 
        //                                        MobliRequestDelegate (self), 
        //                                        URL (requestURL), 
        //                                        and name ("getPublicToken") 
        MobliRequest *request = [MobliRequest getRequestWithParams:params 
                                                        httpMethod:@"POST" 
                                                          delegate:self 
                                                        requestURL:requestURL 
                                                              name:@"getPublicToken"];
        
        [request connect];
    }
    else {
        
        // If asGuest == FALSE, we go to private authorization
        [self authorizeWithMobliAppAuth];
    }
}

- (void)logout:(id<MobliSessionDelegate>)delegate {
    
    self.sessionDelegate = delegate;
    self.accessToken = nil;
    self.refreshToken = nil;
    self.expirationDate = nil;
    self.userID = nil;
    
    if ([self.sessionDelegate respondsToSelector:@selector(mobliDidLogout)]) {
        [sessionDelegate mobliDidLogout];
    }
}

- (BOOL)handleOpenURL:(NSURL *)url {
    
    NSLog(@"handleOpenURL %@",url);
    // If the URL's structure doesn't match the structure used for Mobli authorization, abort.
    if (![[url absoluteString] hasPrefix: [self getOwnBaseUrl]]) {
        return NO;
    }
    NSString *query = [url query];
    NSDictionary *params = [self parseURLParams:query];
    
    NSLog(@"handleOpenURL %@",params);
    [self checkOAuthResponseParams:params];
    return YES;
}

- (BOOL)isSessionValid {
    return (self.accessToken      != nil &&
            self.expirationDate   != nil && 
            NSOrderedDescending   == [self.expirationDate compare:[NSDate date]]);
}


///////////////////////////////////////////////////////////////////////////////////////////////////////////
// API Requests
///////////////////////////////////////////////////////////////////////////////////////////////////////////

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
    
    if (!params) {
        params = [NSMutableDictionary dictionary];
    }
    else {
        params = [NSMutableDictionary dictionaryWithDictionary:params];
    }
    
    [params setValue:imgForUpload   forKey:@"file"];
    [params setValue:@"photo"       forKey:@"type"];
    
    return [self requestWithResourcePath:@"media" 
                               andParams:params 
                           andHttpMethod:@"POST" 
                             andDelegate:delegate];
}

- (MobliRequest *)delete:(NSString *)resourcePath 
                delegate:(id<MobliRequestDelegate>)delegate {
    return [self requestWithResourcePath:resourcePath andParams:nil andHttpMethod:@"DELETE" andDelegate:delegate];
}


///////////////////////////////////////////////////////////////////////////////////////////////////////////
// MobliRequestDelegate
// These delegate methods are only called for requests to get a public access token

- (void)request:(MobliRequest *)request didFailWithError:(NSError *)error {
    if ([request.requestName isEqualToString:@"getPublicToken"]) {
        if ([sessionDelegate respondsToSelector:@selector(mobliDidNotLogin:)]) {
            [sessionDelegate mobliDidNotLogin:NO];
        }
    }
}

- (void)request:(MobliRequest *)request didLoad:(id)result {
    if ([request.requestName isEqualToString:@"getPublicToken"]) {
        if ([sessionDelegate respondsToSelector:@selector(mobliDidLogin)]) {
            [self checkOAuthResponseParams:result];
        }
    }
}


@end
