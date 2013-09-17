//
//  User.m
//  Example
//
//  Created by curer on 9/17/13.
//  Copyright (c) 2013 curer. All rights reserved.
//

#import "User.h"

@implementation User

+ (CUJSONMapper *)getObjectMapping
{
    CUJSONMapper *objectMapping = [[CUJSONMapper alloc] init];
    [objectMapping registerClass:[User class] andMappingDescription:@{
     @"id" : @"userId",
     @"screen_name" : @"screenName",
     }];
    
    return objectMapping;
}

@end
