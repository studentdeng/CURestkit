//
//  CUObjectManager.h
//  CURestkitExample
//
//  Created by yg curer on 13-2-12.
//  Copyright (c) 2013年 curer. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AFHTTPClient;
@class AFJSONRequestOperation;
@class CUJSONMapper;
@interface CUObjectManager : NSObject

- (void)getObjectsAtPath:(NSString *)path
              parameters:(NSDictionary *)parameters
                 success:(void (^)(AFJSONRequestOperation *jsonOperation, NSArray *objects))success
                   error:(void (^)(AFJSONRequestOperation *jsonOperation, NSString *errorMsg))errorBlock;

- (void)getLocalObjectsAt:(NSString *)path
               parameters:(NSDictionary *)parameters
                  success:(void (^)(AFJSONRequestOperation *operation, NSArray *objects))success
                    error:(void (^)(AFJSONRequestOperation *jsonOperation, NSString *errorMsg))errorBlock;

- (void)registerMapper:(CUJSONMapper *)mapper
          atServerPath:(NSString *)serverPath
           andJSONPath:(NSString *)jsonPath;

/*
                 success:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success
                 failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure;
*/

@property (nonatomic, retain, readwrite) AFHTTPClient *HTTPClient;


@end
