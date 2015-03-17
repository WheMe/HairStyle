//
//  SGHttpClient.m
//  SingleBookShelf
//
//  Created by 孙苏军 on 15/3/10.
//  Copyright (c) 2015年 孙苏军. All rights reserved.
//

#import "SGHttpClient.h"

@interface SGHttpClient()
@property (nonatomic,strong)AFHTTPRequestOperationManager *requestManager;
@property (nonatomic,strong)NSMutableDictionary *requestsRecord;
@end

@implementation SGHttpClient
+ (SGHttpClient *)shareInstance{
    static SGHttpClient *shareSGHttpClient = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        shareSGHttpClient = [[self alloc] init];
    });
    return shareSGHttpClient;
}

- (id)init{
    self = [super init];
    if (self) {
        _requestManager = [AFHTTPRequestOperationManager manager];
        _requestManager.responseSerializer = [AFHTTPResponseSerializer serializer];
        _requestsRecord = [NSMutableDictionary dictionary];
        _requestManager.operationQueue.maxConcurrentOperationCount = 4;
    }
    return self;
}


//- (void)getPath:(NSString *)path parameters:(NSDictionary *)parameters success:(void (^)(id, id))success failure:(void (^)(id, NSError *))failure{
//    //1..检查网络连接(苹果公司提供的检查网络的第三方库 Reachability)
//    //AFN 在 Reachability基础上做了一个自己的网络检查的库, 基本上一样
////    设置请求格式
//    [SGHttpClient shareInstance].requestManager.requestSerializer = [AFJSONRequestSerializer serializer];
//    
////    设置返回格式
//    [SGHttpClient shareInstance].requestManager.responseSerializer = [AFHTTPResponseSerializer serializer];
//    
////    设置baseURL
//    
//    [[SGHttpClient shareInstance].requestManager GET:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        success(operation,responseObject);
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        failure(operation,error);
//    }];
//    
//}

- (void)addRequest:(SGBaseRequest *)request
{
    SGRequestMethod method = request.requestMethod;
    NSString * url = [NSString stringWithFormat:@"%@%@",request.baseUrl,request.requestUrl];
    NSDictionary * param = request.requestParam;
    if (request.requestSerializerType == SGRequestSerializerTypeHTTP) {
        _requestManager.requestSerializer = [AFHTTPRequestSerializer serializer];
    }else if (request.requestSerializerType == SGRequestSerializerTypeJSON) {
        _requestManager.requestSerializer = [AFJSONRequestSerializer serializer];
    }
    if (method == SGRequestMethodGet) {
        request.requestOperation = [_requestManager GET:url parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self handleRequestResult:operation responseObject:responseObject error:nil];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self handleRequestResult:operation responseObject:nil error:error];
        }];
    }else if (method == SGRequestMethodPost) {
        request.requestOperation = [_requestManager POST:url parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self handleRequestResult:operation responseObject:responseObject error:nil];
        }                                 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self handleRequestResult:operation responseObject:nil error:error];
        }];
    }
    [self addOperation:request];
}

- (void)handleRequestResult:(AFHTTPRequestOperation *)operation responseObject:(id)responseObject error:(NSError *)error{
    NSLog(@"responseObject == %@",responseObject);
    NSString * key = [self requestHashKey:operation];
    SGBaseRequest *request = _requestsRecord[key];
    if (request) {
        BOOL succeed = [self checkResult:request];
        if (succeed) {
            if (request.successCompletionBlock) {
                request.successCompletionBlock(request,responseObject);
            }
        }else {
            if (request.failureCompletionBlock) {
                request.failureCompletionBlock(request,error);
            }
        }
    }
    [self removeOperation:operation];
    [request clearCompletionBlock];
}

- (BOOL)checkResult:(SGBaseRequest *)request
{
    BOOL result = [request statusCodeValidator];
    return result;
}

- (void)addOperation:(SGBaseRequest *)request {
    if (request.requestOperation != nil) {
        NSString * key = [self requestHashKey:request.requestOperation];
        _requestsRecord[key] = request;
    }
}

- (NSString *)requestHashKey:(AFHTTPRequestOperation *)operation
{
    NSString *key = [NSString stringWithFormat:@"%lu", (unsigned long)[operation hash]];
    return key;
}

- (void)removeOperation:(AFHTTPRequestOperation *)operation {
    NSString * key = [self requestHashKey:operation];
    [_requestsRecord removeObjectForKey:key];
}

- (void)requestUrl:(NSString *)url param:(NSDictionary *)requestArgument baseUrl:(NSString *)baseUrl withRequestMethod:(SGRequestMethod)requestMethod withCompletionBlockWithSuccess:(void (^)(id, id))success failure:(void (^)(id, NSError *))failure withTag:(NSInteger)tag
{
    SGBaseRequest * base = [[SGBaseRequest alloc] init];
    base.baseUrl = baseUrl;
    base.requestUrl = url;
    base.tag = tag;
    base.requestParam = requestArgument;
    base.requestMethod = requestMethod;
    base.successCompletionBlock = success;
    base.failureCompletionBlock = failure;
    base.requestSerializerType = SGRequestSerializerTypeHTTP;
    [self addRequest:base];
}

- (void)cancelRequest:(NSInteger)tag {
    NSDictionary *copyRecord = [_requestsRecord copy];
    for (NSString *key in copyRecord) {
        SGBaseRequest *request = copyRecord[key];
        if (request.tag == tag) {
            [request.requestOperation cancel];
            [self removeOperation:request.requestOperation];
            [request clearCompletionBlock];
        }
    }
}
- (void)cancelAllRequests {
    NSDictionary *copyRecord = [_requestsRecord copy];
    for (NSString *key in copyRecord) {
        SGBaseRequest *request = copyRecord[key];
        [request stop];
    }
}

@end
