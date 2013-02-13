//
//  CUCategory.m
//  CURest
//
//  Created by yg curer on 13-2-1.
//  Copyright (c) 2013年 curer. All rights reserved.
//

#import "CUCategory.h"

@implementation CUCategory

+ (CUJSONMapper *)getObjectMapping
{
    CUJSONMapper *categoryMapper = [[[CUJSONMapper alloc] init] autorelease];
    [categoryMapper registerClass:[CUCategory class] andMappingDescription:@{@"url": @"url"}];
    
    return categoryMapper;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@", self.url];
}

@end
