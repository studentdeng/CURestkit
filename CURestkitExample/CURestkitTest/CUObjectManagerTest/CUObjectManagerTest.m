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
#import "ASIHTTPRequest.h"

#define MAIN_PATH @"http://42.121.117.183/ci_rest/index.php/api/"

@implementation CUObjectManagerTest

- (void)testRefresh
{
    CUObjectManager *manager = [[[CUObjectManager alloc] init] autorelease];
    manager.baseURLString = MAIN_PATH;
    
    [manager registerMapper:[CUStatus getObjectMapping]
               atServerPath:@"statuses/user_timeline" andJSONPath:@""];
    
    [manager getObjectsAtPath:@"statuses/user_timeline"
                   parameters:@{@"user_id": @"1"}
                      success:^(ASIHTTPRequest *jsonOperation, NSArray *objects) {
                          for (CUStatus *item in objects) {
                              STAssertEqualObjects([item class], [CUStatus class], @"");
                              NSLog(@"%@", item);
                          }
                      } error:^(ASIHTTPRequest *jsonOperation, NSString *errorMsg) {
                          NSLog(@"error = %@, msg = %@", jsonOperation.error, errorMsg);
                          STFail(@"network error or parse error");
                      }];
    
    
    [self waitForTimeout:10.0f];
}

- (void)testLocal
{
    CUObjectManager *manager = [[[CUObjectManager alloc] init] autorelease];
    manager.baseURLString = MAIN_PATH;
    
    [manager registerMapper:[CUStatus getObjectMapping]
               atServerPath:@"statuses/user_timeline" andJSONPath:@""];
    
    [manager getObjectsAtPath:@"statuses/user_timeline"
                   parameters:@{@"user_id": @"1"}
                      success:^(ASIHTTPRequest *jsonOperation, NSArray *objects) {
                          for (CUStatus *item in objects) {
                              STAssertEqualObjects([item class], [CUStatus class], @"");
                              NSLog(@"%@", item);
                          }
                      } error:^(ASIHTTPRequest *jsonOperation, NSString *errorMsg) {
                          NSLog(@"error = %@, msg = %@", jsonOperation.error, errorMsg);
                          STFail(@"network error or parse error");
                      }];
    
    [manager cancelAllRequest];
    
    [self waitForTimeout:10.0f];
}

@end
