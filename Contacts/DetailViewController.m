//
//  DetailViewController.m
//  Contacts
//
//  Created by Matthew Voracek on 11/19/14.
//  Copyright (c) 2014 Matthew Voracek. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()

@property (nonatomic, strong) NSURLSession *session;
@property NSString *photo;
@property NSDictionary *addressInfo;
@property (weak, nonatomic) IBOutlet UIImageView *contactPhoto;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *companyLabel;
@property (weak, nonatomic) IBOutlet UILabel *workPhone;
@property (weak, nonatomic) IBOutlet UILabel *homePhone;
@property (weak, nonatomic) IBOutlet UILabel *mobilePhone;
@property (weak, nonatomic) IBOutlet UILabel *streetAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *cityStateZipLabel;
@property (weak, nonatomic) IBOutlet UILabel *birthdayLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;

@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem {
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
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
        self.birthdayLabel.text = [self dateFromSeconds:self.detailItem[@"birthdate"]];
        self.streetAddressLabel.text = self.addressInfo[@"street"];
        self.cityStateZipLabel.text = [self createCityStateZip];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.addressInfo = [NSDictionary dictionary];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    self.session = [NSURLSession sessionWithConfiguration:config];
    
    [self contactsFromJSON];
}

- (NSString *)dateFromSeconds:(NSString *)seconds
{
    NSInteger dateInt = [seconds integerValue];
    NSDate *lastUpdate = [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:-dateInt];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    
    NSString *birthdate = [dateFormatter stringFromDate:lastUpdate];
    
    return birthdate;
}

- (NSString *)createCityStateZip
{
    NSString *city = [NSString stringWithString:self.addressInfo[@"city"]];
    NSString *state = [NSString stringWithString:self.addressInfo[@"state"]];
    NSString *zip = [NSString stringWithString:self.addressInfo[@"zip"]];
    NSString *cityStateZip = [NSString stringWithFormat:@"%@, %@ %@", city, state, zip];
    
    return cityStateZip;
}

- (NSURL *)createURL
{
    NSURL *url = [NSURL URLWithString:self.detailItem[@"detailsURL"]];
    return url;
}

- (void)contactsFromJSON
{
    NSURL *url = [self createURL];
    __block NSString *photo;
    
    NSURLSessionDataTask *dataTask = [self.session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            NSHTTPURLResponse *httpResp = (NSHTTPURLResponse *)response;
            if (httpResp.statusCode == 200) {
                //                NSError *jsonError;
                
                NSDictionary *contactsJSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                
                NSLog(@"%@", contactsJSON);
                
                photo = contactsJSON[@"largeImageURL"];
                self.photo = photo;
                NSURL *imageURL = [NSURL URLWithString:self.photo];
                NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
                self.contactPhoto.image = [UIImage imageWithData:imageData];
                self.addressInfo = contactsJSON[@"address"];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.contactPhoto.image = [UIImage imageWithData:imageData];
                    self.emailLabel.text = contactsJSON[@"email"];
                    [self configureView];
                });
            }
        }
    }];
    [dataTask resume];
}

@end
