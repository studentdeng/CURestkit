//
//  User.h
//  Example
//
//  Created by curer on 9/17/13.
//  Copyright (c) 2013 curer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CURestKit/CURestkit.h>

@interface User : NSObject

+ (CUJSONMapper *)getObjectMapping;

@property (nonatomic, strong) NSNumber *userId;
@property (nonatomic, strong) NSString *screenName;


@end
