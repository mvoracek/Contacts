//
//  NetworkUtility.m
//  Contacts
//
//  Created by Matthew Voracek on 11/19/14.
//  Copyright (c) 2014 Matthew Voracek. All rights reserved.
//

#import "NetworkUtility.h"

static NSString *const URLHost = @"https://solstice.applauncher.com/external/";
static NSString *const URLContacts = @"contacts.json";

@implementation NetworkUtility

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
//                    [self.spinner stopAnimating];
//                    [self.tableView reloadData];
                });
            }
            
            
        }
    }];
    [dataTask resume];
}


@end
