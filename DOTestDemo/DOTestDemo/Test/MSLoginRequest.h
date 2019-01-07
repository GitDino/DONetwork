//
//  MSLoginRequest.h
//  DOTestDemo
//
//  Created by 魏欣宇 on 2019/1/7.
//  Copyright © 2019 haochen. All rights reserved.
//

#import "MSBaseRequest.h"

@interface MSLoginRequest : MSBaseRequest

@property (nonatomic, copy) NSString *tel;
@property (nonatomic, copy) NSString *verifycode;

@end
