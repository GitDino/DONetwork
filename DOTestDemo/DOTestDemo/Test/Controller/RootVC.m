//
//  RootVC.m
//  DOTestDemo
//
//  Created by 魏欣宇 on 2019/1/7.
//  Copyright © 2019 haochen. All rights reserved.
//

#import "RootVC.h"
#import "MSLoginRequest.h"

@interface RootVC ()

@end

@implementation RootVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 50, 50)];
    btn.layer.borderWidth = 1.0;
    btn.layer.borderColor = [UIColor redColor].CGColor;
    [btn setTitle:@"登录" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.view addSubview:btn];
    [btn addTarget:self action:@selector(onTapLoginAction) forControlEvents:UIControlEventTouchUpInside];
}

- (void)onTapLoginAction
{
    MSLoginRequest *loginRequest = [MSLoginRequest requestWithSuccess:^(NSInteger errorCode, NSDictionary *responseDict, id model) {
        NSLog(@"%@", responseDict);
    } failure:^(NSError *error) {
        NSLog(@"%@", error);
    }];
    loginRequest.showHUD = YES;
    loginRequest.tel = @"18767109654";
    loginRequest.verifycode = @"1234";
    [loginRequest startRequest];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
