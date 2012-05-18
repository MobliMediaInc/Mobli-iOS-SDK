//
//  ConnectorAroundViewController.m
//  Connector
//
//  Created by Ariel Krieger on 5/9/12.
//  Copyright (c) 2012 Mobli. All rights reserved.
//

#import "ConnectorAroundViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface ConnectorAroundViewController ()

@property(nonatomic, retain) CLLocationManager *locationManager;
@end

@interface ConnectorAroundViewController (Private) <CLLocationManagerDelegate>


- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation;
- (void)getNearbyFeed:(CLLocation *)aLocation;

@end


@implementation ConnectorAroundViewController (Private)


- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    [self.locationManager stopUpdatingLocation];
    [self getNearbyFeed:newLocation];
}

- (void)getNearbyFeed:(CLLocation *)aLocation {

    NSString *geo_lat = [NSString stringWithFormat:@"%f", aLocation.coordinate.latitude];
    NSString *geo_long = [NSString stringWithFormat:@"%f", aLocation.coordinate.longitude];
    
    NSMutableDictionary *nearbyMediaParams = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                              @"1",       @"page",
                                              @"21",      @"max_per_page",
                                              @"21",      @"max_results",
                                              @"1",       @"noch",
                                              @"1",       @"nopl",
                                              @"1",       @"nocy",
                                              @"1",       @"noct",
                                              geo_lat,    @"geo_lat",
                                              geo_long,   @"geo_long",
                                              nil];
    [self get:@"nearby" params:nearbyMediaParams delegate:self];
}


@end
@implementation ConnectorAroundViewController
@synthesize locationManager;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Around";
        self.tabBarItem.image = [UIImage imageNamed:@"dev_tab_around_off"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.leftBarButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 7, 54, 29)];
    self.leftBarButton.layer.masksToBounds = TRUE;
    self.leftBarButton.layer.cornerRadius = 6.0;
    [self.leftBarButton setBackgroundImage:[UIImage imageNamed:@"dev_refresh_btn_up"] forState:UIControlStateNormal];
    [self.leftBarButton setBackgroundImage:[UIImage imageNamed:@"dev_refresh_btn_down"] forState:UIControlStateHighlighted];
    self.leftBarButton.titleLabel.textColor = [UIColor colorWithRed:76.0/255.0 green:76.0/255.0 blue:76.0/255.0 alpha:1.0];
    [self.leftBarButton setTitle:@"Refresh" forState:UIControlStateNormal];
    [self.leftBarButton addTarget:self action:@selector(getLocation) forControlEvents:UIControlEventTouchUpInside];
    UIFont *refreshFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0];
    self.leftBarButton.titleLabel.font = refreshFont;
    self.leftBarButton.titleLabel.textAlignment = UITextAlignmentCenter;
    [self.navBar addSubview:self.leftBarButton];
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = kCLLocationAccuracyHundredMeters;

}

- (void)dealloc {
    self.locationManager        = nil;
    [super dealloc];
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)aSection {
    return 7;
}

- (void)getLocation {
    [self.locationManager startUpdatingLocation];
}
@end
