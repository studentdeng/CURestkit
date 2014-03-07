//
//  NSMutableArray+CURestKit.m
//  Pods
//
//  Created by curer on 3/7/14.
//
//
#import "objc/runtime.h"
#import "NSMutableArray+CURestKit.h"
#import "CURestkit.h"

static char requestKey;
static char requestErrorKey;

@implementation NSMutableArray (CURestKit)

- (void)fetchDataFromPath:(NSString *)path
                  success:(void (^)(void))successBlock
                    error:(void (^)(int statusCode, NSString *responseString))errorBlock
{
    __block __weak typeof(self)selfWeak = self;
    
    [self cancelRequest];
    ASIHTTPRequest *request = [[CUObjectManager sharedInstance] getJSONRequestAtPath:path
                                                                          parameters:nil
                                                                             success:^(ASIHTTPRequest *ASIRequest, id json) {
                                                                                 
                                                                                 [selfWeak removeAllObjects];
                                                                                 
                                                                                 if (![json isKindOfClass:[NSArray class]]) {
                                                                                     
                                                                                     [selfWeak setupErrorMessage:@"json Data is not NSArray"];
                                                                                     
                                                                                     errorBlock(ASIRequest.responseStatusCode, ASIRequest.responseString);
                                                                                 }
                                                                                 
                                                                                 [selfWeak addObjectsFromArray:json];
                                                                                 
                                                                                 successBlock();
                                                                                 
                                                                             } error:^(ASIHTTPRequest *ASIRequest, NSString *errorMsg) {
                                                                                 
                                                                                 [selfWeak setupErrorMessage:errorMsg];
                                                                                 
                                                                                 errorBlock(ASIRequest.responseStatusCode, ASIRequest.responseString);
                                                                             }];
    
    objc_setAssociatedObject(self, &requestKey, request, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
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
    NSString *errorString = objc_getAssociatedObject(self, &requestErrorKey);
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



@end
