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

#define TIMELINE    @"demo_data/weibo_timeline.json"
#define USER        @"demo_data/weibo_usershow.json"

@interface ViewController ()

@property (nonatomic, strong) NSMutableArray *dataList;
@property (nonatomic, strong) NSMutableDictionary *userDictionary;

@end

@implementation ViewController

- (void)dealloc
{
    [self.dataList cancelRequest];
    [self.userDictionary cancelRequest];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.dataList = [NSMutableArray array];
    self.userDictionary = [NSMutableDictionary dictionary];
    
    //setup ObjectManager
    [CUObjectManager sharedInstance].baseURLString = @"http://112.124.107.63/";
    
    [[CUObjectManager sharedInstance] registerMapper:[Status getObjectMapping]
                                        atServerPath:TIMELINE
                                         andJSONPath:@"statuses"];
    
    [[CUObjectManager sharedInstance] registerMapper:[User getObjectMapping]
                                        atServerPath:USER
                                         andJSONPath:@""];
    
    [self fetchList];
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
    [self.dataList fetchObjectsFromPath:TIMELINE
                             parameters:nil
                                success:^(NSArray *array) {
                                    NSLog(@"%@", array);
                                } error:^(int statusCode, NSString *responseString) {
                                    NSLog(@"%@", self.dataList.errorMessage);
                                }];
     
    [self.userDictionary fetchDataFromPath:USER
                                parameters:nil
                                   success:^(NSDictionary *dictionary) {
                                       NSLog(@"%@", dictionary);
                                   } error:^(int statusCode, NSString *responseString) {
                                       NSLog(@"error");
                                   }];
}

#pragma mark - action

- (IBAction)jsonDic:(id)sender {
    [self parseJSONFileDic];
}

- (IBAction)jsonArray:(id)sender {
    [self parseJSONFileArray];
}

@end
