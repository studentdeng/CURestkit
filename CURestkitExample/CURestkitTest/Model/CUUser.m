//
//  CUUser.m
//  CUWeiboKit
//
//  Created by yg curer on 13-2-20.
//  Copyright (c) 2013年 curer. All rights reserved.
//

#import "CUUser.h"


@implementation CUUser

+ (CUJSONMapper *)getObjectMapping
{
    CUJSONMapper *userMapper = [[[CUJSONMapper alloc] init] autorelease];
    [userMapper registerClass:[CUUser class] andMappingDescription:@{
     @"id": @"userID",
     @"screen_name" : @"name",
     @"name" : @"displayName",
     @"profile_image_url" : @"avatarImageURLString"
     }];
    
    return userMapper;
}

@end
