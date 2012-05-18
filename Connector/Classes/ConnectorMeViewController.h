//
//  ConnectorMeViewController.h
//  Connector
//
//  Created by Ariel Krieger on 5/9/12.
//  Copyright (c) 2012 Mobli. All rights reserved.
//

#import "ConnectorFeedViewController.h"

@interface ConnectorMeViewController : ConnectorFeedViewController <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

// Method for initiating an API request for the user's last 24 medias
- (void)getUserMedia; 
- (void)showLoggedIn;
- (void)showLoggedOut;
@end
