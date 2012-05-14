//
//  ConnectorNotificationCell.h
//  Connector
//
//  Created by Ariel Krieger on 5/14/12.
//  Copyright (c) 2012 Mobli. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConnectorNotificationCell : UITableViewCell {
    id                  subject;
}


@property(nonatomic, assign) id subject;

- (void)setSubject:(id)subject;
- (id)subject;
@end
