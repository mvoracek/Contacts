//
//  MasterTableViewCell.h
//  Contacts
//
//  Created by Matthew Voracek on 11/19/14.
//  Copyright (c) 2014 Matthew Voracek. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MasterTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *contactName;
@property (weak, nonatomic) IBOutlet UILabel *phoneNumber;

@end
