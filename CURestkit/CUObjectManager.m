//
//  CUObjectManager.m
//  CURestkitExample
//
//  Created by yg curer on 13-2-12.
//  Copyright (c) 2013年 curer. All rights reserved.
//

#import "CUObjectManager.h"
#import "CUJSONMapper.h"
#import "AFNetworking.h"
#import "JSON.h"

@interface CUObjectManager ()

@property (nonatomic, retain) NSMutableDictionary *mapperAtServerPathDictionary;
@property (nonatomic, retain) NSMutableDictionary *jsonPathAtServerPathDictionary;

@end

@implementation CUObjectManager

- (void)dealloc
{
    self.HTTPClient = nil;
    self.mapperAtServerPathDictionary = nil;
    self.jsonPathAtServerPathDictionary = nil;
    
    [super dealloc];
}

- (id)init
{
    if (self = [super init]) {
        self.mapperAtServerPathDictionary = [NSMutableDictionary dictionary];
        self.jsonPathAtServerPathDictionary = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (void)registerMapper:(CUJSONMapper *)mapper
          atServerPath:(NSString *)serverPath
           andJSONPath:(NSString *)jsonPath
{
    [self.mapperAtServerPathDictionary setObject:mapper forKey:serverPath];
    [self.jsonPathAtServerPathDictionary setObject:jsonPath forKey:serverPath];
}

- (void)getObjectsAtPath:(NSString *)path
              parameters:(NSDictionary *)parameters
                 success:(void (^)(AFJSONRequestOperation *jsonOperation, NSArray *objects))success
                   error:(void (^)(AFJSONRequestOperation *jsonOperation, NSString *errorMsg))errorBlock
{
    NSMutableURLRequest *
    request = [self.HTTPClient requestWithMethod:@"GET" path:path parameters:parameters];
    
    __block CUObjectManager *blockSelf = self;
    
    AFJSONRequestOperation *operation = nil;
    operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                success:^(NSURLRequest *request,
                                                                          NSHTTPURLResponse *response,
                                                                          id jsonObject)
    {
        id objects = [CUObjectManager parseObjects:blockSelf withJSON:jsonObject at:path];
        if (objects != nil) {
            success(operation, objects);
        }
        else
        {
            errorBlock(operation, @"parse error");
        }
    }
                                                    failure:^(NSURLRequest *request,
                                                              NSHTTPURLResponse *response,
                                                              NSError *error,
                                                              id JSON)
    {
        errorBlock(operation, [error localizedDescription]);
    }];
    
    
    [self.HTTPClient enqueueHTTPRequestOperation:operation];
    [operation start];
}

- (void)getLocalObjectsAt:(NSString *)path
               parameters:(NSDictionary *)parameters
                  success:(void (^)(AFJSONRequestOperation *operation, NSArray *objects))success
                    error:(void (^)(AFJSONRequestOperation *jsonOperation, NSString *errorMsg))errorBlock
{
    NSMutableURLRequest *
    request = [self.HTTPClient requestWithMethod:@"GET" path:path parameters:parameters];
    
    [request setCachePolicy:NSURLRequestReturnCacheDataDontLoad];
}

+ (NSArray *)parseObjects:(CUObjectManager *)objectManager withJSON:(id)jsonObject at:(NSString *)path
{
    NSString *targetJSONPath = [objectManager.jsonPathAtServerPathDictionary objectForKey:path];
    if ([targetJSONPath length] > 0) {
        jsonObject = [jsonObject valueForKeyPath:targetJSONPath];
    }
    
    CUJSONMapper *mapper = [objectManager.mapperAtServerPathDictionary objectForKey:path];
    if (mapper == nil)
    {
        return nil;
    }
    
    id objects = nil;
    if ([jsonObject isKindOfClass:[NSArray class]]) {
        objects = [mapper objectfromJSONArray:(NSArray *)jsonObject];
    }
    else
    {
        NSLog(@"");
    }
    
    return objects;
}

@end
