//
//  MSBaseRequest.m
//  MSNetworkDemo
//
//  Created by 魏欣宇 on 2019/1/4.
//  Copyright © 2019 haochen. All rights reserved.
//

#define VALID_DICTIONARY(dict) ((dict) && ([(dict) isKindOfClass:[NSDictionary class]]) && ([(dict) count] > 0))

#import "MSBaseRequest.h"
#import <SVProgressHUD.h>
#import <AFNetworking.h>

NSString *const MSNetworkHost = @"https://api.wutonglife.com/life";

@interface MSBaseRequest ()

@property (nonatomic, copy) NSString *urlStr;
@property (nonatomic, assign) NSTimeInterval timeoutInterval;
@property (nonatomic, assign) NSInteger page;

@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;
@property (nonatomic, strong) NSURLSessionTask *requestTask;

@end

@implementation MSBaseRequest

#pragma mark - Life Cycle
- (instancetype)init
{
    if (self = [super init])
    {
        [self initHttpSessionManager];
    }
    return self;
}

#pragma mark - Public Cycle
- (instancetype)initWithSuccess:(MSRequestSuccessBlcok)successBlock
                        failure:(MSRequestFailureBlock)failureBlock
{
    if (self = [self init])
    {
        self.successBlock = successBlock;
        self.failureBlock = failureBlock;
        self.uploadProgressBlock = nil;
    }
    return self;
}

+ (instancetype)requestWithSuccess:(MSRequestSuccessBlcok)successBlock
                           failure:(MSRequestFailureBlock)failureBlock
{
    return [[[self class] alloc] initWithSuccess:successBlock failure:failureBlock];
}

- (void)uploadTaskWithSuccess:(MSRequestSuccessBlcok)successBlock
                      failure:(MSRequestFailureBlock)failureBlock
{
    self.successBlock = successBlock;
    self.failureBlock = failureBlock;
    self.uploadProgressBlock = nil;
}

- (void)uploadTaskWithSuccess:(MSRequestSuccessBlcok)successBlock
                      failure:(MSRequestFailureBlock)failureBlock
               uploadProgress:(AFURLSessionTaskProgressBlock)uploadProgressBlock
{
    self.successBlock = successBlock;
    self.failureBlock = failureBlock;
    self.uploadProgressBlock = uploadProgressBlock;
}

- (void)startRequest
{
    //网络判断
    AFNetworkReachabilityManager *reachabilityManager = [AFNetworkReachabilityManager sharedManager];
    [reachabilityManager startMonitoring];
    [reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (status != AFNetworkReachabilityStatusNotReachable)
        {
            [self constructURL];
            [self constructSessionTask];
            
            if (self.showHUD)
            {
                [SVProgressHUD show];
            }
        }
        else
        {
            [SVProgressHUD showErrorWithStatus:@"当前无可用的网络"];
        }
    }];
}

- (NSDictionary *)requestParameters
{
    return nil;
}

- (NSString *)requestURLPath
{
    return nil;
}

- (MSRequestMethod)requestMethod
{
    return MSRequestMethodPOST;
}

- (MSRequestSerializerType)requestSerializerType
{
    return MSRequestSerializerTypeJSON;
}

- (MSResponseSerializerType)responseSerializerType
{
    return MSResponseSerializerTypeJSON;
}

- (NSDictionary<NSString *,NSString *> *)requestHeaderFieldDictionary
{
    return nil;
}

- (AFConstructingBodyBlock)constructingBodyBlock
{
    return nil;
}

- (void)handleData:(id)data errorCode:(NSInteger)errorCode
{
    NSAssert([self isMemberOfClass:[MSBaseRequest class]], @"子类必须实现[handleData:data errCode:errCode]");
}

- (void)cancelRequest
{
    if (self.sessionManager.tasks.count > 0)
    {
        [self.sessionManager.tasks makeObjectsPerformSelector:@selector(cancel)];
    }
}

#pragma mark - Private Cycle
- (void)initHttpSessionManager
{
    self.page = -1;
    self.showHUD = NO;
    self.timeoutInterval = 10.0;
    
    
    if (!self.sessionManager)
    {
        self.sessionManager = [AFHTTPSessionManager manager];
    }
    
    self.sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
    self.sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json", @"text/html", nil];
}

- (void)constructURL
{
    self.urlStr = [NSString stringWithFormat:@"%@%@", MSNetworkHost, [self requestURLPath]];
}

- (void)constructSessionTask
{
    NSError *__autoreleasing requestSerializationError = nil;
    
    self.requestTask = [self sessionTaskWithError:&requestSerializationError];
    [self.requestTask resume];
}

- (NSURLSessionTask *)sessionTaskWithError:(NSError *__autoreleasing *)error
{
    MSRequestMethod method = [self requestMethod];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:[self requestParameters]];
    
    AFConstructingBodyBlock constructingBodyBlock = [self constructingBodyBlock];
    AFHTTPRequestSerializer *requestSerializer = [self requestSerializer];
    
    switch (method) {
        case MSRequestMethodGET:
            return [self dataTaskWithHttpMethod:@"GET"
                              requestSerializer:requestSerializer
                                         URLStr:self.urlStr
                                     parameters:params
                                 uploadProgress:nil
                               downloadProgress:nil
                      constructingBodyWithBlock:nil error:error];
            break;
        case MSRequestMethodPOST:
            return [self dataTaskWithHttpMethod:@"POST"
                              requestSerializer:requestSerializer
                                         URLStr:self.urlStr
                                     parameters:params
                                 uploadProgress:self.uploadProgressBlock
                               downloadProgress:nil
                      constructingBodyWithBlock:constructingBodyBlock error:error];
            break;
            
        default:
            break;
    }
}

- (AFHTTPRequestSerializer *)requestSerializer
{
    AFHTTPRequestSerializer *requestSerializer = nil;
    switch ([self requestSerializerType]) {
        case MSRequestSerializerTypeHTTP:
            requestSerializer = [AFHTTPRequestSerializer serializer];
            break;
        case MSRequestSerializerTypeJSON:
            requestSerializer = [AFJSONRequestSerializer serializer];
            break;
    }
    
    requestSerializer.timeoutInterval = [self requestTimeoutInterval];
    requestSerializer.allowsCellularAccess = [self allowsCellularAccess];
    
    NSDictionary <NSString *, NSString *> *headerFieldDict = [self requestHeaderFieldDictionary];
    if (headerFieldDict != nil)
    {
        for (NSString *key in headerFieldDict.allKeys)
        {
            NSString *value = headerFieldDict[key];
            [requestSerializer setValue:value forHTTPHeaderField:key];
        }
    }
    
    return requestSerializer;
}

- (NSTimeInterval)requestTimeoutInterval
{
    return _timeoutInterval;
}

- (BOOL)allowsCellularAccess
{
    return YES;
}

- (NSURLSessionTask *)dataTaskWithHttpMethod:(NSString *)method
                           requestSerializer:(AFHTTPRequestSerializer *)requestSerializer
                                      URLStr:(NSString *)urlStr
                                  parameters:(id)params
                              uploadProgress:(nullable void (^)(NSProgress *uploadProgress))uploadProgress
                            downloadProgress:(nullable void (^)(NSProgress *downloadProgress))downloadProgress
                   constructingBodyWithBlock:(nullable void (^)(id <AFMultipartFormData>formData))block
                                       error:(NSError * _Nullable __autoreleasing *)error

{
    NSMutableURLRequest *request = nil;
    
    if (block)
    {
        request = [requestSerializer multipartFormRequestWithMethod:method
                                                          URLString:urlStr
                                                         parameters:params
                                          constructingBodyWithBlock:block
                                                              error:error];
    }
    else
    {
        request = [requestSerializer requestWithMethod:method
                                             URLString:urlStr
                                            parameters:params
                                                 error:error];
    }
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    __block NSURLSessionDataTask *dataTask = nil;
    dataTask = [self.sessionManager dataTaskWithRequest:request
                                         uploadProgress:uploadProgress
                                       downloadProgress:downloadProgress
                                      completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                                          [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                          [self handleRequestResult:dataTask
                                                           response:response
                                                     responseObject:responseObject
                                                              error:error];
                                      }];
    
    return dataTask;
}

- (void)handleRequestResult:(NSURLSessionDataTask *)dataTask
                   response:(NSURLResponse *)response
             responseObject:(id)responseObject
                      error:(NSError *)error
{
    if (error)
    {
        NSString *errorStr = error.localizedFailureReason;
        NSLog(@"+++ %@ +++ %@ +++", error, errorStr);
        
        if (error.code == -1011)
        {
            NSData *data = [error.userInfo objectForKey:@"com.alamofire.serialization.response.error.data"];
            errorStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"+++ %@ +++ %@ +++", data, errorStr);
        }
        
        self.showHUD = YES;
        if (self.failureBlock)
        {
            self.failureBlock(error);
        }
        
        if (self.isShowHUD)
        {
            [SVProgressHUD showErrorWithStatus:@"网络连接错误"];
        }
        else
        {
            [SVProgressHUD dismiss];
        }
        self.showHUD = NO;
    }
    else
    {
        id json = [self preHandleData:responseObject error:error];
        if (json)
        {
            if ([json isKindOfClass:[NSString class]])
            {
                BOOL showStatus = YES;
                if (showStatus)
                {
                    [SVProgressHUD showErrorWithStatus:json];
                    self.showHUD = NO;
                }
            }
            else
            {
                NSDictionary *jsonDict = (NSDictionary *)json;
                id resultData = [jsonDict objectForKey:@"data"];
                NSInteger errorCode = [[jsonDict objectForKey:@"error"] integerValue];
                NSLog(@"+++ jsonData: %@ +++", jsonDict);
                if (resultData)
                {
                    [self handleData:resultData
                           errorCode:errorCode];
                }
                else
                {
                    NSLog(@"+++ 服务器返回数据为null +++");
                }
            }
        }
        
        if (self.isShowHUD)
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
            });
            self.showHUD = NO;
        }
    }
    
    [self clearCompletionBlock];
}

- (id)preHandleData:(id)data error:(NSError *)error
{
    if (error)
    {
        return error.localizedFailureReason;
    }
    
    NSDictionary *jsonDict = (NSDictionary *)data;
    NSInteger errorCode = [[jsonDict objectForKey:@"error"] integerValue];
    if (errorCode == 0)
    {
        NSDictionary *resultData = [jsonDict objectForKey:@"data"];
        if (VALID_DICTIONARY(resultData))
        {
            NSInteger page = [[resultData objectForKey:@"page"] integerValue];
            NSInteger total = [[resultData objectForKey:@"total"] integerValue];
            NSInteger rowsperpage = [[resultData objectForKey:@"rowsperpage"] integerValue];
            if (page * rowsperpage < total)
            {
                self.page = page + 1;
                [self startRequest];
            }
        }
        return jsonDict;
    }
    else if (errorCode == 1002)
    {
        return jsonDict;
    }
    else
    {
        return jsonDict;
    }
}

- (void)clearCompletionBlock
{
    self.successBlock = nil;
    self.failureBlock = nil;
}



@end
