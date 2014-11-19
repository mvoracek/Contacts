//
//  DetailViewController.m
//  Contacts
//
//  Created by Matthew Voracek on 11/19/14.
//  Copyright (c) 2014 Matthew Voracek. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *contactPhoto;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *companyLabel;
@property (weak, nonatomic) IBOutlet UILabel *workPhone;
@property (weak, nonatomic) IBOutlet UILabel *homePhone;
@property (weak, nonatomic) IBOutlet UILabel *mobilePhone;


@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem {
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
            
        // Update the view.
        [self configureView];
    }
}

- (void)configureView {
    // Update the user interface for the detail item.
    if (self.detailItem) {
        self.nameLabel.text = self.detailItem[@"name"];
        self.companyLabel.text = self.detailItem[@"company"];
        self.workPhone.text = self.detailItem[@"phone"][@"work"];
        self.homePhone.text = self.detailItem[@"phone"][@"home"];
        self.mobilePhone.text = self.detailItem[@"phone"][@"mobile"];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}



@end
