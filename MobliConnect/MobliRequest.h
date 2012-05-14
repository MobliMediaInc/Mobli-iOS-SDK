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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol MobliRequestDelegate;

enum {
    kMobliRequestStateReady,
    kMobliRequestStateLoading,
    kMobliRequestStateComplete,
    kMobliRequestStateError
};
typedef NSUInteger MobliRequestState;

/**
 * Do not use this interface directly, instead, use method in Facebook.h
 */
@interface MobliRequest : NSObject {
    id<MobliRequestDelegate>                    _delegate;
    NSString                                    *_url;
    NSString                                    *_httpMethod;
    NSMutableDictionary                         *_params;
    NSURLConnection                             *_connection;
    NSMutableData                               *_responseText;
    MobliRequestState                           _state;
    NSError                                     *_error;
    BOOL                                        _sessionDidExpire;

}


@property(nonatomic,assign) id<MobliRequestDelegate> delegate;

/**
 * The URL which will be contacted to execute the request.
 */
@property(nonatomic,copy) NSString              *url;

/**
 * The API method which will be called.
 */
@property(nonatomic,copy) NSString              *httpMethod;

/**
 * The request name (convenience).
 */
@property(nonatomic,copy) NSString              *requestName;

/**
 * The dictionary of parameters to pass to the method.
 *
 * These values in the dictionary will be converted to strings using the
 * standard Objective-C object-to-string conversion facilities.
 */
@property(nonatomic,retain)     NSMutableDictionary *params;
@property(nonatomic,assign)     NSURLConnection     *connection;
@property(nonatomic,assign)     NSMutableData       *responseText;
@property(nonatomic,readonly)   MobliRequestState   state;
@property(nonatomic,readonly)   BOOL                sessionDidExpire;

/**
 * Error returned by the server in case of request's failure (or nil otherwise).
 */
@property(nonatomic,retain) NSError* error;

+ (NSString*)serializeURL:(NSString *)baseUrl
                   params:(NSDictionary *)params;

+ (NSString*)serializeURL:(NSString *)baseUrl
                   params:(NSDictionary *)params
               httpMethod:(NSString *)httpMethod;

+ (MobliRequest*)getRequestWithParams:(NSMutableDictionary *) params
                           httpMethod:(NSString *) httpMethod
                             delegate:(id<MobliRequestDelegate>)delegate
                           requestURL:(NSString *) url 
                                 name:(NSString *)aRequestName;
- (BOOL) loading;

- (void) connect;

@end

////////////////////////////////////////////////////////////////////////////////

/*
 *Your application should implement this delegate
 */
@protocol MobliRequestDelegate <NSObject>

@optional

/**
 * Called just before the request is sent to the server.
 */
- (void)requestLoading:(MobliRequest *)request;

/**
 * Called when the server responds and begins to send back data.
 */
- (void)request:(MobliRequest *)request didReceiveResponse:(NSURLResponse *)response;

/**
 * Called when an error prevents the request from completing successfully.
 */
- (void)request:(MobliRequest *)request didFailWithError:(NSError *)error;

/**
 * Called when a request returns and its response has been parsed into
 * an object.
 *
 * The resulting object may be a dictionary, an array, a string, or a number,
 * depending on thee format of the API response.
 */
- (void)request:(MobliRequest *)request didLoad:(id)result;

/**
 * Called when a request returns a response.
 *
 * The result object is the raw response from the server of type NSData
 */
- (void)request:(MobliRequest *)request didLoadRawResponse:(NSData *)data;

@end

