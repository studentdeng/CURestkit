//
//  CUJSONMapper.h
//  CURestkitExample
//
//  Created by yg curer on 13-2-12.
//  Copyright (c) 2013年 curer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CUJSONMapper : NSObject

- (void)registerClass:(Class)class andMappingDescription:(NSDictionary *)dic;
- (void)addRelationship:(CUJSONMapper *)relationshipMapper
           withJSONName:(NSString *)jsonName
           atPropername:(NSString *)properName;

- (void)addValueCover:(NSString *)properName procblock:(id (^)(id value))block;

- (id)objectFromJSONDictionary:(NSDictionary *)jsonDic;
- (id)objectfromJSONArray:(NSArray *)jsonArray;

@property (nonatomic, retain) Class classType;

@end
