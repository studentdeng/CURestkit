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

@end

@implementation CUObjectManager

- (void)dealloc
{
    self.mapperAtServerPathDictionary = nil;
    self.jsonPathAtServerPathDictionary = nil;
    self.baseURLString = nil;
    
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

#pragma mark - public

- (void)registerMapper:(CUJSONMapper *)mapper
          atServerPath:(NSString *)serverPath
           andJSONPath:(NSString *)jsonPath
{
    [self.mapperAtServerPathDictionary setObject:mapper forKey:serverPath];
    [self.jsonPathAtServerPathDictionary setObject:jsonPath forKey:serverPath];
}

- (ASIHTTPRequest *)getObjectsRequestAtPath:(NSString *)path
                                 parameters:(NSDictionary *)parameters
                                    success:(void (^)(ASIHTTPRequest *ASIRequest, NSArray *objects))success
                                      error:(void (^)(ASIHTTPRequest *ASIRequest, NSString *errorMsg))errorBlock
{
    ASIHTTPRequest *request = [self requestWithPath:path
                                         parameters:parameters
                                            success:success
                                              error:errorBlock];
    
    [request setCachePolicy:ASIAskServerIfModifiedWhenStaleCachePolicy];
    [request setDownloadCache:[ASIDownloadCache sharedCache]];
    [request setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
    
    return request;
}

- (ASIHTTPRequest *)getLocalObjectsRequestAt:(NSString *)path
                                  parameters:(NSDictionary *)parameters
                                     success:(void (^)(ASIHTTPRequest *, NSArray *))success
                                       error:(void (^)(ASIHTTPRequest *, NSString *))errorBlock
{
    ASIHTTPRequest *request = [self requestWithPath:path
                                         parameters:parameters
                                            success:success
                                              error:errorBlock];
    
    [request setDownloadCache:[ASIDownloadCache sharedCache]];
    [request setCachePolicy:ASIOnlyLoadIfNotCachedCachePolicy | ASIFallbackToCacheIfLoadFailsCachePolicy];
    [request setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
    
    return request;
}

- (ASIHTTPRequest *)getJSONRequestAtPath:(NSString *)path
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
    
    [self setJSONResponseWithRequest:request
                             success:success
                               error:errorBlock];
    
    return request;
}

- (ASIHTTPRequest *)requestWithURL:(NSURL *)url
                        parameters:(NSDictionary *)parameters
                           success:(void (^)(ASIHTTPRequest *ASIRequest, id json))success
                             error:(void (^)(ASIHTTPRequest *ASIRequest, NSString *errorMsg))errorBlock
{
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
    [request addBasicAuthenticationHeaderWithUsername:self.HTTPBasicAuthUsername
                                          andPassword:self.HTTPBasicAuthPassword];
    
    [self setJSONResponseWithRequest:request
                             success:^(ASIHTTPRequest *ASIRequest, id json) {
                                 if (json != nil) {
                                     success(request, json);
                                 }
                                 else
                                 {
                                     errorBlock(request, PARSE_JSON_FAILED);
                                 }
                             } error:errorBlock];
    
    return request;
}

- (ASIHTTPRequest *)postJSONRequestAtPath:(NSString *)path
                                userBlock:(void (^)(ASIFormDataRequest *ASIRequest))postBlock
                                  success:(void (^)(ASIHTTPRequest *ASIRequest, id json))success
                                    error:(void (^)(ASIHTTPRequest *ASIRequest, NSString *errorMsg))errorBlock
{
    NSString *urlString = [CUObjectManager serializeBaseURL:self.baseURLString
                                                       path:path
                                                     params:nil];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:urlString]];
    [request addBasicAuthenticationHeaderWithUsername:self.HTTPBasicAuthUsername
                                          andPassword:self.HTTPBasicAuthPassword];
    postBlock(request);
    [self setJSONResponseWithRequest:request
                             success:success
                               error:errorBlock];
    
    return request;
}

- (ASIHTTPRequest *)postJSONRequestAtPath:(NSString *)path
                               parameters:(NSDictionary *)parameters
                                  success:(void (^)(ASIHTTPRequest *ASIRequest, id json))success
                                    error:(void (^)(ASIHTTPRequest *ASIRequest, NSString *errorMsg))errorBlock
{
    NSString *urlString = [CUObjectManager serializeBaseURL:self.baseURLString
                                                       path:path
                                                     params:nil];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:urlString]];
    [request addBasicAuthenticationHeaderWithUsername:self.HTTPBasicAuthUsername
                                          andPassword:self.HTTPBasicAuthPassword];
    
    for (NSString *key in parameters) {
        [request addPostValue:[parameters objectForKey:key] forKey:key];
    }
    
    [self setJSONResponseWithRequest:request
                             success:success
                               error:errorBlock];
    
    return request;
}

- (ASIHTTPRequest *)postRequestAtPath:(NSString *)path
                            userBlock:(void (^)(ASIFormDataRequest *ASIRequest))postBlock
                              success:(void (^)(ASIHTTPRequest *ASIRequest, id object))success
                                error:(void (^)(ASIHTTPRequest *ASIRequest, NSString *errorMsg))errorBlock
{
    NSString *urlString = [CUObjectManager serializeBaseURL:self.baseURLString
                                                       path:path
                                                     params:nil];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:urlString]];
    [request addBasicAuthenticationHeaderWithUsername:self.HTTPBasicAuthUsername
                                          andPassword:self.HTTPBasicAuthPassword];
    postBlock(request);
    
    __block CUObjectManager *blockSelf = self;
    [self setJSONResponseWithRequest:request
                             success:^(ASIHTTPRequest *ASIRequest, id json) {
                                 id object = [CUObjectManager parseObject:blockSelf withJSON:json at:path];
                                 if (object != nil) {
                                     success(request, object);
                                 }
                                 else
                                 {
                                     errorBlock(request, PARSE_JSON_FAILED);
                                 }
                             } error:errorBlock];
    
    return request;
}

- (ASIHTTPRequest *)postObjectRequestAtPath:(NSString *)path
                                 parameters:(NSDictionary *)parameters
                                    success:(void (^)(ASIHTTPRequest *ASIRequest, id object))success
                                      error:(void (^)(ASIHTTPRequest *ASIRequest, NSString *errorMsg))errorBlock
{
    NSString *urlString = [CUObjectManager serializeBaseURL:self.baseURLString
                                                       path:path
                                                     params:nil];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:urlString]];
    [request addBasicAuthenticationHeaderWithUsername:self.HTTPBasicAuthUsername
                                          andPassword:self.HTTPBasicAuthPassword];
    
    for (NSString *key in parameters) {
        [request addPostValue:[parameters objectForKey:key] forKey:key];
    }
    
    
    __block CUObjectManager *blockSelf = self;
    
    [self setJSONResponseWithRequest:request
                             success:^(ASIHTTPRequest *ASIRequest, id json) {
                                 id objects = [CUObjectManager parseObject:blockSelf withJSON:json at:path];
                                 if (objects != nil) {
                                     success(request, objects);
                                 }
                                 else
                                 {
                                     errorBlock(request, PARSE_JSON_FAILED);
                                 }
                             } error:errorBlock];
    
    return request;
}

#pragma mark - private

- (void)setJSONResponseWithRequest:(ASIHTTPRequest *)request
                           success:(void (^)(ASIHTTPRequest *ASIRequest, id json))success
                             error:(void (^)(ASIHTTPRequest *ASIRequest, NSString *errorMsg))errorBlock
{
    __block CUObjectManager *blockSelf = self;
    
    [request setCompletionBlock:^{
        if (![blockSelf parseHTTPStatusCode:request]) {
            NSLog(@"%@ %@", HTTP_STATUS_CODE_FAILED, [request responseString]);
            errorBlock(request, HTTP_STATUS_CODE_FAILED);
            
            return;
        }
        
        NSError *error = nil;
        id jsonObject = [NSJSONSerialization JSONObjectWithData:request.responseData
                                                        options:kNilOptions
                                                          error:&error];
        if (error == nil) {
            success(request, jsonObject);
        }
        else
        {
            errorBlock(request, PARSE_JSON_FAILED);
        }
    }];
    
    [request setFailedBlock:^{
        NSLog(@"%@", [[request error] localizedDescription]);
        errorBlock(request, [[request error] localizedDescription]);
    }];
}

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
    
    [self setJSONResponseWithRequest:request
                             success:^(ASIHTTPRequest *ASIRequest, id json) {
                                 id objects = [CUObjectManager parseObjects:blockSelf withJSON:json at:path];
                                 if (objects != nil) {
                                     success(request, objects);
                                 }
                                 else
                                 {
                                     errorBlock(request, PARSE_JSON_FAILED);
                                 }
                             } error:errorBlock];
    
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
        NSLog(@"can't find mapper");
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
