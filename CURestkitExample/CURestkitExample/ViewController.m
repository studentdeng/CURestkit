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

@property (nonatomic, strong) ASIHTTPRequest *request;

@end

@implementation ViewController

- (void)dealloc
{
    [self.request clearDelegatesAndCancel];
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self testLocal];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)refresh:(id)sender {
    [self testRefresh];
}

- (IBAction)refreshNoObject:(id)sender {
    [self testNoMappingRefresh];
}

- (void)testNoMappingRefresh
{
    CUObjectManager *manager = [[CUObjectManager alloc] init];
    manager.baseURLString = MAIN_PATH;
    
    CUJSONMapper *mapper = [CUStatus getObjectMapping];
    
    self.request =
    [manager getJSONRequestAtPath:@"statuses/user_timeline"
                       parameters:@{@"user_id": @"1"}
                          success:^(ASIHTTPRequest *ASIRequest, id json) {
                              
                              NSArray *objects = [mapper objectfromJSONArray:json];
                              for (CUStatus *item in objects) {
                                  //NSLog(@"%@", item);
                              }
                              
                              NSDictionary *last = [json lastObject];
                              
                              CUStatus *one = [mapper objectFromJSONDictionary:last];
                              NSLog(@"%@", one);
                              
                              
                          } error:^(ASIHTTPRequest *ASIRequest, NSString *errorMsg) {
                              NSLog(@"error = %@, msg = %@", ASIRequest.error, errorMsg);
                          }];
    
    [self.request startSynchronous];
}

- (void)testRefresh
{
    CUObjectManager *manager = [[CUObjectManager alloc] init];
    manager.baseURLString = MAIN_PATH;
    
    [manager registerMapper:[CUStatus getObjectMapping]
               atServerPath:@"statuses/user_timeline" andJSONPath:@""];
    
    self.request = 
    [manager getObjectsRequestAtPath:@"statuses/user_timeline"
                          parameters:@{@"user_id": @"1"}
                             success:^(ASIHTTPRequest *ASIRequest, NSArray *objects) {
                                 for (CUStatus *item in objects) {
                                     NSLog(@"%@", item);
                                 }
                             } error:^(ASIHTTPRequest *ASIRequest, NSString *errorMsg) {
                                 NSLog(@"error = %@, msg = %@", ASIRequest.error, errorMsg);
                             }];
    
    [self.request startAsynchronous];
}

- (void)testLocal
{
    CUObjectManager *manager = [[CUObjectManager alloc] init];
    manager.baseURLString = MAIN_PATH;
    
    [manager registerMapper:[CUStatus getObjectMapping]
               atServerPath:@"statuses/user_timeline" andJSONPath:@""];
    
    self.request =
    [manager getLocalObjectsRequestAt:@"statuses/user_timeline"
                           parameters:@{@"user_id": @"1"}
                              success:^(ASIHTTPRequest *ASIRequest, NSArray *objects) {
                                  for (CUStatus *item in objects) {
                                      NSLog(@"%@", item);
                                  }
                              } error:^(ASIHTTPRequest *ASIRequest, NSString *errorMsg) {
                                  NSLog(@"error = %@, msg = %@", ASIRequest.error, errorMsg);
                              }];
    
    [self.request startSynchronous];
}

@end
