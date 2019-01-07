//
//  MSRequestCallback.h
//  MSNetworkDemo
//
//  Created by 魏欣宇 on 2019/1/4.
//  Copyright © 2019 haochen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MSBaseRequest;

@protocol AFMultipartFormData;

typedef void(^AFConstructingBodyBlock)(id<AFMultipartFormData> data);
typedef void(^AFURLSessionTaskProgressBlock)(NSProgress *progress);

typedef void(^MSRequestSuccessBlcok)(NSInteger errorCode, NSDictionary *responseDict, id model);
typedef void(^MSRequestFailureBlock)(NSError *error);
