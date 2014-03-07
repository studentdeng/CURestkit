//
//  NSMutableDictionary+CURestKit.m
//  Pods
//
//  Created by curer on 3/7/14.
//
//

#import "objc/runtime.h"
#import "CURestkit.h"
#import "NSMutableDictionary+CURestKit.h"

static char requestKey;
static char requestErrorKey;

@implementation NSMutableDictionary (CURestKit)

- (void)fetchDataFromPath:(NSString *)path
               parameters:(NSDictionary *)parameters
                  success:(void (^)(NSDictionary *dictionary))successBlock
                    error:(void (^)(int statusCode, NSString *responseString))errorBlock
{
    __block __weak NSMutableDictionary *wself = self;
    
    [self cancelRequest];
    
    ASIHTTPRequest *request = [[CUObjectManager sharedInstance] getJSONRequestAtPath:path
                                                                          parameters:parameters
                                                                             success:^(ASIHTTPRequest *ASIRequest, id json) {
                                                                                 
                                                                                 if (![json isKindOfClass:[NSDictionary class]]) {
                                                                                     
                                                                                     [wself setupErrorMessage:@"json Data is not NSArray"];
                                                                                     
                                                                                     errorBlock(ASIRequest.responseStatusCode, ASIRequest.responseString);
                                                                                     
                                                                                     return;
                                                                                 }
                                                                                 
                                                                                 [wself removeAllObjects];
                                                                                 [wself addEntriesFromDictionary:json];
                                                                                 
                                                                                 successBlock(self);
                                                                                 
                                                                             } error:^(ASIHTTPRequest *ASIRequest, NSString *errorMsg) {
                                                                                 
                                                                                 [wself setupErrorMessage:errorMsg];
                                                                                 
                                                                                 errorBlock(ASIRequest.responseStatusCode, ASIRequest.responseString);
                                                                             }];
    
    objc_setAssociatedObject(self, &requestKey, request, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [request startAsynchronous];
}

- (void)postDataFromPath:(NSString *)path
              parameters:(NSDictionary *)parameters
                 success:(void (^)(NSDictionary *dictionary))successBlock
                   error:(void (^)(int statusCode, NSString *responseString))errorBlock
{
    [self cancelRequest];
    
    __block __weak NSMutableDictionary *wself = self;
    
    ASIHTTPRequest *request = [[CUObjectManager sharedInstance] postJSONRequestAtPath:path
                                                                           parameters:parameters
                                                                              success:^(ASIHTTPRequest *ASIRequest, id json) {
                                                                                  if (![json isKindOfClass:[NSDictionary class]]) {
                                                                                      
                                                                                      [wself setupErrorMessage:@"json Data is not NSArray"];
                                                                                      
                                                                                      errorBlock(ASIRequest.responseStatusCode, ASIRequest.responseString);
                                                                                      
                                                                                      return;
                                                                                  }
                                                                                  
                                                                                  [wself removeAllObjects];
                                                                                  [wself addEntriesFromDictionary:json];
                                                                                  
                                                                                  successBlock(self);
                                                                                  
                                                                              } error:^(ASIHTTPRequest *ASIRequest, NSString *errorMsg) {
                                                                                  [wself setupErrorMessage:errorMsg];
                                                                                  
                                                                                  errorBlock(ASIRequest.responseStatusCode, ASIRequest.responseString);
                                                                              }];
    
    objc_setAssociatedObject(self, &requestKey, request, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [request startAsynchronous];
}

- (void)postDataFromPath:(NSString *)path
               userBlock:(void (^)(ASIFormDataRequest *ASIRequest))postBlock
                 success:(void (^)(NSDictionary *dictionary))successBlock
                   error:(void (^)(int statusCode, NSString *responseString))errorBlock
{
    [self cancelRequest];
    
    __block __weak NSMutableDictionary *wself = self;
    
    ASIHTTPRequest *request = [[CUObjectManager sharedInstance] postJSONRequestAtPath:path
                                                                            userBlock:postBlock
                                                                              success:^(ASIHTTPRequest *ASIRequest, id json) {
                                                                                  if (![json isKindOfClass:[NSDictionary class]]) {
                                                                                      
                                                                                      [wself setupErrorMessage:@"json Data is not NSArray"];
                                                                                      
                                                                                      errorBlock(ASIRequest.responseStatusCode, ASIRequest.responseString);
                                                                                      
                                                                                      return;
                                                                                  }
                                                                                  
                                                                                  [wself removeAllObjects];
                                                                                  [wself addEntriesFromDictionary:json];
                                                                                  
                                                                                  successBlock(self);
                                                                            } error:^(ASIHTTPRequest *ASIRequest, NSString *errorMsg) {
                                                                                [wself setupErrorMessage:errorMsg];
                                                                                
                                                                                errorBlock(ASIRequest.responseStatusCode, ASIRequest.responseString);
                                                                            }];
    
    objc_setAssociatedObject(self, &requestKey, request, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [request startAsynchronous];
}

- (void)cancelRequest
{
    ASIHTTPRequest *request = objc_getAssociatedObject(self, &requestKey);
    if (request)
    {
        [request clearDelegatesAndCancel];
        objc_setAssociatedObject(self, &requestKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    [self clearError];
}

- (void)clearError
{
    NSString *errorString = [self errorMessage];
    if (errorString)
    {
        objc_setAssociatedObject(self, &requestErrorKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (void)setupErrorMessage:(NSString *)errorMessage
{
    [self clearError];
    
    objc_setAssociatedObject(self, &requestErrorKey, errorMessage, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)errorMessage
{
    return objc_getAssociatedObject(self, &requestErrorKey);
}

@end

