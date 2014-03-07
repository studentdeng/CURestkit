//
//  NSMutableArray+CURestKit.h
//  Pods
//
//  Created by curer on 3/7/14.
//
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (CURestKit)

//GET
- (void)fetchObjectsFromPath:(NSString *)path
                  parameters:(NSDictionary *)parameters
                     success:(void (^)(NSArray *array))successBlock
                       error:(void (^)(int statusCode, NSString *responseString))errorBlock;

- (void)cancelRequest;

- (NSString *)errorMessage;

@end
