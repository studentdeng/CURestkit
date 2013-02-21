//
//  ViewController.m
//  CURestkitExample
//
//  Created by yg curer on 13-2-12.
//  Copyright (c) 2013年 curer. All rights reserved.
//

#import "ViewController.h"
#import "CUStatus.h"
#import "CUAdvertisement.h"
#import "CUCategory.h"

#import "CURestkit.h"

#define MAIN_PATH @"http://42.121.117.183/ci_rest/index.php/api/"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)refresh:(id)sender {
    [self testRefresh];
}

- (void)testRefresh
{
    CUObjectManager *manager = [[CUObjectManager alloc] init];
    manager.baseURLString = MAIN_PATH;
    
    [manager registerMapper:[CUStatus getObjectMapping]
               atServerPath:@"statuses/user_timeline4" andJSONPath:@""];
    
    [manager getObjectsAtPath:@"statuses/user_timeline"
                   parameters:@{@"user_id": @"1"}
                      success:^(ASIHTTPRequest *jsonOperation, NSArray *objects) {
                          for (CUStatus *item in objects) {
                              NSLog(@"%@", item);
                          }
                      } error:^(ASIHTTPRequest *jsonOperation, NSString *errorMsg) {
                          NSLog(@"error = %@, msg = %@", jsonOperation.error, errorMsg);
                      }];
}

- (void)testLocal
{
    CUObjectManager *manager = [[CUObjectManager alloc] init];
    manager.baseURLString = MAIN_PATH;
    
    [manager registerMapper:[CUStatus getObjectMapping]
               atServerPath:@"statuses/user_timeline" andJSONPath:@""];
    
    [manager getLocalObjectsAt:@"statuses/user_timeline"
                    parameters:@{@"user_id": @"1"}
                       success:^(ASIHTTPRequest *jsonOperation, NSArray *objects) {
                           for (CUStatus *item in objects) {
                               NSLog(@"%@", item);
                           }
                       } error:^(ASIHTTPRequest *jsonOperation, NSString *errorMsg) {
                           NSLog(@"error = %@, msg = %@", jsonOperation.error, errorMsg);
                       }];
}

@end
