//
//  SGBaseRequest.m
//  SingleBookShelf
//
//  Created by 孙苏军 on 15/3/12.
//  Copyright (c) 2015年 孙苏军. All rights reserved.
//

#import "SGBaseRequest.h"
#import "SGHttpClient.h"
@implementation SGBaseRequest

- (NSString *)responseString{
    return self.requestOperation.responseString;
}

- (BOOL)statusCodeValidator{
    NSInteger statusCode = [self responseStatusCode];
    if (statusCode >= 200 && statusCode <= 299) {
        return YES;
    }else {
        return NO;
    }
}
- (NSInteger)responseStatusCode{
    return self.requestOperation.response.statusCode;
}

- (void)clearCompletionBlock
{
    self.successCompletionBlock = nil;
    self.failureCompletionBlock = nil;
}
- (void)stop {
    [[SGHttpClient shareInstance] cancelRequest:self.tag];
}
@end
