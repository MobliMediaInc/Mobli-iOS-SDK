//
//  GridTableViewCell.h
//  MobliConnector
//
//  Created by Ariel Krieger on 12/18/11.
//  Copyright (c) 2011 Mobli. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GridTableViewCell : UITableViewCell

@property(nonatomic, retain)  UIImageView        *thumb1;
@property(nonatomic, retain)  UIImageView        *thumb2;
@property(nonatomic, retain)  UIImageView        *thumb3;
@property(nonatomic, retain)  UIActivityIndicatorView   *activityIndicator1;
@property(nonatomic, retain)  UIActivityIndicatorView   *activityIndicator2;
@property(nonatomic, retain)  UIActivityIndicatorView   *activityIndicator3;



- (void)setThumb1Image:(UIImage *)aImage;
- (void)setThumb2Image:(UIImage *)aImage;
- (void)setThumb3Image:(UIImage *)aImage;

@end
