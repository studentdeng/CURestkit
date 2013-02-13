//
//  CUObjectManagerTest.m
//  CURestkitExample
//
//  Created by yg curer on 13-2-13.
//  Copyright (c) 2013年 curer. All rights reserved.
//

#import "CUObjectManagerTest.h"
#import "CUJSONMapper.h"
#import "CUObjectManager.h"
#import "AFNetworking.h"

#define MAIN_PATH @"http://42.121.117.183/ci_rest/index.php/api/"

@implementation CUObjectManagerTest

- (void)testSimple
{
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:MAIN_PATH]];
    
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
}

@end
