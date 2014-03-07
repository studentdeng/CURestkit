//
//  NSMutableDictionary+CURestKit.h
//  Pods
//
//  Created by curer on 3/7/14.
//
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (CURestKit)

//GET
- (void)fetchDataFromPath:(NSString *)path
               parameters:(NSDictionary *)parameters
                  success:(void (^)(NSDictionary *dictionary))successBlock
                    error:(void (^)(int statusCode, NSString *responseString))errorBlock;

//POST
- (void)postDataFromPath:(NSString *)path
              parameters:(NSDictionary *)parameters
                 success:(void (^)(NSDictionary *dictionary))successBlock
                   error:(void (^)(int statusCode, NSString *responseString))errorBlock;

//POST
- (void)postDataFromPath:(NSString *)path
               userBlock:(void (^)(ASIFormDataRequest *ASIRequest))postBlock
                 success:(void (^)(NSDictionary *dictionary))successBlock
                   error:(void (^)(int statusCode, NSString *responseString))errorBlock;

- (void)cancelRequest;

- (NSString *)errorMessage;

@end
