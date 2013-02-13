//
//  CUStatus.h
//  CURest
//
//  Created by yg curer on 13-1-31.
//  Copyright (c) 2013年 curer. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CUAdvertisement;
@class CUCategory;
@class CUJSONMapper;

@interface CUStatus : NSObject

+ (CUJSONMapper *)getObjectMapping;

- (NSString *)getHTMLLink;
- (NSString *)getVideoLink;
- (NSString *)getImageLink;
- (NSString *)getAppStoreDownloadLink;

@property (nonatomic, strong) CUAdvertisement *ad;
@property (nonatomic, strong) CUCategory *category;
@property (nonatomic, strong) NSNumber *statusID;

/**
 * Timestamp the Status was sent
 */
@property (nonatomic, strong) NSDate *createdAt;

/**
 * Text of the Status
 */
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSNumber *watchesCount;

@property (nonatomic, strong) NSArray *attachments;

@end
