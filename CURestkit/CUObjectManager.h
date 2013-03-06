//
//  CUObjectManager.h
//  CURestkitExample
//
//  Created by yg curer on 13-2-12.
//  Copyright (c) 2013年 curer. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ASIHTTPRequest;
@class ASIFormDataRequest;
@class CUJSONMapper;
@interface CUObjectManager : NSObject

@property (nonatomic, retain) NSString *baseURLString;
@property (nonatomic, retain) NSString *HTTPBasicAuthUsername;
@property (nonatomic, retain) NSString *HTTPBasicAuthPassword;

- (void)registerMapper:(CUJSONMapper *)mapper
          atServerPath:(NSString *)serverPath
           andJSONPath:(NSString *)jsonPath;

- (void)getObjectsAtPath:(NSString *)path
              parameters:(NSDictionary *)parameters
                 success:(void (^)(ASIHTTPRequest *ASIRequest, NSArray *objects))success
                   error:(void (^)(ASIHTTPRequest *ASIRequest, NSString *errorMsg))errorBlock;

- (void)getLocalObjectsAt:(NSString *)path
               parameters:(NSDictionary *)parameters
                  success:(void (^)(ASIHTTPRequest *ASIRequest, NSArray *objects))success
                    error:(void (^)(ASIHTTPRequest *ASIRequest, NSString *errorMsg))errorBlock;

- (void)post:(NSString *)path
   userBlock:(void (^)(ASIFormDataRequest *ASIRequest))postBlock
     success:(void (^)(ASIHTTPRequest *ASIRequest, NSDictionary *object))success
       error:(void (^)(ASIHTTPRequest *ASIRequest, NSString *errorMsg))errorBlock;

- (void)getResponseAtPath:(NSString *)path
               parameters:(NSDictionary *)parameters
                  success:(void (^)(ASIHTTPRequest *ASIRequest, id json))success
                    error:(void (^)(ASIHTTPRequest *ASIRequest, NSString *errorMsg))errorBlock;

- (void)cancelAllRequest;
- (void)cancelRequestURLString:(NSString *)urlString;
- (void)cancelRequestAtPath:(NSString *)path;
- (void)iteratorRequestUseBlock:(void (^)(ASIHTTPRequest *ASIRequest, BOOL *bCancel))block;

+ (NSString *)serializeBaseURL:(NSString *)baseURL path:(NSString *)path params:(NSDictionary *)params;

@end
