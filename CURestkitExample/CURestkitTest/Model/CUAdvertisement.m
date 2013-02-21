//
//  CUAdvertisement.m
//  CURest
//
//  Created by yg curer on 13-2-1.
//  Copyright (c) 2013年 curer. All rights reserved.
//

#import "CUAdvertisement.h"
#import "CUJSONMapper.h"

@implementation CUAdvertisement

+ (CUJSONMapper *)getObjectMapping
{
    CUJSONMapper *adMapper = [[[CUJSONMapper alloc] init] autorelease];
    [adMapper registerClass:[CUAdvertisement class] andMappingDescription:@{
        @"resolution": @"resolution",
        @"style" : @"style"
     }];
    
    return adMapper;
}


- (BOOL)isFullScreen
{
    return [self isIPhone] && [self.style isEqualToString:@"full"];
}

- (BOOL)isHalfScreen
{
    return [self isIPhone] && [self.style isEqualToString:@"half"];
}

- (BOOL)isIPhone
{
    return [self.resolution isEqualToString:@"iphone"];
}

@end
