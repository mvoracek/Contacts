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
@property (weak, nonatomic) IBOutlet UIImageView *favoriteStar;
@property CGRect screenBounds;
@property (strong, nonatomic) UIActivityIndicatorView *spinner;

@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)setContactDetails:(id)newDetailItem {
    if (_contactDetails != newDetailItem) {
        _contactDetails = newDetailItem;
    }
}

- (void)configureView {
    
    if (self.contactDetails) {
        self.nameLabel.text = self.contactDetails[@"name"];
        self.companyLabel.minimumScaleFactor = 10./self.companyLabel.font.pointSize;
        self.companyLabel.adjustsFontSizeToFitWidth = YES;
        self.companyLabel.text = self.contactDetails[@"company"];
        self.workPhone.text = self.contactDetails[@"phone"][@"work"];
        self.homePhone.text = self.contactDetails[@"phone"][@"home"];
        self.mobilePhone.text = self.contactDetails[@"phone"][@"mobile"];
        self.birthdayLabel.text = [self dateFromSeconds:self.contactDetails[@"birthdate"]];
        self.streetAddressLabel.text = self.addressInfo[@"street"];
        self.cityStateZipLabel.text = [self createCityStateZip];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.addressInfo = [NSDictionary dictionary];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    self.session = [NSURLSession sessionWithConfiguration:config];
    
    self.screenBounds = [UIScreen mainScreen].bounds;
    CGFloat navBarHeight = self.navigationController.navigationBar.frame.size.height;
    CGFloat screenCenterX = self.screenBounds.size.width / 2;
    CGFloat screenCenterY = (self.screenBounds.size.height / 2) - navBarHeight;
    self.spinner = [[UIActivityIndicatorView alloc]
                    initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.spinner.center = CGPointMake(screenCenterX, screenCenterY);
    self.spinner.hidesWhenStopped = YES;
    [self.view addSubview:self.spinner];
    [self.spinner startAnimating];
    
    self.contactPhoto.image = [UIImage imageNamed:@"default"];
    [self requestForDetails];
}

#pragma mark - Data for details

- (NSString *)dateFromSeconds:(NSString *)seconds
{
    NSInteger dateInt = [seconds integerValue];
    //not sure what time interval to use here so I chose something that made the dates somewhat feasible
    NSDate *lastUpdate = [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:-labs(dateInt)];
    
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

- (void)downloadImageWithURL:(NSURL *)url completionBlock:(void (^)(BOOL succeeded, UIImage *image))completionBlock
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if (!error)
                               {
                                   UIImage *image = [[UIImage alloc] initWithData:data];
                                   completionBlock(YES,image);
                               } else {
                                   completionBlock(NO,nil);
                               }
                           }];
}

- (void)requestForDetails
{
    NSURL *url = [NSURL URLWithString:self.contactDetails[@"detailsURL"]];
    __block NSString *photo;
    
    NSURLSessionDataTask *dataTask = [self.session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            NSHTTPURLResponse *httpResp = (NSHTTPURLResponse *)response;
            if (httpResp.statusCode == 200) {
                
                NSDictionary *contactsDetails = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                
                photo = contactsDetails[@"largeImageURL"];
                NSURL *photoURL = [NSURL URLWithString:photo];
                NSData *photoData = [NSData dataWithContentsOfURL:photoURL];
                self.contactPhoto.image = [UIImage imageWithData:photoData];
                self.addressInfo = contactsDetails[@"address"];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self downloadImageWithURL:photoURL completionBlock:^(BOOL succeeded, UIImage *image) {
                        if (succeeded) {
                            self.contactPhoto.image = image;
                        } else {
                            //error handling
                        }
                    }];
                    self.emailLabel.text = contactsDetails[@"email"];
                    BOOL favorite = [contactsDetails[@"favorite"] boolValue];
                    if (favorite) {
                        self.favoriteStar.image = [UIImage imageNamed:@"goldStar"];
                    } else {
                        self.favoriteStar.image = [UIImage imageNamed:@"emptyStar"];
                    }
                    [self.spinner stopAnimating];
                    [self configureView];
                });
            } else {
                //json error handling
            }
        } else {
            //error handling
        }
    }];
    [dataTask resume];
}

@end
