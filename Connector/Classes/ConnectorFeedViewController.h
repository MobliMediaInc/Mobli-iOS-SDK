//
//  ConnectorFeedViewController.h
//  Connector
//
//  Created by Ariel Krieger on 5/9/12.
//  Copyright (c) 2012 Mobli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GridTableViewCell.h"
#import <QuartzCore/QuartzCore.h>
#import "MobliConnect.h"

@interface ConnectorFeedViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, MobliRequestDelegate>

@property(nonatomic, retain) UITableView        *tableView;
@property(nonatomic, retain) GridTableViewCell  *thumbnailCell;
@property(nonatomic, retain) NSMutableArray     *dataSource;
@property(nonatomic, retain) UIProgressView     *progressView;
@property(nonatomic, retain) UINavigationBar    *navBar;
@property(nonatomic, retain) UIButton           *leftBarButton;
@property(nonatomic, retain) UIButton           *rightBarButton;


- (void)get:(NSString *)resourcePath params:(NSMutableDictionary *)params delegate:(id<MobliRequestDelegate>)delegate;
- (void)post:(NSString *)resourcePath params:(NSMutableDictionary *)params delegate:(id<MobliRequestDelegate>)delegate;
- (void)postImage:(UIImage *)image params:(NSMutableDictionary *)params delegate:(id<MobliRequestDelegate>)delegate;
- (void)delete:(NSString *)resourcePath delegate:(id<MobliRequestDelegate>)delegate;

- (void)getThumbsFromPayload:(NSArray *)aPayload;

- (void)fadeInTable;

- (void)updateProgress:(NSNumber *)aProgress;

@end
