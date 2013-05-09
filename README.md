CURestkit
=========

#description

Inspired By Restkit.

light weight of client for RESTFul server. 

I want to make it easy to use. because I don't like coreData and so many class : ). 

#example for json mapping class

## JSON file

	JSON:

	{
		"user_h":
		{
			"name":"curer"
		},
		"text":"hello world come on curer"
	}

## Model class 

	@interface Status : NSObject

	@property (nonatomic, retain) NSString *text;
	@property (nonatomic, retain) User *user;
	@property (nonatomic, retain) NSString *statusUsername;

	@end

	@interface User : NSObject

	@property (nonatomic, retain) NSString *username;

	@end

## how to use mapper 

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



#example for create request and parse json result

	CUObjectManager *manager = [[[CUObjectManager alloc] init] autorelease];
    manager.HTTPClient = client;
    
    [manager registerMapper:[CUStatus getObjectMapping]
               atServerPath:@"statuses/user_timeline" andJSONPath:@""];
    
    [manager getObjectsAtPath:@"statuses/user_timeline"
                   parameters:@{@"user_id": @"1"}
                      success:^(AFJSONRequestOperation *jsonOperation, NSArray *objects) {
                          for (CUStatus *item in objects) {
                              STAssertEqualObjects([item class], [CUStatus class], @"");
                              NSLog(@"%@", item);
                          }
                      } error:^(AFJSONRequestOperation *jsonOperation, NSString *errorMsg) {
                          NSLog(@"error = %@, msg = %@", jsonOperation.error, errorMsg);
                          STFail(@"network error or parse error");
                      }];
    
    
    [self waitForTimeout:10.0f];
