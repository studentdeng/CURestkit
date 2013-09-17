//
//  Status.m
//  Example
//
//  Created by curer on 9/17/13.
//  Copyright (c) 2013 curer. All rights reserved.
//

#import "Status.h"
#import "User.h"

static NSDateFormatter *s_format = nil;

@implementation Status

+ (CUJSONMapper *)getObjectMapping
{
    CUJSONMapper *objectMapping = [[CUJSONMapper alloc] init];
    [objectMapping registerClass:[Status class] andMappingDescription:@{
     @"id" : @"statusId",
     @"mid" : @"mid",
     @"created_at" : @"createdAt",
     @"favorited" : @"isFavorited",
     }];
    
    [objectMapping addRelationship:[User getObjectMapping]
                      withJSONName:@"user"
                      atPropername:@"user"];
    
    [objectMapping addValueCover:@"createdAt"
                       procblock:^id(id value) {
                           if (s_format == nil) {
                               s_format = [[NSDateFormatter alloc] init];
                               [s_format setDateFormat:@"E MMM d HH:mm:ss Z y"];
                               [s_format setLocale:[[NSLocale alloc]
                                                    initWithLocaleIdentifier:@"en_US_POSIX"]];
                           }
                           
                           return [s_format dateFromString:value];
                       }];
    
    return objectMapping;
}

@end
