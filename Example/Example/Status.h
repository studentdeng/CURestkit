//
//  Status.h
//  Example
//
//  Created by curer on 9/17/13.
//  Copyright (c) 2013 curer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CURestKit/CURestkit.h>

@class User;
@interface Status : NSObject

+ (CUJSONMapper *)getObjectMapping;

@property (nonatomic, strong) NSNumber *isFavorited;
@property (nonatomic, strong) NSString *mid;
@property (nonatomic, strong) NSDate *createdAt;
@property (nonatomic, strong) User *user;
@property (nonatomic, strong) NSNumber *statusId;

@end
