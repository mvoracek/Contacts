//
//  MasterViewController.m
//  Contacts
//
//  Created by Matthew Voracek on 11/19/14.
//  Copyright (c) 2014 Matthew Voracek. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "MasterTableViewCell.h"

@interface MasterViewController ()

@property (nonatomic, strong) NSURLSession *session;
@property NSMutableArray *contacts;
@property CGRect screenBounds;
@property (strong, nonatomic) UIActivityIndicatorView *spinner;

@end

static NSString *const CellID = @"contactCell";
static NSString *const URLHost = @"https://solstice.applauncher.com/external/";
static NSString *const URLContacts = @"contacts.json";

@implementation MasterViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    self.session = [NSURLSession sessionWithConfiguration:config];
    self.contacts = [NSMutableArray array];
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
    
    [self contactsFromJSON];
}

- (NSURL *)createURL
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",URLHost, URLContacts]];
    
    return url;
}

- (void)contactsFromJSON
{
    NSURL *url = [self createURL];
    
    NSURLSessionDataTask *dataTask = [self.session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            NSHTTPURLResponse *httpResp = (NSHTTPURLResponse *)response;
            if (httpResp.statusCode == 200) {
//                NSError *jsonError;
                
                NSArray *contactsJSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                
                NSLog(@"%@", contactsJSON);
                
                for (NSDictionary *contacts in contactsJSON) {
                    [self.contacts addObject:contacts];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.spinner stopAnimating];
                    [self.tableView reloadData];
                });
            }
            
            
        }
    }];
    [dataTask resume];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSMutableArray *contact = self.contacts[indexPath.row];
        [[segue destinationViewController] setDetailItem:contact];
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.contacts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MasterTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellID forIndexPath:indexPath];

    NSDictionary *contactDict = self.contacts[indexPath.row];
    NSURL *imageURL = [NSURL URLWithString:contactDict[@"smallImageURL"]];
    NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
    cell.contactImage.image = [UIImage imageWithData:imageData];
    
    cell.contactName.text = contactDict[@"name"];
    cell.phoneNumber.text = contactDict[@"phone"][@"work"];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0;
}

@end
