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

+ (NSString *)serializeBaseURL:(NSString *)baseURL
                          path:(NSString *)path
                        params:(NSDictionary *)params;

- (ASIHTTPRequest *)getObjectsRequestAtPath:(NSString *)path
                                 parameters:(NSDictionary *)parameters
                                    success:(void (^)(ASIHTTPRequest *ASIRequest, NSArray *objects))success
                                      error:(void (^)(ASIHTTPRequest *ASIRequest, NSString *errorMsg))errorBlock;

- (ASIHTTPRequest *)getLocalObjectsRequestAt:(NSString *)path
                                  parameters:(NSDictionary *)parameters
                                     success:(void (^)(ASIHTTPRequest *ASIRequest, NSArray *objects))success
                                       error:(void (^)(ASIHTTPRequest *ASIRequest, NSString *errorMsg))errorBlock;

- (ASIHTTPRequest *)postRequestAtPath:(NSString *)path
                            userBlock:(void (^)(ASIFormDataRequest *ASIRequest))postBlock
                              success:(void (^)(ASIHTTPRequest *ASIRequest, id object))success
                                error:(void (^)(ASIHTTPRequest *ASIRequest, NSString *errorMsg))errorBlock;

- (ASIHTTPRequest *)getJSONRequestAtPath:(NSString *)path
                              parameters:(NSDictionary *)parameters
                                 success:(void (^)(ASIHTTPRequest *ASIRequest, id json))success
                                   error:(void (^)(ASIHTTPRequest *ASIRequest, NSString *errorMsg))errorBlock;

- (ASIHTTPRequest *)postJSONRequestAtPath:(NSString *)path
                                userBlock:(void (^)(ASIFormDataRequest *ASIRequest))postBlock
                                  success:(void (^)(ASIHTTPRequest *ASIRequest, id json))success
                                    error:(void (^)(ASIHTTPRequest *ASIRequest, NSString *errorMsg))errorBlock;

@end
