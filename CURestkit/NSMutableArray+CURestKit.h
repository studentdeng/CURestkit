//
//  NSMutableArray+CURestKit.h
//  Pods
//
//  Created by curer on 3/7/14.
//
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (CURestKit)

- (void)fetchDataFromPath:(NSString *)path
                  success:(void (^)(void))successBlock
                    error:(void (^)(int statusCode, NSString *responseString))errorBlock;

- (void)cancelRequest;

@end
