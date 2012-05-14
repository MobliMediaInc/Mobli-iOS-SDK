//
//  ConnectorNotificationsViewController.m
//  Connector
//
//  Created by Ariel Krieger on 5/14/12.
//  Copyright (c) 2012 Mobli. All rights reserved.
//

#import "ConnectorNotificationsViewController.h"
#import "ConnectorNotificationCell.h"
#import "MobliConnect.h"
#import "ConnectorAppDelegate.h"

@interface ConnectorNotificationsViewController ()

@property(nonatomic, retain) UITableView        *notificationsTableView;
@property(nonatomic, retain) UINavigationBar    *navBar;
@property(nonatomic, retain) UIButton           *dismissButton;
@property(nonatomic, retain) NSMutableArray     *dataSource;
@end

@interface ConnectorNotificationsViewController (MobliRequestDelegate) <MobliRequestDelegate>

@end

@interface ConnectorNotificationsViewController (TableView) <UITableViewDelegate, UITableViewDataSource>

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)aIndexPath;

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)aSection;

- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)aIndexPath;

@end


@implementation ConnectorNotificationsViewController (MobliRequestDelegate)


- (void)request:(MobliRequest *)aRequest didLoad:(id)aResult {
    self.dataSource = [aResult valueForKey:@"payload"];
    [self.notificationsTableView reloadData];
}

- (void)request:(MobliRequest *)aRequest didFailWithError:(NSError *)aError {
    // Make sure you handle this error properly
    NSString *alertTitle = [NSString stringWithFormat: @"Error code %i",[aError code]];
    NSString *alertMessage = [NSString stringWithFormat:@"%@",[aError userInfo]];
    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:alertTitle
                                                         message:alertMessage 
                                                        delegate:nil 
                                               cancelButtonTitle:@"OK" 
                                               otherButtonTitles:nil];
    [errorAlert show];
    [errorAlert release];
}
@end

@implementation ConnectorNotificationsViewController (TableView)

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)aIndexPath {
    NSInteger row = aIndexPath.row;
    ConnectorNotificationCell *cell = (ConnectorNotificationCell *)[aTableView dequeueReusableCellWithIdentifier:@"ConnectorNotificationCell"];
    if (cell == nil) {
        cell = [[[ConnectorNotificationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ConnectorNotificationCell"] autorelease];
    }
    cell.subject = [self.dataSource objectAtIndex:row];
    cell.userInteractionEnabled = FALSE;
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)aSection {
   return [self.dataSource count];
}

- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)aIndexPath {
    return 100;
}
@end
@implementation ConnectorNotificationsViewController


@synthesize notificationsTableView;
@synthesize navBar;
@synthesize dismissButton;
@synthesize dataSource;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    CGRect bounds = self.view.frame;

    navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44.0)];
    [navBar setBackgroundImage:[UIImage imageNamed:@"dev_topbar"] forBarMetrics:UIBarMetricsDefault];
    [self.view addSubview:navBar];

    
    notificationsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,self.navBar.frame.size.height ,bounds.size.width, bounds.size.height - self.navBar.frame.size.height) style:UITableViewStylePlain];
    notificationsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    notificationsTableView.backgroundColor = [UIColor clearColor];
    notificationsTableView.delegate = self;
    notificationsTableView.dataSource = self;
    [self.view addSubview:notificationsTableView];
    dismissButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 120, 44)];
    dismissButton.backgroundColor = [UIColor clearColor];
    dismissButton.center = self.navBar.center;
    [dismissButton addTarget:self action:@selector(dismissModalViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
    [self.navBar addSubview:dismissButton];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    ConnectorAppDelegate *delegate = [ConnectorAppDelegate current];
    
    [delegate.mobli get:@"me/notifications" params:[NSMutableDictionary dictionary] delegate:self];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    self.navBar         = nil;
    self.dismissButton  = nil;
    self.dataSource     = nil;
    [super dealloc];
}

@end
