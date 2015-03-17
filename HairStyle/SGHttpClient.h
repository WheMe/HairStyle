//
//  SGHttpClient.h
//  SingleBookShelf
//
//  Created by 孙苏军 on 15/3/10.
//  Copyright (c) 2015年 孙苏军. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import "SGBaseRequest.h"
@interface SGHttpClient : NSObject
+ (SGHttpClient *)shareInstance;


- (void)requestUrl:(NSString *)url param:(NSDictionary *)requestArgument baseUrl:(NSString *)baseUrl withRequestMethod:(SGRequestMethod)requestMethod withCompletionBlockWithSuccess:(void (^)(id content, id responseObject))success failure:(void (^)(id content, NSError *error))failure withTag:(NSInteger)tag;

- (void)addRequest:(SGBaseRequest *)request;
- (void)cancelRequest:(NSInteger)tag;
- (void)cancelAllRequests;

- (void)getPath:(NSString *)path parameters:(NSDictionary *)parameters success:(void (^)(id content, id responseObject))success failure:(void (^)(id content, NSError *error))failure;

@end
