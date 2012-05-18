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

// Get your client id: http://developers.mobli.com
// Don't forget to add a custom URL scheme in the info.plist: mobli<your_client_id>

#define kMobliClientId                             @"YOUR_CLIENT_ID"
#define kMobliClientSecret                         @"YOUR_CLIENT_SECRET"

@interface ConnectorAppDelegate ()

@property(nonatomic, retain) ConnectorLiveViewController        *liveViewController;
@property(nonatomic, retain) ConnectorPopularViewController     *popularViewController;
@property(nonatomic, retain) ConnectorMeViewController          *meViewController;
@property(nonatomic, retain) ConnectorAroundViewController      *aroundViewController;

@property(nonatomic, assign) BOOL                                   didLogout;
@end

@implementation ConnectorAppDelegate (MobliSessionDelegate)

- (void)mobliDidLogin {
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    [defaults setObject:self.mobli.accessToken forKey:@"MobliAccessTokenKey"];
    [defaults setObject:self.mobli.refreshToken forKey:@"MobliRefreshTokenKey"];
    [defaults setObject:self.mobli.expirationDate forKey:@"MobliExpirationDateKey"];
    [defaults setObject:self.mobli.userID forKey:@"MobliUserID"];
    [defaults synchronize];
    if ([self.mobli.permissions count] == 1 && [[self.mobli.permissions objectAtIndex:0] isEqualToString:@"shared"]) { //Check if 'guest' login
        if (self.didLogout) { // If current 'guest' login was result of user logging off of mobli then we do not refresh the public feeds
            self.didLogout = FALSE;
            return;
        }
        // If not then get the feeds
        [self.liveViewController getLiveFeed];
        [self.popularViewController getFeaturedMediaFeed];
        [self.aroundViewController getLocation];
    }
    else {
        [self.meViewController showLoggedIn];
        [self.meViewController getUserMedia];
    }
    
}

- (void)mobliDidLogout {
    [self.meViewController showLoggedOut];
    self.didLogout = TRUE;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"MobliAccessTokenKey"];
    [defaults removeObjectForKey:@"MobliRefreshTokenKey"];
    [defaults removeObjectForKey:@"MobliExpirationDateKey"];
    [defaults removeObjectForKey:@"MobliUserID"];
    [defaults synchronize];
    [self.mobli loginAsGuest];
    
}

- (void)mobliDidNotLogin:(BOOL)cancelled {
    
}


@end
@implementation ConnectorAppDelegate

@synthesize window = _window;
@synthesize tabBarController = _tabBarController;
@synthesize mobli;
@synthesize liveViewController, popularViewController, meViewController, aroundViewController;
@synthesize didLogout;

+ (ConnectorAppDelegate *)current {
    return (ConnectorAppDelegate *)[UIApplication sharedApplication].delegate;
}

- (void)dealloc {
    [_window release];
    [_tabBarController release];
    [mobli release];
    self.liveViewController     = nil;
    self.popularViewController  = nil;
    self.meViewController       = nil;
    self.aroundViewController   = nil;
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    

    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    liveViewController     = [[[ConnectorLiveViewController alloc] init] autorelease];
    popularViewController  = [[[ConnectorPopularViewController alloc] init] autorelease];
    meViewController       = [[[ConnectorMeViewController alloc] init] autorelease];
    aroundViewController   = [[[ConnectorAroundViewController alloc] init] autorelease];
    self.tabBarController = [[[UITabBarController alloc] init] autorelease];
    self.tabBarController.viewControllers = [NSArray arrayWithObjects:liveViewController, popularViewController, meViewController, aroundViewController, nil];
    self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];

    // Initialize Mobli
    // We assign meViewController to be the MobliSessionDelegate because it's the view controller responsible for logging in and out
    mobli = [[Mobli alloc] initWithClientId:kMobliClientId clientSecret:kMobliClientSecret andDelegate:self];

    
    // Start the request to get a public token
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"MobliAccessTokenKey"] == nil) {
        [self getPublicToken];
    }
    else {
        mobli.accessToken = [defaults objectForKey:@"MobliAccessTokenKey"];
        mobli.expirationDate = [defaults objectForKey:@"MobliExpirationDateKey"];
        mobli.permissions = [defaults objectForKey:@"MobliUserPermissions"];
        mobli.userID = [defaults objectForKey:@"MobliUserID"];
        [liveViewController getLiveFeed];
        [popularViewController getFeaturedMediaFeed];
        [aroundViewController getLocation];
        if ([self.mobli.permissions count] == 1 && [[self.mobli.permissions objectAtIndex:0] isEqualToString:@"shared"]){
            // Do nothing
        }
        else {
            [meViewController getUserMedia];
        }
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
    didLogout = FALSE;
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [self.mobli handleOpenURL:url];
}


- (void)getPublicToken {
    [self.mobli loginAsGuest];
}


@end


