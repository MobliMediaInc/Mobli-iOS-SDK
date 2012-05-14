//
//  GridTableViewCell.m
//  MobliConnector
//
//  Created by Ariel Krieger on 12/18/11.
//  Copyright (c) 2011 Mobli. All rights reserved.
//

#import "GridTableViewCell.h"


@implementation GridTableViewCell
@synthesize thumb1, thumb2, thumb3, activityIndicator1, activityIndicator2, activityIndicator3;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];

        thumb1 = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 100, 100)];
        thumb2 = [[UIImageView alloc] initWithFrame:CGRectMake(110, 5, 100, 100)];
        thumb3 = [[UIImageView alloc] initWithFrame:CGRectMake(215, 5, 100, 100)];
        thumb1.contentMode = UIViewContentModeScaleAspectFit;
        thumb2.contentMode = UIViewContentModeScaleAspectFit;
        thumb3.contentMode = UIViewContentModeScaleAspectFit;
        activityIndicator1 = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 37, 37)];
        activityIndicator1.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        activityIndicator1.hidesWhenStopped = TRUE;
        [activityIndicator1 startAnimating];
        [self.contentView addSubview:activityIndicator1];
        activityIndicator2 = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 37, 37)];
        activityIndicator2.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        activityIndicator2.hidesWhenStopped = TRUE;
        [activityIndicator2 startAnimating];
        [self.contentView addSubview:activityIndicator2];
        activityIndicator3 = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 37, 37)];
        activityIndicator3.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        activityIndicator3.hidesWhenStopped = TRUE;
        [activityIndicator3 startAnimating];
        [self.contentView addSubview:activityIndicator3];
        [self.contentView addSubview:thumb1];
        [self.contentView addSubview:thumb2];
        [self.contentView addSubview:thumb3];
        activityIndicator1.center = thumb1.center;
        activityIndicator2.center = thumb2.center;
        activityIndicator3.center = thumb3.center;

    }
    return self;
}

- (void)setThumb1Image:(UIImage *)aImage {
    [activityIndicator1 stopAnimating];
    thumb1.alpha = 0.0;
    thumb1.image = aImage;
    [UIView animateWithDuration:0.4
                     animations:^{
                         thumb1.alpha = 1.0;
                     }];
}

- (void)setThumb2Image:(UIImage *)aImage {
    [activityIndicator2 stopAnimating];
    thumb2.alpha = 0.0;
    thumb2.image = aImage;
    [UIView animateWithDuration:0.4
                     animations:^{
                         thumb2.alpha = 1.0;
                     }];
}

- (void)setThumb3Image:(UIImage *)aImage {
    [activityIndicator3 stopAnimating];
    thumb3.alpha = 0.0;
    thumb3.image = aImage;
    [UIView animateWithDuration:0.4
                     animations:^{
                         thumb3.alpha = 1.0;
                     }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)prepareForReuse {
    thumb1.image = nil;
    [activityIndicator1 startAnimating];
    thumb2.image = nil;
    [activityIndicator2 startAnimating];
    thumb3.image = nil;
    [activityIndicator3 startAnimating];
}

- (void)dealloc {
    self.thumb1 = nil;
    self.thumb2 = nil;
    self.thumb3 = nil;
    self.activityIndicator1 = nil;
    self.activityIndicator2 = nil;
    self.activityIndicator3 = nil;
    [super dealloc];
}

@end
