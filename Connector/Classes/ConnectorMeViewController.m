//
//  ConnectorMeViewController.m
//  Connector
//
//  Created by Ariel Krieger on 5/9/12.
//  Copyright (c) 2012 Mobli. All rights reserved.
//

#import "ConnectorMeViewController.h"
#import "ConnectorAppDelegate.h"
#import "ConnectorNotificationsViewController.h"


@interface ConnectorMeViewController ()

@property(nonatomic, retain) UIButton                           *mobliConnectButton;
@property(nonatomic, retain) UIButton                           *notificationsButton;
@property(nonatomic, retain) UITextField                        *textField;
@property(nonatomic, retain) NSMutableDictionary                *uploadedMediaInfo;

@end

@interface ConnectorMeViewController (UITextFieldDelegate) <UITextFieldDelegate>
@end

@interface ConnectorMeViewController (Private)

// Private methods

// Method for initiating the login process
- (void)loginWithMobli;

// Method for initiating the logout process (Invalidate the access token)
- (void)logout;

// Method for initiating image selection/creation and uploading vie mobli app
- (void)uploadToMobli;

// Initializing and api request to upload an image to mobli
- (void)actionAPISelected;

// Initializing the image library picker
- (void)actionLibrarySelected;

// Initializing the camera
- (void)actionCameraSelected;

// Adding the text field as an input accessory view to the keyboard
- (void)keyboardWillShow:(NSNotification *)notification;
- (void)keyboardWillHide:(NSNotification *)notification;

// Show user notifications view controller
- (void)toggleNotifications;

@end

@implementation ConnectorMeViewController (UITextFieldDelegate) 

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self actionAPISelected];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.uploadedMediaInfo setValue:textField.text forKey:@"text"];
    [textField resignFirstResponder];
    return TRUE;
}

@end

@implementation ConnectorMeViewController (Private)

- (void)loginWithMobli {
    ConnectorAppDelegate *delegate = [ConnectorAppDelegate current];
    // permissions represent the selected scopes the user is requesting (see Mobli.m)
    NSArray *permissions =  [NSArray arrayWithObjects:@"shared",@"basic",@"advanced", nil];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:permissions forKey:@"MobliUserPermissions"];
    [defaults synchronize];
    
    [delegate.mobli loginWithPermissions:permissions]; 
}

- (void)logout {
    [self.dataSource removeAllObjects];
    [self.tableView reloadData];
    [self.tableView scrollsToTop];
    ConnectorAppDelegate *delegate = [ConnectorAppDelegate current];
    [delegate.mobli logout:delegate];
}

- (void)uploadToMobli {
    
    UIActionSheet *mediaUploadSourceActionSheet = [[UIActionSheet alloc]
                                         initWithTitle:@"Please select upload source"
                                         delegate:self
                                         cancelButtonTitle:NSLocalizedString(@"Cancel",@"")
                                         destructiveButtonTitle:nil
                                         otherButtonTitles:
                                         NSLocalizedString(@"Library", @""),
                                         NSLocalizedString(@"Camera", @""),
                                         nil];
    
    [mediaUploadSourceActionSheet showInView:self.view.window];
}

- (void)actionAPISelected {
    NSString *mediaCaption = [self.uploadedMediaInfo valueForKey:@"text"];
    UIImage *img = [self.uploadedMediaInfo valueForKey:UIImagePickerControllerOriginalImage];
    
    NSMutableDictionary *uploadMediaParams = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                              @"jpg",                       @"extension",
                                              mediaCaption,                 @"text",
                                              nil];
    
    // Additional parameters relevant to image upload are also added in the postImage request method
    [self postImage:img params:uploadMediaParams delegate:self];
    [self.uploadedMediaInfo removeAllObjects];
}

- (void)actionLibrarySelected {
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary | UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
        return;
    }
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary & UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    picker.delegate = self;
    [self presentModalViewController:picker animated:YES];
    [picker release];
}

- (void)actionCameraSelected {
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        return;
    }
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.showsCameraControls = YES;
    picker.delegate = self;
    [self presentModalViewController:picker animated:YES];
    [picker release];
}

- (void)keyboardWillShow:(NSNotification *)notification {    
    ConnectorAppDelegate *delegate = [ConnectorAppDelegate current];
    
    NSTimeInterval animationDuration;
    CGRect keyboardRect, textFieldFrame;
	[[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardRect];
	[[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
	textFieldFrame = self.textField.frame;
	textFieldFrame.origin.x = 0;
	textFieldFrame.origin.y = self.view.frame.size.height - textFieldFrame.size.height +  delegate.tabBarController.tabBar.frame.size.height;
	self.textField.frame = textFieldFrame;
	self.textField.alpha = 0.0;
	textFieldFrame.origin.y = textFieldFrame.origin.y - keyboardRect.size.height;
    
    [UIView
     animateWithDuration:animationDuration
     animations:^{
         self.textField.frame = textFieldFrame;
         self.textField.alpha = 1.0;
     }];
    
}

- (void)keyboardWillHide:(NSNotification *)notification {
    // Resize the table to accomodate for the keyboard
    NSTimeInterval animationDuration;
    
	CGRect keyboardRect, textFieldFrame;
	[[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] getValue:&keyboardRect];
	[[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
	textFieldFrame = self.textField.frame;
	textFieldFrame.origin.y = self.view.frame.size.height + textFieldFrame.size.height;
	[UIView
	 transitionWithView:self.view
	 duration:animationDuration
	 options:0
	 animations:^{
         
		 self.textField.alpha = 0.0;
		 self.textField.frame = textFieldFrame;
	 }
	 completion:^(BOOL f){
		 [self.textField removeFromSuperview];
	 }];
}

- (void)toggleNotifications {
    ConnectorNotificationsViewController *notificationsVC = [[ConnectorNotificationsViewController alloc] init];
    notificationsVC.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentModalViewController:notificationsVC animated:YES];
    [notificationsVC release];
}

#pragma mark - MobliRequestDelegate Methods

- (void)request:(MobliRequest *)aRequest didLoad:(id)aResult {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
    NSArray *payload = [aResult valueForKey:@"payload"];
    
    if ([aRequest.requestName isEqualToString:@"me/media"]) { // This is the get 'Me' feed request
        [NSThread detachNewThreadSelector:@selector(getThumbsFromPayload:) toTarget:self withObject:payload];
    }
    else if ([aRequest.requestName isEqualToString:@"media"]) { // This is the upload image request
        BOOL success = [[aResult valueForKey:@"success"] boolValue];
        self.tableView.userInteractionEnabled = TRUE;
        if (success) { // Refresh the user's 'Me' feed
            [self getUserMedia];
        }
        UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Yeepy!" 
                                                         message:@"Photo uploaded"
                                                        delegate:nil
                                               cancelButtonTitle:@"Cool" 
                                               otherButtonTitles:nil] autorelease];
        [alert show];
    }
}

- (void)request:(MobliRequest *)request didFailWithError:(NSError *)error {
    
    [super request:request didFailWithError:error];
    // Show logged out state if:
    // 1. the app is no longer authorized
    // 2. the user logged out of Mobli from mobli.com or the Mobli app
    // 3. the user has changed their password
    if ([error code] == 401) {
        [self showLoggedOut];
    }
}

@end

@implementation ConnectorMeViewController

@synthesize mobliConnectButton;
@synthesize notificationsButton;
@synthesize textField;
@synthesize uploadedMediaInfo;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Me";
        self.tabBarItem.image = [UIImage imageNamed:@"dev_tab_eye_off"];
        uploadedMediaInfo = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    self.leftBarButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 7, 54, 29)];
    self.leftBarButton.layer.masksToBounds = TRUE;
    self.leftBarButton.layer.cornerRadius = 6.0;
    [self.leftBarButton setBackgroundImage:[UIImage imageNamed:@"dev_refresh_btn_up"] forState:UIControlStateNormal];
    [self.leftBarButton setBackgroundImage:[UIImage imageNamed:@"dev_refresh_btn_down"] forState:UIControlStateHighlighted];
    self.leftBarButton.titleLabel.textColor = [UIColor colorWithRed:76.0/255.0 green:76.0/255.0 blue:76.0/255.0 alpha:1.0];
    [self.leftBarButton setTitle:@"Log Out" forState:UIControlStateNormal];
    [self.leftBarButton addTarget:self action:@selector(logout) forControlEvents:UIControlEventTouchUpInside];

    UIFont *logoutFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0];
    self.leftBarButton.titleLabel.font = logoutFont;
    self.leftBarButton.titleLabel.textAlignment = UITextAlignmentCenter;
    [self.navBar addSubview:self.leftBarButton];
    
    self.rightBarButton = [[UIButton alloc] initWithFrame:CGRectMake(280, 8, 29, 25)];
    [self.rightBarButton setBackgroundImage:[UIImage imageNamed:@"shoot_white"] forState:UIControlStateNormal];
    [self.rightBarButton addTarget:self action:@selector(uploadToMobli) forControlEvents:UIControlEventTouchUpInside];
    [self.navBar addSubview:self.rightBarButton];
    
    mobliConnectButton = [[UIButton alloc] initWithFrame:CGRectMake(67, 150, 185, 45)];
    [mobliConnectButton addTarget:self action:@selector(loginWithMobli) forControlEvents:UIControlEventTouchUpInside];
    [mobliConnectButton setBackgroundImage:[UIImage imageNamed:@"dev_connect_up"] forState:UIControlStateNormal];
    [mobliConnectButton setBackgroundImage:[UIImage imageNamed:@"dev_connect_down"] forState:UIControlStateHighlighted];
    mobliConnectButton.layer.masksToBounds = FALSE;
    mobliConnectButton.layer.cornerRadius = 8.0;
    mobliConnectButton.layer.shadowOpacity = 1.0;
    mobliConnectButton.layer.shadowRadius = 10.0;
    mobliConnectButton.layer.shadowOffset = CGSizeMake(10.0, 10.0);
    mobliConnectButton.layer.shadowColor = [UIColor blackColor].CGColor;
    [mobliConnectButton setTitle:@"Connect With Mobli" forState:UIControlStateNormal];
    [self.view addSubview:mobliConnectButton];
    
    notificationsButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 120, 44)];
    notificationsButton.backgroundColor = [UIColor clearColor];
    notificationsButton.center = self.navBar.center;
    [notificationsButton addTarget:self action:@selector(toggleNotifications) forControlEvents:UIControlEventTouchUpInside];
    [self.navBar addSubview:notificationsButton];
    
    CGRect selfFrame = self.view.frame;
    textField = [[UITextField alloc] initWithFrame:CGRectMake(0, selfFrame.size.height, selfFrame.size.width, 33)];
    textField.font = [UIFont fontWithName:@"HelveticaNeue" size:18.0];
    textField.textAlignment = UITextAlignmentLeft;
    textField.textColor = [UIColor blackColor];
    textField.placeholder = @"Media Caption (optional)...";
    textField.delegate = self;
    textField.backgroundColor = [UIColor whiteColor];
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.returnKeyType = UIReturnKeySend;
    [self.view addSubview:textField];
    self.tableView.alpha = 0.0;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    ConnectorAppDelegate *delegate = [ConnectorAppDelegate current];
    // Check and retrieve authorization information. Saving to NSUserDefaults is NOT secure and should not be used in your app.
    // Some form of encrypted keychain is recommended.
    

    if (![delegate.mobli isSessionValid] || ([delegate.mobli.permissions count] == 1 && [[delegate.mobli.permissions objectAtIndex:0] isEqualToString:@"shared"])) {
        [self showLoggedOut];
    } 
    else {
        [self showLoggedIn];
    }
}

- (void)viewDidUnload {
    [super viewDidUnload];
    self.mobliConnectButton     = nil;
    self.textField              = nil;

    // Release any retained subviews of the main view.
}

- (void)dealloc {
    self.mobliConnectButton     = nil;
    self.textField              = nil;
    self.uploadedMediaInfo      = nil;
    [super dealloc];
}

- (void)getUserMedia {
    NSMutableDictionary *userMediaParams = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                            @"1",@"page",
                                            @"24",@"max_per_page",
                                            @"120",@"max_results",
                                            @"1",@"noch",
                                            @"1",@"nopl",
                                            @"1",@"nocy",
                                            @"1",@"noct",
                                            @"1",@"noow",
                                            nil];
    [self get:@"me/media" params:userMediaParams delegate:self];
    self.leftBarButton.alpha = 0.3;
    self.leftBarButton.userInteractionEnabled = FALSE;
}

- (void)showLoggedIn {
    self.progressView.progress = 0.0;
    [UIView animateWithDuration:0.4 animations:^{
        self.tableView.alpha = 1.0;
        self.mobliConnectButton.alpha = 0.0;
        self.leftBarButton.alpha = 1.0;
        if ([self.dataSource count] == 0) {
            self.progressView.alpha = 1.0;
        }
        self.rightBarButton.alpha = 1.0;

    }completion:^(BOOL finished) {
        self.rightBarButton.userInteractionEnabled = TRUE;
    }];
}

- (void)showLoggedOut {
    [UIView animateWithDuration:0.4 animations:^{
        self.tableView.alpha = 0.0;
        self.mobliConnectButton.alpha = 1.0;
        self.leftBarButton.alpha = 0.3;
        self.progressView.alpha = 0.0;
        self.rightBarButton.alpha = 0.3;
    }completion:^(BOOL finished) {
        self.rightBarButton.userInteractionEnabled = FALSE;
    }];
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)aSection {
    return 8;
}

#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {

        switch (buttonIndex) {
            case 0:
                [self actionLibrarySelected];
                break;
            case 1:
                [self actionCameraSelected];
                break;
            default:
                break;
        }
}

#pragma mark UIImagePickerController

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];        
    UIImage *img = [info valueForKey:UIImagePickerControllerOriginalImage];
    [uploadedMediaInfo setValue:img forKey:UIImagePickerControllerOriginalImage];
    [uploadedMediaInfo setValue:type forKey:UIImagePickerControllerMediaType];
    [self.view addSubview:textField];
    [textField becomeFirstResponder];
    [picker dismissModalViewControllerAnimated:YES];  
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissModalViewControllerAnimated:YES];
}

@end
