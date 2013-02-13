//
//  CUAdvertisement.h
//  CURest
//
//  Created by yg curer on 13-2-1.
//  Copyright (c) 2013年 curer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CUAdvertisement : NSObject

+ (CUJSONMapper *)getObjectMapping;

- (BOOL)isFullScreen;
- (BOOL)isHalfScreen;
- (BOOL)isIPhone;

@property (nonatomic, strong) NSString *resolution;
@property (nonatomic, strong) NSString *style;

@end
