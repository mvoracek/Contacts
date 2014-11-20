//
//  NetworkUtility.h
//  Contacts
//
//  Created by Matthew Voracek on 11/19/14.
//  Copyright (c) 2014 Matthew Voracek. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetworkUtility : NSObject

@property (nonatomic, strong) NSMutableArray *contacts;
@property (nonatomic, strong) NSURLSession *session;

@end
