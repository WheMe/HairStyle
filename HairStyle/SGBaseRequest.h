//
//  SGBaseRequest.h
//  SingleBookShelf
//
//  Created by 孙苏军 on 15/3/12.
//  Copyright (c) 2015年 孙苏军. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

typedef NS_ENUM(NSInteger, SGRequestMethod) {
    SGRequestMethodGet = 0,
    SGRequestMethodPost,
};
typedef NS_ENUM(NSInteger, SGRequestSerializerType) {
    SGRequestSerializerTypeJSON = 0,
    SGRequestSerializerTypeHTTP,
};

@interface SGBaseRequest : NSObject

@property (nonatomic,strong)AFHTTPRequestOperation * requestOperation;
//HTTP请求的方法..
@property (nonatomic) SGRequestMethod requestMethod;

//请求的参数
@property (nonatomic, strong) NSDictionary * requestParam;

//服务器地址BaseUrl
@property (nonatomic, strong) NSString * baseUrl;

//请求的URL
@property (nonatomic, strong) NSString * requestUrl;

//返回的数据
@property (nonatomic, strong, readonly) NSString * responseString;

//请求的数据类型
@property (nonatomic) SGRequestSerializerType requestSerializerType;

//失败的回调
@property (nonatomic, copy) void (^failureCompletionBlock)(id,id);

//成功的回调
@property (nonatomic, copy) void (^successCompletionBlock)(id,id);

@property (nonatomic) NSInteger tag;

//状态码校验
- (BOOL)statusCodeValidator;

//把block置nil来打破循环引用
- (void)clearCompletionBlock;

- (void)stop;

@end
