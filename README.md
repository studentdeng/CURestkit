CURestkit
=========

ARC support

#install

	platform :ios, '5.0'
	pod 'CURestKit', :git => 'https://github.com/studentdeng/CURestkit'

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

```objc
- (void)parseJSONFileDic
{
    NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"json1"
                                                                                  ofType:@"json"]];
    
    NSError *error = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:data
                                                    options:kNilOptions
                                                      error:&error];
    
    CUJSONMapper *mapper = [Status getObjectMapping];
    NSDictionary *statusDic = [jsonObject[@"statuses"] lastObject];
    
    Status *status = [mapper objectFromJSONDictionary:statusDic];
    
    NSLog(@"%@",status);
}

- (void)parseJSONFileArray
{
    NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"json1"
                                                                                  ofType:@"json"]];
    
    NSError *error = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:data
                                                    options:kNilOptions
                                                      error:&error];
    
    CUJSONMapper *mapper = [Status getObjectMapping];
    
    NSArray *list = [mapper objectfromJSONArray:jsonObject[@"statuses"]];
    
    NSLog(@"%@", list);
}

- (void)fetchList
{
    CUObjectManager *manager = [[CUObjectManager alloc] init];
    manager.baseURLString = @"https://api.weibo.com/2/";
    
    [manager registerMapper:[Status getObjectMapping]
               atServerPath:@"statuses/public_timeline.json"
                andJSONPath:@"statuses"];
    
    ASIHTTPRequest *request = 
    [manager getObjectsRequestAtPath:@"statuses/public_timeline.json"
                          parameters:@{
                                @"access_token" : SINA_TOKEN
                            }
                             success:^(ASIHTTPRequest *ASIRequest, NSArray *objects) {
                                 NSLog(@"%@", objects);
                             } error:^(ASIHTTPRequest *ASIRequest, NSString *errorMsg) {
                                 
                             }];
    
    [request startSynchronous];
}

```