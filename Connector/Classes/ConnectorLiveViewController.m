//
//  ConnectorLiveViewController.m
//  Connector
//
//  Created by Ariel Krieger on 5/9/12.
//  Copyright (c) 2012 Mobli. All rights reserved.
//

#import "ConnectorLiveViewController.h"

@interface ConnectorLiveViewController ()

@end

@interface ConnectorLiveViewController (Private)

- (void)getLiveFeed;

@end

@implementation ConnectorLiveViewController (Private)

- (void)getLiveFeed {
    NSMutableDictionary *liveMediaParams = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                            @"1",@"page",
                                            @"21",@"max_per_page",
                                            @"21",@"max_results",
                                            @"1",@"noch",
                                            @"1",@"nopl",
                                            @"1",@"nocy",
                                            @"1",@"noct",
                                            nil];
    
    [self get:@"live" params:liveMediaParams delegate:self];
}

@end

@implementation ConnectorLiveViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Live";
        self.tabBarItem.image = [UIImage imageNamed:@"dev_tab_live_off"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.leftBarButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 7, 54, 29)];
    self.leftBarButton.layer.masksToBounds = TRUE;
    self.leftBarButton.layer.cornerRadius = 6.0;
    [self.leftBarButton setBackgroundImage:[UIImage imageNamed:@"dev_refresh_btn_up"] forState:UIControlStateNormal];
    [self.leftBarButton setBackgroundImage:[UIImage imageNamed:@"dev_refresh_btn_down"] forState:UIControlStateHighlighted];
    self.leftBarButton.titleLabel.textColor = [UIColor colorWithRed:76.0/255.0 green:76.0/255.0 blue:76.0/255.0 alpha:1.0];
    [self.leftBarButton setTitle:@"Refresh" forState:UIControlStateNormal];
    [self.leftBarButton addTarget:self action:@selector(getLiveFeed) forControlEvents:UIControlEventTouchUpInside];
    UIFont *refreshFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0];
    self.leftBarButton.titleLabel.font = refreshFont;
    self.leftBarButton.titleLabel.textAlignment = UITextAlignmentCenter;
    [self.navBar addSubview:self.leftBarButton];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getLiveFeed) name:@"ACCESS_TOKEN_EXISTS" object:nil];

}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}


- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)aSection {
    return 7;
}


@end
