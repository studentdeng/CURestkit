//
//  CUObjectManager.h
//  CURestkitExample
//
//  Created by yg curer on 13-2-12.
//  Copyright (c) 2013年 curer. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ASIHTTPRequest;
@class CUJSONMapper;
@interface CUObjectManager : NSObject

@property (nonatomic, retain) NSString *baseURLString;
@property (nonatomic, retain) NSString *HTTPBasicAuthUsername;
@property (nonatomic, retain) NSString *HTTPBasicAuthPassword;

- (void)getObjectsAtPath:(NSString *)path
              parameters:(NSDictionary *)parameters
                 success:(void (^)(ASIHTTPRequest *ASIRequest, NSArray *objects))success
                   error:(void (^)(ASIHTTPRequest *ASIRequest, NSString *errorMsg))errorBlock;

- (void)getLocalObjectsAt:(NSString *)path
               parameters:(NSDictionary *)parameters
                  success:(void (^)(ASIHTTPRequest *ASIRequest, NSArray *objects))success
                    error:(void (^)(ASIHTTPRequest *ASIRequest, NSString *errorMsg))errorBlock;

- (void)registerMapper:(CUJSONMapper *)mapper
          atServerPath:(NSString *)serverPath
           andJSONPath:(NSString *)jsonPath;

- (void)cancelAllRequest;
- (void)cancelRequestURLString:(NSString *)urlString;

@end
