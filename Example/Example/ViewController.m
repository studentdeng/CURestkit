//
//  ViewController.m
//  Example
//
//  Created by curer on 9/12/13.
//  Copyright (c) 2013 curer. All rights reserved.
//

#import "ViewController.h"
#import "User.h"
#import "Status.h"
#import <CURestKit/CURestkit.h>

#define SINA_TOKEN  @""

@interface ViewController ()

@property (nonatomic, strong) CUObjectManager *manager;
@property (nonatomic, strong) NSMutableArray *requestList;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
  
    self.requestList = [NSMutableArray array];
    self.manager = [[CUObjectManager alloc] init];
    
    [self fetchList];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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
    self.manager.baseURLString = @"http://112.124.107.63/";
    
    [self.manager registerMapper:[Status getObjectMapping]
               atServerPath:@"demo_data/test_weibo_timeline.json"
                andJSONPath:@"statuses"];
    
    ASIHTTPRequest *request = 
    [self.manager getObjectsRequestAtPath:@"demo_data/test_weibo_timeline.json"
                          parameters:nil
                             success:^(ASIHTTPRequest *ASIRequest, NSArray *objects) {
                                 NSLog(@"%@", objects);
                             } error:^(ASIHTTPRequest *ASIRequest, NSString *errorMsg) {
                                 
                             }];
    
    [request startAsynchronous];
  
    [self.requestList addObject:request];
}

#pragma mark - action

- (IBAction)jsonDic:(id)sender {
    [self parseJSONFileDic];
}

- (IBAction)jsonArray:(id)sender {
    [self parseJSONFileArray];
}

@end
