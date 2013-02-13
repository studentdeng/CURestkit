//
//  CUJSONMapperTest.m
//  CUJSONMapperTest
//
//  Created by yg curer on 13-2-12.
//  Copyright (c) 2013年 curer. All rights reserved.
//

#import "CUJSONMapperTest.h"
#import "CUJSONMapper.h"

@interface User : NSObject

@property (nonatomic, retain) NSString *username;

@end

@implementation User

@end


@interface Status : NSObject

@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) User *user;
@property (nonatomic, retain) NSString *statusUsername;

@end

@implementation Status

@end

@implementation CUJSONMapperTest

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
    NSString *path = [[NSBundle mainBundle] pathForResource:@"json" ofType:@"json"];
    
    NSString *json = [NSString stringWithContentsOfURL:[NSURL fileURLWithPath:path]
                                              encoding:NSUTF8StringEncoding
                                                 error:nil];
    
    self.jsonArray = [json JSONValue];
}

- (void)tearDown
{
    // Tear-down code here.
    
    self.jsonArray = nil;
    
    [super tearDown];
}

- (void)testSimple
{    
    CUJSONMapper *statusMapper = [[[CUJSONMapper alloc] init] autorelease];
    NSDictionary *statusMapping = @{@"user_h.name": @"statusUsername", @"text":@"text"};
    [statusMapper registerClass:[Status class] andMappingDescription:statusMapping];
    
    CUJSONMapper *userMapper = [[[CUJSONMapper alloc] init] autorelease];
    NSDictionary *userMapping = @{@"name": @"username"};
    [userMapper registerClass:[User class] andMappingDescription:userMapping];
    
    [statusMapper addRelationship:userMapper
                     withJSONName:@"user_h"
                     atPropername:@"user"];
    
    NSDictionary *statusDic = @{
                                @"user_h": @{
                                        @"name": @"curer"
                                        },
                                @"text": @"hello world come on curer"
                                };
    
    Status *status = [statusMapper objectFromJSONDictionary:statusDic];
    
    STAssertEqualObjects(status.text, [statusDic objectForKey:@"text"], @"");
    STAssertEqualObjects(status.user.username, [statusDic valueForKeyPath:@"user_h.name"], @"");
    STAssertEqualObjects(status.statusUsername, [statusDic valueForKeyPath:@"user_h.name"], @"");
}

- (void)testdictionary
{
    NSDictionary *statusDic = [self.jsonArray objectAtIndex:0];
    
    CUJSONMapper *mapper = [CUStatus getObjectMapping];
    CUStatus *status = [mapper objectFromJSONDictionary:statusDic];
    
    [self statusCompare:status andDic:statusDic];
}

- (void)testArray
{
    CUJSONMapper *mapper = [CUStatus getObjectMapping];
    
    NSArray *statusList = [mapper objectfromJSONArray:self.jsonArray];
    
    STAssertEquals([statusList count], [self.jsonArray count], @"");
    
    for (int i = 0; i < [self.jsonArray count]; ++i) {
        NSDictionary *statusDic = [self.jsonArray objectAtIndex:i];
        CUStatus *status = [mapper objectFromJSONDictionary:statusDic];
        [self statusCompare:status andDic:statusDic];
    }
}

- (void)testDateCover
{
    CUJSONMapper *mapper = [CUStatus getObjectMapping];
    
    [mapper addValueCover:@"createdAt" procblock:^id(id propertyValue) {
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"E MMM d HH:mm:ss Z y"];
        return [df dateFromString:propertyValue];
    }];
    
    for (NSDictionary *statusDic in self.jsonArray) {
        CUStatus *status = [mapper objectFromJSONDictionary:statusDic];
        [self statusCompare:status andDic:statusDic];
        
        NSLog(@"%@", status.createdAt);
    }
}

- (void)statusCompare:(CUStatus *)status andDic:(NSDictionary *)statusDic
{
    STAssertEqualObjects(status.text, [statusDic objectForKey:@"text"], @"");
    STAssertEqualObjects(status.statusID, [statusDic objectForKey:@"id"], @"");
    STAssertEqualObjects(status.title, [statusDic objectForKey:@"title"], @"");
    STAssertEqualObjects(status.watchesCount, [statusDic objectForKey:@"watches_count"], @"");
    STAssertEqualObjects(status.ad.resolution, [statusDic valueForKeyPath:@"ad.resolution"], @"");
    STAssertEqualObjects(status.ad.style, [statusDic objectForKey:@"ad.style"], @"");
    STAssertEqualObjects(status.category.url, [statusDic valueForKeyPath:@"category.url"], @"");
    
    STAssertTrue([[status.statusID class] isSubclassOfClass:[NSNumber class]], @"");
}

@end
