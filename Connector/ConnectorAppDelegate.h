//
//  ConnectorAppDelegate.h
//  Connector
//
//  Created by Ariel Krieger on 5/9/12.
//  Copyright (c) 2012 Mobli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MobliConnect.h"

@interface ConnectorAppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate, MobliRequestDelegate, MobliSessionDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UITabBarController *tabBarController;
@property (nonatomic, retain) Mobli             *mobli;

+ (ConnectorAppDelegate *)current;
- (void)getPublicToken;

@end
