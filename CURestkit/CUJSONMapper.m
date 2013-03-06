//
//  CUJSONMapper.m
//  CURestkitExample
//
//  Created by yg curer on 13-2-12.
//  Copyright (c) 2013年 curer. All rights reserved.
//

#import "CUJSONMapper.h"

@interface CUJSONMapper ()

@property (nonatomic, retain) NSMutableDictionary *mappingDictionary;
@property (nonatomic, retain) NSMutableDictionary *relationshipMappingDictionary;
@property (nonatomic, retain) NSMutableDictionary *valueCoverblockDictionary;

@end

@implementation CUJSONMapper

- (void)dealloc
{
    self.relationshipMappingDictionary = nil;
    self.mappingDictionary = nil;
    self.valueCoverblockDictionary = nil;
    self.classType = nil;
    
    [super dealloc];
}

- (id)init
{
    if (self = [super init]) {
        self.relationshipMappingDictionary = [NSMutableDictionary dictionary];
        self.mappingDictionary = [NSMutableDictionary dictionary];
        self.valueCoverblockDictionary = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (void)registerClass:(Class)class andMappingDescription:(NSDictionary *)dic
{
    self.classType = class;
    self.mappingDictionary = [NSMutableDictionary dictionaryWithDictionary:dic];
}

- (void)addValueCover:(NSString *)properName procblock:(id (^)(id))block
{
    [[block copy] autorelease];
    [self.valueCoverblockDictionary setObject:block forKey:properName];
}

- (void)addRelationship:(CUJSONMapper *)relationshipMapper
           withJSONName:(NSString *)jsonName
           atPropername:(NSString *)properName
{
    [self.relationshipMappingDictionary setObject:relationshipMapper
                                           forKey:jsonName];
    [self.mappingDictionary setObject:properName forKey:jsonName];
}

- (id)objectFromJSONDictionary:(NSDictionary *)jsonDic
{
    Class classType = self.classType;
    
    id instance = [[[classType alloc] init] autorelease];
    
    [self handlePropertyList:jsonDic atInstance:instance];
    
    return instance;
}

- (void)handleRelationship:(NSDictionary *)jsonDic
              withJSONName:(NSString *)jsonName
                atInstance:(id)instance
{
    CUJSONMapper *mapper = [self.relationshipMappingDictionary objectForKey:jsonName];
    if (mapper) {
        id relationshipInstance = [mapper objectFromJSONDictionary:jsonDic];
        
        NSString *properName = [self classPropertyNameFromJSONName:jsonName];
        [instance setValue:relationshipInstance forKey:properName];
    }
}

- (void)handlePropertyList:(NSDictionary *)jsonDic atInstance:(id)instance
{
    Class classType = [instance class];
    
    for (NSString *item in self.mappingDictionary)
    {
        id value = nil;
        
        if ([self isPathProperty:item]) {
            value = [jsonDic valueForKeyPath:item];
        }
        else
        {
            value = [jsonDic objectForKey:item];
        }
        
        if ([value isKindOfClass:[NSDictionary class]]) {
            [self handleRelationship:value withJSONName:item atInstance:instance];
        }
        else
        {
            NSString *propertyName = [self classPropertyNameFromJSONName:item];
            id (^coverBlock)(id) = [self.valueCoverblockDictionary objectForKey:propertyName];
            if (coverBlock != nil) {
                value = coverBlock(value);
            }
            
            [CUJSONMapper assingValue:value
                     forAttributeName:propertyName
                    andAttributeClass:classType
                             onObject:instance];
        }
    }
}

- (id)objectfromJSONArray:(NSArray *)jsonArray
{
    if ([jsonArray count] == 0) {
        return [NSMutableArray array];
    }
    
    NSMutableArray *resultArray = [NSMutableArray arrayWithCapacity:[jsonArray count]];
    
    for (NSObject *item in jsonArray) {
        if ([item isKindOfClass:[NSDictionary class]]) {
            id object = [self objectFromJSONDictionary:(NSDictionary *)item];
            
            [resultArray addObject:object];
        }
        else if ([item isKindOfClass:[NSArray class]])
        {
            id object = [self objectfromJSONArray:(NSArray *)item];
            [resultArray addObject:object];
        }
    }
    
    return resultArray;
}

// look like user.name
- (BOOL)isPathProperty:(NSString *)name
{
    NSArray *components = [name componentsSeparatedByString:@"."];
    return [components count] != 1;
}

/*
 *  if we can't find this name, we use default name for propertyname which is equal to json key name
 */
- (NSString *)classPropertyNameFromJSONName:(NSString *)name
{
    NSString *propertyName = [self.mappingDictionary objectForKey:name];
    
    if ([propertyName length] > 0) {
        return propertyName;
    }
    
    return name;
}

+ (void)assingValue:(id)value
   forAttributePath:(NSString *)attributePath
  andAttributeClass:(Class) attributeClass
           onObject:(id)object
{
    if([object validateValue:&value forKeyPath:attributePath error:nil]){
        if([value isKindOfClass:[NSNull class]]){
            value = nil;
        }
        if(([value isKindOfClass:[NSNull class]] || value == nil) && attributeClass == [NSString class]){
            [object setValue:nil forKeyPath:attributePath];
        }else {
            [object setValue:value forKeyPath:attributePath];
        }
    }
}

+ (void)assingValue:(id)value
   forAttributeName:(NSString *)attributeName
  andAttributeClass:(Class) attributeClass
           onObject:(id)object
{
    if([object validateValue:&value forKey:attributeName error:nil]){
        if([value isKindOfClass:[NSNull class]]){
            value = nil;
        }
        if(([value isKindOfClass:[NSNull class]] || value == nil) && attributeClass == [NSString class]){
            [object setValue:nil forKey:attributeName];
        }else {
            [object setValue:value forKey:attributeName];
        }
    }
}

@end
