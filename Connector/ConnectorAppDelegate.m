//
//  ConnectorAppDelegate.m
//  Connector
//
//  Created by Ariel Krieger on 5/9/12.
//  Copyright (c) 2012 Mobli. All rights reserved.
//

#import "ConnectorAppDelegate.h"

#import "ConnectorLiveViewController.h"
#import "ConnectorPopularViewController.h"
#import "ConnectorMeViewController.h"
#import "ConnectorAroundViewController.h"

@implementation ConnectorAppDelegate

@synthesize window = _window;
@synthesize tabBarController = _tabBarController;
@synthesize mobli;

+ (ConnectorAppDelegate *)current {
    return (ConnectorAppDelegate *)[UIApplication sharedApplication].delegate;
}

- (void)dealloc {
    [_window release];
    [_tabBarController release];
    [mobli release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    

    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    ConnectorLiveViewController     *liveViewController     = [[[ConnectorLiveViewController alloc] init] autorelease];
    ConnectorPopularViewController  *popularViewController  = [[[ConnectorPopularViewController alloc] init] autorelease];
    ConnectorMeViewController       *meViewController       = [[[ConnectorMeViewController alloc] init] autorelease];
    ConnectorAroundViewController   *aroundViewController   = [[[ConnectorAroundViewController alloc] init] autorelease];
    self.tabBarController = [[[UITabBarController alloc] init] autorelease];
    self.tabBarController.viewControllers = [NSArray arrayWithObjects:liveViewController, popularViewController, meViewController, aroundViewController, nil];
    self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];

    // Initialize Mobli
    // We assign meViewController to be the MobliSessionDelegate because it's the view controller responsible for logging in and out
    mobli = [[Mobli alloc] initWithAppId:kMobliAppId andDelegate:meViewController];

    
    // Start the request to get a public token
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"MobliAccessTokenKey"] == nil) {
        [self getPublicToken];
    }
    else {
        mobli.accessToken = [defaults objectForKey:@"MobliAccessTokenKey"];
        mobli.expirationDate = [defaults objectForKey:@"MobliExpirationDateKey"];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ACCESS_TOKEN_EXISTS" object:nil];
    }
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [self.mobli handleOpenURL:url];
}

#pragma mark MobliRequestDelegate methods

#pragma mark MobliRequestDelegate

- (void)request:(MobliRequest *)aRequest didReceiveResponse:(NSURLResponse *)aResponse {
}

- (void)requestLoading:(MobliRequest *)aRequest {
}

- (void)request:(MobliRequest *)aRequest didLoad:(id)aResult {
    
    // Normally you would store the public access_token in a secure storage and then replace it with the private token after authorizing the user.
    // (See MeViewController)
    if ([aRequest.requestName isEqualToString:@"getPublicToken"]) {
                
        mobli.accessToken = [aResult valueForKey:@"access_token"]; 
        mobli.expirationDate = [NSDate dateWithTimeIntervalSinceNow:[[aResult valueForKey:@"expires_in"] intValue]];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:mobli.accessToken forKey:@"MobliAccessTokenKey"];
        [defaults setObject:mobli.expirationDate forKey:@"MobliExpirationDateKey"];
        [defaults synchronize];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ACCESS_TOKEN_EXISTS" object:nil];
        
    }
}

- (void)request:(MobliRequest *)aRequest didLoadRawResponse:(NSData *)aData {
    //  
}

- (void)request:(MobliRequest *)request didFailWithError:(NSError *)error {
    // Make sure you handle this error properly
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

- (void)getPublicToken {
    [self.mobli loginWithPermissions:nil asGuest:YES withDelegate:self];
}
@end


