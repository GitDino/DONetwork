//
//  MSLoginRequest.m
//  DOTestDemo
//
//  Created by 魏欣宇 on 2019/1/7.
//  Copyright © 2019 haochen. All rights reserved.
//

#import "MSLoginRequest.h"
#import <MJExtension.h>

@implementation MSLoginRequest

- (NSString *)requestURLPath
{
    return @"/users/loginRegister";
}

- (NSDictionary *)requestParameters
{
    return @{
             @"tel": _tel,
             @"verifycode": _verifycode
             };
}

- (void)handleData:(id)data errorCode:(NSInteger)errorCode
{
    NSDictionary *dict = (NSDictionary *)data;
    NSLog(@"%@", dict);
}

@end
