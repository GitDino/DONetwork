//
//  MSBaseRequest.h
//  MSNetworkDemo
//
//  Created by 魏欣宇 on 2019/1/4.
//  Copyright © 2019 haochen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MSRequestCallback.h"

extern NSString *const MSNetworkHost;

typedef NS_ENUM(NSInteger, MSRequestMethod) {
    MSRequestMethodGET = 0,
    MSRequestMethodPOST
};

typedef NS_ENUM(NSInteger, MSRequestSerializerType) {
    MSRequestSerializerTypeHTTP = 0,
    MSRequestSerializerTypeJSON
};

typedef NS_ENUM(NSInteger, MSResponseSerializerType) {
    MSResponseSerializerTypeHTTP = 0,
    MSResponseSerializerTypeJSON
};

@interface MSBaseRequest : NSObject

@property (nonatomic, assign, getter=isShowHUD) BOOL showHUD;

@property (nonatomic, copy) AFConstructingBodyBlock constructingBodyBlock;
@property (nonatomic, copy) AFURLSessionTaskProgressBlock uploadProgressBlock;

@property (nonatomic, copy) MSRequestSuccessBlcok successBlock;
@property (nonatomic, copy)  MSRequestFailureBlock failureBlock;

+ (instancetype)requestWithSuccess:(MSRequestSuccessBlcok)successBlock
                           failure:(MSRequestFailureBlock)failureBlock;
- (instancetype)initWithSuccess:(MSRequestSuccessBlcok)successBlock
                        failure:(MSRequestFailureBlock)failureBlock;


- (void)uploadTaskWithSuccess:(MSRequestSuccessBlcok)successBlock
                      failure:(MSRequestFailureBlock)failureBlock;
- (void)uploadTaskWithSuccess:(MSRequestSuccessBlcok)successBlock
                      failure:(MSRequestFailureBlock)failureBlock
               uploadProgress:(AFURLSessionTaskProgressBlock)uploadProgressBlock;


/**
 开始请求
 */
- (void)startRequest;

/**
 请求参数
 */
- (NSDictionary *)requestParameters;

/**
 请求路径
 */
- (NSString *)requestURLPath;

/**
 请求方式
 */
- (MSRequestMethod)requestMethod;

/**
 请求序列化方式
 */
- (MSRequestSerializerType)requestSerializerType;

/**
 响应序列化方式
 */
- (MSResponseSerializerType)responseSerializerType;

/**
 请求头
 */
- (NSDictionary<NSString *, NSString *> *)requestHeaderFieldDictionary;

/**
 数据处理
 */
- (void)handleData:(id)data
         errorCode:(NSInteger)errorCode;

/**
 取消请求
 */
- (void)cancelRequest;

@end
