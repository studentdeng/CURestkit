//
//  CUCategory.h
//  CURest
//
//  Created by yg curer on 13-2-1.
//  Copyright (c) 2013年 curer. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CUJSONMapper;
@interface CUCategory : NSObject

+ (CUJSONMapper *)getObjectMapping;

@property (nonatomic, strong) NSString *url;

@end
