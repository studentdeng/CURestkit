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

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
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

#pragma mark - action

- (IBAction)jsonDic:(id)sender {
    [self parseJSONFileDic];
}

- (IBAction)jsonArray:(id)sender {
    [self parseJSONFileArray];
}

@end
