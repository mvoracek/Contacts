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
@property NSMutableArray *names;
@property NSMutableArray *workNumbers;
@property NSMutableArray *photos;
@property NSMutableArray *contacts;


@end

static NSString *const CellID = @"contactCell";
static NSString *const URLHost = @"https://solstice.applauncher.com/external/";
static NSString *const URLContacts = @"contacts.json";

@implementation MasterViewController

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    self.session = [NSURLSession sessionWithConfiguration:config];
    
    self.names = [NSMutableArray array];
    self.workNumbers = [NSMutableArray array];
    self.photos = [NSMutableArray array];
    self.contacts = [NSMutableArray array];
    [self contactsFromJSON];
}

- (void)insertNewObject:(id)sender {
    if (!self.names) {
        self.names = [[NSMutableArray alloc] init];
    }
    [self.names insertObject:[NSDate date] atIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
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
                    NSString *name = contacts[@"name"];
                    NSString *number = contacts[@"phone"][@"work"];
                    NSString *photo = contacts[@"smallImageURL"];
                    [self.names addObject:name];
                    [self.workNumbers addObject:number];
                    [self.photos addObject:photo];
                    [self.contacts addObject:contacts];
                }
                [self.tableView reloadData];
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
    return self.names.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MasterTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellID forIndexPath:indexPath];

//    NSDate *object = self.objects[indexPath.row];
//    cell.textLabel.text = [object description];
    
    NSURL *imageURL = [NSURL URLWithString:self.photos[indexPath.row]];
    NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
    cell.contactImage.image = [UIImage imageWithData:imageData];
    
    cell.contactName.text = self.names[indexPath.row];
    cell.phoneNumber.text = self.workNumbers[indexPath.row];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.names removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0;
}

@end
