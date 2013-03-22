//
//  CUObjectManager.m
//  CURestkitExample
//
//  Created by yg curer on 13-2-12.
//  Copyright (c) 2013年 curer. All rights reserved.
//

#import "CUObjectManager.h"
#import "CUJSONMapper.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "JSON.h"
#import "ASIDownloadCache.h"

#define HTTP_STATUS_CODE_FAILED     @"httpcodefailed"
#define PARSE_JSON_FAILED     @"parse json failed"

@implementation NSString (CUObjectManager)

- (NSString *)URLEncodedString
{
	return [self URLEncodedStringWithCFStringEncoding:kCFStringEncodingUTF8];
}

- (NSString *)URLEncodedStringWithCFStringEncoding:(CFStringEncoding)encoding
{
	return [(NSString *) CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)[[self mutableCopy] autorelease], NULL, CFSTR("￼=,!$&'()*+;@?\n\"<>#\t :/"), encoding) autorelease];
}

@end

@interface CUObjectManager ()

@property (nonatomic, retain) NSMutableDictionary *mapperAtServerPathDictionary;
@property (nonatomic, retain) NSMutableDictionary *jsonPathAtServerPathDictionary;
@property (nonatomic, retain) NSMutableDictionary *requestDictionary;

@end

@implementation CUObjectManager

- (void)dealloc
{
    self.mapperAtServerPathDictionary = nil;
    self.jsonPathAtServerPathDictionary = nil;
    self.baseURLString = nil;
    
    [self cancelAllRequest];
    
    self.requestDictionary = nil;
    
    [super dealloc];
}

- (id)init
{
    if (self = [super init]) {
        self.mapperAtServerPathDictionary = [NSMutableDictionary dictionary];
        self.jsonPathAtServerPathDictionary = [NSMutableDictionary dictionary];
        self.requestDictionary = [NSMutableDictionary dictionary];
    }
    
    return self;
}

#pragma mark - public

- (void)registerMapper:(CUJSONMapper *)mapper
          atServerPath:(NSString *)serverPath
           andJSONPath:(NSString *)jsonPath
{
    [self.mapperAtServerPathDictionary setObject:mapper forKey:serverPath];
    [self.jsonPathAtServerPathDictionary setObject:jsonPath forKey:serverPath];
}

- (void)getObjectsAtPath:(NSString *)path
              parameters:(NSDictionary *)parameters
                 success:(void (^)(ASIHTTPRequest *ASIRequest, NSArray *objects))success
                   error:(void (^)(ASIHTTPRequest *ASIRequest, NSString *errorMsg))errorBlock;
{
    ASIHTTPRequest *request = [self requestWithPath:path
                                         parameters:parameters
                                            success:success
                                              error:errorBlock];
    
    [request setCachePolicy:ASIAskServerIfModifiedWhenStaleCachePolicy];
    [request setDownloadCache:[ASIDownloadCache sharedCache]];
    [request setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
    
    [request startAsynchronous];
}

- (void)getLocalObjectsAt:(NSString *)path
               parameters:(NSDictionary *)parameters
                  success:(void (^)(ASIHTTPRequest *ASIRequest, NSArray *objects))success
                    error:(void (^)(ASIHTTPRequest *ASIRequest, NSString *errorMsg))errorBlock;
{
    ASIHTTPRequest *request = [self requestWithPath:path
                                         parameters:parameters
                                            success:success
                                              error:errorBlock];
    
    [request setDownloadCache:[ASIDownloadCache sharedCache]];
    [request setCachePolicy:ASIOnlyLoadIfNotCachedCachePolicy | ASIFallbackToCacheIfLoadFailsCachePolicy];
    [request setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
    
    [request startAsynchronous];
}

- (void)getResponseAtPath:(NSString *)path
               parameters:(NSDictionary *)parameters
                  success:(void (^)(ASIHTTPRequest *ASIRequest, id json))success
                    error:(void (^)(ASIHTTPRequest *ASIRequest, NSString *errorMsg))errorBlock
{
    NSString *urlString = [CUObjectManager serializeBaseURL:self.baseURLString
                                                       path:path
                                                     params:parameters];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    [request addBasicAuthenticationHeaderWithUsername:self.HTTPBasicAuthUsername
                                          andPassword:self.HTTPBasicAuthPassword];
    
    __block CUObjectManager *blockSelf = self;
    
    [request setCompletionBlock:^{
        [blockSelf.requestDictionary removeObjectForKey:request.url];
        
        if (![blockSelf parseHTTPStatusCode:request]) {
            errorBlock(request, HTTP_STATUS_CODE_FAILED);
            
            return;
        }
        
        success(request, [request.responseString JSONValue]);
    }];
    
    [request setFailedBlock:^{
        [blockSelf.requestDictionary removeObjectForKey:request.url];
        
        errorBlock(request, [[request error] localizedDescription]);
    }];
    
    ASIHTTPRequest *requestInHistory = [blockSelf.requestDictionary objectForKey:request.url];
    if (requestInHistory != nil) {
        [requestInHistory clearDelegatesAndCancel];
        
        NSLog(@"cancel history request %@", request);
    }
    
    [blockSelf.requestDictionary setObject:request forKey:request.url];
    
    [request startAsynchronous];
}

- (void)post:(NSString *)path
   userBlock:(void (^)(ASIFormDataRequest *ASIRequest))postBlock
     success:(void (^)(ASIHTTPRequest *ASIRequest, NSDictionary *object))success
       error:(void (^)(ASIHTTPRequest *ASIRequest, NSString *errorMsg))errorBlock
{
    NSString *urlString = [CUObjectManager serializeBaseURL:self.baseURLString
                                                       path:path
                                                     params:nil];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    postBlock(request);
    
    [request addBasicAuthenticationHeaderWithUsername:self.HTTPBasicAuthUsername
                                          andPassword:self.HTTPBasicAuthPassword];
    
    __block CUObjectManager *blockSelf = self;
    
    [request setCompletionBlock:^{
        [blockSelf.requestDictionary removeObjectForKey:request.url];
        
        if (![blockSelf parseHTTPStatusCode:request]) {
            errorBlock(request, HTTP_STATUS_CODE_FAILED);
            
            return;
        }
        
        id jsonObject = [self JSONFromRequest:request];
        
        id object = [CUObjectManager parseObject:blockSelf withJSON:jsonObject at:path];
        if (object != nil) {
            success(request, object);
        }
        else
        {
            errorBlock(request, PARSE_JSON_FAILED);
        }
    }];
    
    [request setFailedBlock:^{
        [blockSelf.requestDictionary removeObjectForKey:request.url];
        
        errorBlock(request, [[request error] localizedDescription]);
    }];
    
    ASIHTTPRequest *requestInHistory = [blockSelf.requestDictionary objectForKey:request.url];
    if (requestInHistory != nil) {
        [requestInHistory clearDelegatesAndCancel];
        
        NSLog(@"cancel history request %@", request);
    }
    
    [blockSelf.requestDictionary setObject:request forKey:request.url];
    
    [request startAsynchronous];
}

- (void)cancelAllRequest
{
    [self.requestDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        ASIHTTPRequest *request = (ASIHTTPRequest *)obj;
        [request clearDelegatesAndCancel];
    }];
    
    [self.requestDictionary removeAllObjects];
}

- (void)cancelRequestAtPath:(NSString *)path
{
    [self iteratorRequestUseBlock:^(ASIHTTPRequest *ASIRequest, BOOL *bCancel) {
        NSString *url = [[ASIRequest url] absoluteString];
        
        if ([url hasPrefix:[NSString stringWithFormat:@"%@%@", self.baseURLString, path]]) {
            *bCancel = YES;
        }
    }];
}

- (void)cancelRequestURLString:(NSString *)urlString
{
    ASIHTTPRequest *request = [self.requestDictionary objectForKey:urlString];
    [request clearDelegatesAndCancel];
    
    [self.requestDictionary removeObjectForKey:request.url];
}

- (void)iteratorRequestUseBlock:(void (^)(ASIHTTPRequest *ASIRequest, BOOL *bCancel))block;
{
    [self.requestDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        ASIHTTPRequest *request = (ASIHTTPRequest *)obj;
        BOOL bCancel = NO;
        block(request, &bCancel);
        
        if (bCancel) {
            [request clearDelegatesAndCancel];
            [self.requestDictionary removeObjectForKey:request.url];
        }
    }];
}

#pragma mark - private

- (ASIHTTPRequest *)requestWithPath:(NSString *)path
                         parameters:(NSDictionary *)parameters
                            success:(void (^)(ASIHTTPRequest *ASIRequest, NSArray *objects))success
                              error:(void (^)(ASIHTTPRequest *ASIRequest, NSString *errorMsg))errorBlock
{
    NSString *urlString = [CUObjectManager serializeBaseURL:self.baseURLString
                                                       path:path
                                                     params:parameters];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    [request addBasicAuthenticationHeaderWithUsername:self.HTTPBasicAuthUsername
                                          andPassword:self.HTTPBasicAuthPassword];
    
    __block CUObjectManager *blockSelf = self;
    
    [request setCompletionBlock:^{
        [blockSelf.requestDictionary removeObjectForKey:request.url];
        
        if (![blockSelf parseHTTPStatusCode:request]) {
            errorBlock(request, HTTP_STATUS_CODE_FAILED);
            
            return;
        }
        
        id jsonObject = [self JSONFromRequest:request];
        
        id objects = [CUObjectManager parseObjects:blockSelf withJSON:jsonObject at:path];
        if (objects != nil) {
            success(request, objects);
        }
        else
        {
            errorBlock(request, PARSE_JSON_FAILED);
        }
    }];
    
    [request setFailedBlock:^{
        [blockSelf.requestDictionary removeObjectForKey:request.url];
        
        errorBlock(request, [[request error] localizedDescription]);
    }];
    
    ASIHTTPRequest *requestInHistory = [blockSelf.requestDictionary objectForKey:request.url];
    if (requestInHistory != nil) {
        [requestInHistory clearDelegatesAndCancel];
        
        NSLog(@"cancel history request %@", request);
    }
    
    [blockSelf.requestDictionary setObject:request forKey:request.url];
    
    return request;
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

+ (NSDictionary *)parseObject:(CUObjectManager *)objectManager withJSON:(id)jsonObject at:(NSString *)path
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
    if ([jsonObject isKindOfClass:[NSDictionary class]]) {
        objects = [mapper objectFromJSONDictionary:(NSDictionary *)jsonObject];
    }
    else
    {
        NSLog(@"");
    }
    
    return objects;
}

#pragma mark - parse server response

- (BOOL)parseHTTPStatusCode:(ASIHTTPRequest *)request
{
    if ([request responseStatusCode] == 200) {
        return YES;
    }
    
    return NO;
}

- (id)JSONFromRequest:(ASIHTTPRequest *)request
{
    NSString *response = [request responseString];
    id jsonObject = [response JSONValue];
    
    return jsonObject;
}

#pragma mark - URL schema

+ (NSString *)serializeBaseURL:(NSString *)baseURL path:(NSString *)path params:(NSDictionary *)params
{
    NSURL *parsedURL = [NSURL URLWithString:baseURL];
	NSString *queryPrefix = parsedURL.query ? @"&" : @"?";
	NSString *query = [self stringFromDictionary:params];
	
	return [NSString stringWithFormat:@"%@%@%@%@", baseURL, path, queryPrefix, query];
}

+ (NSString *)stringFromDictionary:(NSDictionary *)dict
{
    NSMutableArray *pairs = [NSMutableArray array];
	for (NSString *key in [dict keyEnumerator])
	{
        NSString *param = [dict objectForKey:key];
		if (!([param isKindOfClass:[NSString class]]))
		{
            param = [NSString stringWithFormat:@"%@", param];
		}

		[pairs addObject:[NSString stringWithFormat:@"%@=%@", key, [param URLEncodedString]]];
	}
	
	return [pairs componentsJoinedByString:@"&"];
}

@end
