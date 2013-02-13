//
//  CUStatus.m
//  CURest
//
//  Created by yg curer on 13-1-31.
//  Copyright (c) 2013年 curer. All rights reserved.
//

#import "CUStatus.h"
#import "CUAdvertisement.h"
#import "CUAdvertisement.h"
#import "CUCategory.h"
#import "CUJSONMapper.h"

@implementation CUStatus


+ (CUJSONMapper *)getObjectMapping
{
    /*
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[CUStatus class]];
    [statusMapping mapKeyPathsToAttributes:
        @"id", @"statusID",
        @"created_at", @"createdAt",
        @"text", @"text",
        @"title", @"title",
        @"watches_count", @"watchesCount",
     nil];
    
    [statusMapping mapKeyPath:@"attachments" toAttribute:@"attachments"];
    
    [statusMapping mapRelationship:@"ad" withMapping:[CUAdvertisement getObjectMapping]];
    [statusMapping mapRelationship:@"category" withMapping:[CUCategory getObjectMapping]];
    
    return statusMapping;*/
    
    CUJSONMapper *statusMapper = [[[CUJSONMapper alloc] init] autorelease];
    [statusMapper registerClass:[CUStatus class] andMappingDescription:@{
        @"id": @"statusID",
        @"created_at" : @"createdAt",
        @"text" : @"text",
        @"title" : @"title",
        @"watches_count" : @"watchesCount",
     }];
    
    [statusMapper addRelationship:[CUAdvertisement getObjectMapping]
                     withJSONName:@"ad"
                     atPropername:@"ad"];
    [statusMapper addRelationship:[CUCategory getObjectMapping]
                     withJSONName:@"category"
                     atPropername:@"category"];
    
    return statusMapper;
}

- (NSString *)getHTMLLink
{
    if ([self.attachments count] > 0) {
        
        for (NSDictionary *dictionary in self.attachments)
        {
            NSString *mimetype = [dictionary objectForKey:@"mimetype"];
            NSString *url = [dictionary objectForKey:@"url"];
            
            if ([mimetype hasPrefix:@"text/url"]) {
                return url;
            }
        }
    }
    
    return nil;
}

- (NSString *)getVideoLink
{
    if ([self.attachments count] > 0) {
        
        for (NSDictionary *dictionary in self.attachments)
        {
            NSString *mimetype = [dictionary objectForKey:@"mimetype"];
            NSString *url = [dictionary objectForKey:@"url"];
            
            if ([mimetype hasPrefix:@"text/url"] && [url hasSuffix:@".m3u8"]) {
                return url;
            }
        }
    }
    
    return nil;
}

- (NSString *)getImageLink
{
    if ([self.attachments count] > 0) {
        
        for (NSDictionary *dictionary in self.attachments)
        {
            NSString *mimetype = [dictionary objectForKey:@"mimetype"];
            NSString *url = [dictionary objectForKey:@"url"];
            
            if ([mimetype hasPrefix:@"image"]) {
                return url;
            }
        }
    }
    
    return nil;
}

- (NSString *)getAppStoreDownloadLink
{
    NSString *link = [self getHTMLLink];
    if ([link hasPrefix:@"https://itunes.apple.com/cn/app/"]) {
        return link;
    }
    
    return nil;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ (ID: %@) (title: %@) category = %@", self.text, self.statusID, self.title, self.category];
}

@end
