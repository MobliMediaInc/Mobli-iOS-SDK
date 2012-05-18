//
//  ConnectorFeedViewController.m
//  Connector
//
//  Created by Ariel Krieger on 5/9/12.
//  Copyright (c) 2012 Mobli. All rights reserved.
//

#import "ConnectorFeedViewController.h"
#import "ConnectorAppDelegate.h"

#define kMobliCDNBaseURL                         @"http://stat.mobli.com/"

@interface ConnectorFeedViewController ()

@end

@implementation ConnectorFeedViewController

@synthesize tableView;
@synthesize thumbnailCell;
@synthesize dataSource;
@synthesize progressView;
@synthesize navBar;
@synthesize leftBarButton;
@synthesize rightBarButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dev_main_bg"]];
        dataSource = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44.0)];
    [navBar setBackgroundImage:[UIImage imageNamed:@"dev_topbar"] forBarMetrics:UIBarMetricsDefault];
    [self.view addSubview:navBar];
    tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, navBar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height- 52 - navBar.frame.size.height)];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:tableView];
    
    progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(10, 48, 300, 30)];
    [progressView setProgress:0];
    [self.view addSubview:progressView];
    [self.view bringSubviewToFront:progressView];
    
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    self.tableView      = nil;
    self.thumbnailCell  = nil;
    self.progressView   = nil;
    self.navBar         = nil;
    self.leftBarButton  = nil;
    self.rightBarButton = nil;
}

- (void)dealloc {
    self.tableView      = nil;
    self.thumbnailCell  = nil;
    self.dataSource     = nil;
    self.progressView   = nil;
    self.navBar         = nil;
    self.leftBarButton  = nil;
    self.rightBarButton = nil;
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark UITableViewDataSource methods

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)aIndexPath {
    NSInteger row = aIndexPath.row;
    GridTableViewCell *cell = (GridTableViewCell *)[aTableView dequeueReusableCellWithIdentifier:@"GridTableViewCell"];
    if (cell == nil) {
        cell = [[[GridTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"GridTableViewCell"] autorelease];
    }
    if ([dataSource count] > 0) {
        if ([dataSource count] - 1 >= row*3  ) {
            [cell setThumb1Image:[dataSource objectAtIndex:row*3]];
        }
        if ([dataSource count] - 1 >= row*3+1 ) {
            [cell setThumb2Image:[dataSource objectAtIndex:row*3+1]];
        }
        if ([dataSource count] - 1 >= row*3+2  ) {
            [cell setThumb3Image:[dataSource objectAtIndex:row*3+2]];
        }

    }
    cell.userInteractionEnabled = FALSE;

    return cell;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)aSection {
    NSInteger rows = ceil([dataSource count]/3);
    return rows;
}

#pragma mark UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)aIndexPath {
    return 105;
}

#pragma mark MobliConnect methods

- (void)get:(NSString *)resourcePath params:(NSMutableDictionary *)params delegate:(id<MobliRequestDelegate>)delegate {
    leftBarButton.userInteractionEnabled = FALSE;
    leftBarButton.alpha = 0.3;
    rightBarButton.userInteractionEnabled = FALSE;
    rightBarButton.alpha = 0.3;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = TRUE;
    [[ConnectorAppDelegate current].mobli get:resourcePath params:params delegate:delegate];
}

- (void)post:(NSString *)resourcePath params:(NSMutableDictionary *)params delegate:(id<MobliRequestDelegate>)delegate {
    leftBarButton.userInteractionEnabled = FALSE;
    leftBarButton.alpha = 0.3;
    rightBarButton.userInteractionEnabled = FALSE;
    rightBarButton.alpha = 0.3;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = TRUE;
    [[ConnectorAppDelegate current].mobli post:resourcePath params:params delegate:delegate];
}

- (void)postImage:(UIImage *)image params:(NSMutableDictionary *)params delegate:(id<MobliRequestDelegate>)delegate {
    leftBarButton.userInteractionEnabled = FALSE;
    leftBarButton.alpha = 0.3;
    rightBarButton.userInteractionEnabled = FALSE;
    rightBarButton.alpha = 0.3;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = TRUE;
    [[ConnectorAppDelegate current].mobli postImage:image params:params delegate:delegate];
}

- (void)delete:(NSString *)resourcePath delegate:(id<MobliRequestDelegate>)delegate {
    leftBarButton.userInteractionEnabled = FALSE;
    leftBarButton.alpha = 0.3;
    rightBarButton.userInteractionEnabled = FALSE;
    rightBarButton.alpha = 0.3;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = TRUE;
    [[ConnectorAppDelegate current].mobli delete:resourcePath delegate:delegate];
}


- (void)getThumbsFromPayload:(NSArray *)aPayload {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    if ([dataSource count] > 0) {
        [dataSource removeAllObjects];
    }
    int count = [aPayload count];
    for (int i = 0; i < count; ++i) {
        NSString *thumbId = nil;
        if ([[aPayload objectAtIndex:i] valueForKey:@"repost_from_id"] !=nil) {
            thumbId = [NSString stringWithString:[[aPayload objectAtIndex:i]valueForKey:@"repost_from_id"]];
        }
        else {
            thumbId = [NSString stringWithString:[[aPayload objectAtIndex:i]valueForKey:@"id"]];
        }
        NSString *thumbUrlString = [NSString stringWithFormat:@"%@thumbs/thumb_%@_200.jpg",kMobliCDNBaseURL,thumbId];
        NSURL *thumbUrl = [NSURL URLWithString:thumbUrlString];
        NSData *thumbData = [NSData dataWithContentsOfURL:thumbUrl];
        if (thumbData) {
            [dataSource addObject:[UIImage imageWithData:thumbData]];
        }
        float progress = (float)i/(count-1);
        NSNumber *floatNum = [NSNumber numberWithFloat:progress];
        [self performSelectorOnMainThread:@selector(updateProgress:) withObject:floatNum waitUntilDone:FALSE];
    }  
    [pool release];
    [self performSelectorOnMainThread:@selector(fadeInTable) withObject:nil waitUntilDone:FALSE];
}

- (void)fadeInTable {
    leftBarButton.userInteractionEnabled = TRUE;
    rightBarButton.userInteractionEnabled = TRUE;
    [UIView animateWithDuration:0.3 animations:^{
        progressView.alpha = 0.0;
        leftBarButton.alpha = 1.0;
        rightBarButton.alpha = 1.0;
    } completion:^(BOOL finished) {
        tableView.userInteractionEnabled = TRUE;
        [tableView reloadData];
    }];
}

- (void)updateProgress:(NSNumber *)aProgress{
    [progressView setProgress:[aProgress floatValue] animated:YES];

}

- (void)requestLoading:(MobliRequest *)aRequest {
    tableView.userInteractionEnabled = FALSE;
    rightBarButton.userInteractionEnabled = FALSE;
    leftBarButton.userInteractionEnabled = FALSE;

}

- (void)request:(MobliRequest *)aRequest didLoad:(id)aResult {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
    NSArray *payload = [aResult valueForKey:@"payload"];
    // run getThumbsFromPayload on background thread because we want to update the UI during
    [NSThread detachNewThreadSelector:@selector(getThumbsFromPayload:) toTarget:self withObject:payload];
}

- (void)request:(MobliRequest *)request didFailWithError:(NSError *)error {
    leftBarButton.userInteractionEnabled = TRUE;
    rightBarButton.userInteractionEnabled = TRUE;

    leftBarButton.alpha = 1.0;
    rightBarButton.alpha = 1.0;
    
    tableView.userInteractionEnabled = TRUE;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;

    // Make sure you handle this error properly
    NSString *alertTitle = [NSString stringWithFormat: @"Error code %i\n%@",[error code],request.url];
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
