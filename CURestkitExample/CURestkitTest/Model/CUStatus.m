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
#import "CUUser.h"

static NSDateFormatter *s_format = nil;

@implementation CUStatus


+ (CUJSONMapper *)getObjectMapping
{
    CUJSONMapper *statusMapper = [[[CUJSONMapper alloc] init] autorelease];
    [statusMapper registerClass:[CUStatus class] andMappingDescription:@{
        @"id": @"statusID",
        @"created_at" : @"createdAt",
        @"text" : @"text",
        @"title" : @"title",
        @"watches_count" : @"watchesCount",
        @"attachments" : @"attachments"
     }];
    
    [statusMapper addValueCover:@"createdAt" procblock:^id(id value) {
        
        if (s_format == nil) {
            s_format = [[NSDateFormatter alloc] init];
            [s_format setDateFormat:@"E MMM d HH:mm:ss Z y"];
        }
        
        return [s_format dateFromString:value];
    }];
    
    [statusMapper addRelationship:[CUAdvertisement getObjectMapping]
                     withJSONName:@"ad"
                     atPropername:@"ad"];
    
    [statusMapper addRelationship:[CUCategory getObjectMapping]
                     withJSONName:@"category"
                     atPropername:@"category"];
    
    [statusMapper addRelationship:[CUUser getObjectMapping]
                     withJSONName:@"user"
                     atPropername:@"user"];
    
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
