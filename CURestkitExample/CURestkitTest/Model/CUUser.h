//
//  CUUser.h
//  CUWeiboKit
//
//  Created by yg curer on 13-2-20.
//  Copyright (c) 2013年 curer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CUUser : NSObject

+ (CUJSONMapper *)getObjectMapping;

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, strong) NSString *avatarImageURLString;
@property (nonatomic, strong) NSNumber *userID;

@end
