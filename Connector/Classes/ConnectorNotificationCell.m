//
//  ConnectorNotificationCell.m
//  Connector
//
//  Created by Ariel Krieger on 5/14/12.
//  Copyright (c) 2012 Mobli. All rights reserved.
//

#import "ConnectorNotificationCell.h"

@interface ConnectorNotificationCell ()

@property(nonatomic, retain) UIImageView    *notificationImageView;
@property(nonatomic, retain) UILabel        *notificationLabel;

@end

@interface ConnectorNotificationCell (Private)

- (void)postSetSubject;

@end

@implementation ConnectorNotificationCell (Private)

- (void)postSetSubject {
    NSString *mediaId = [(NSDictionary *)subject valueForKey:@"entity_id"];
    NSString *msgText = [(NSDictionary *)subject valueForKey:@"value"];
    NSString *thumbPath = [NSString stringWithFormat:@"%@thumbs/thumb_%@_200.jpg",kMobliCDNDomain,mediaId];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:thumbPath]]];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (image != nil) {
                self.notificationImageView.image = image;
            }
        });
    });
    
    self.notificationLabel.text = msgText;
}

@end


@implementation ConnectorNotificationCell

@synthesize notificationLabel, notificationImageView;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;

        notificationImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 80, 80)];
        notificationImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:notificationImageView];
        
        notificationLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 10, 200, 80)];
        notificationLabel.backgroundColor = [UIColor clearColor];
        notificationLabel.textColor = [UIColor lightTextColor];
        notificationLabel.lineBreakMode = UILineBreakModeWordWrap;
        notificationLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:12.0];
        notificationLabel.textAlignment = UITextAlignmentLeft;
        [self.contentView addSubview:notificationLabel];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)setSubject:(id)aSubject {
    subject = aSubject;
    [self postSetSubject];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    notificationImageView.image = nil;
}
- (id)subject {
    return subject;
}

- (void)dealloc {
    self.notificationImageView = nil;
    self.notificationLabel = nil;
    [super dealloc];
}
@end
