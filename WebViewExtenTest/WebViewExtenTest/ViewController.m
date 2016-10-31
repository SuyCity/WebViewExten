//
//  ViewController.m
//  WebViewExtenTest
//
//  Created by FanFrank on 16/10/31.
//  Copyright © 2016年 com.frankfan. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self.webView setViewController:self];
    
    NSURL *fileUrl = [NSURL URLWithString:[[NSBundle mainBundle] pathForResource:@"index.html" ofType:nil]];
    [self.webView loadRequest:[NSURLRequest requestWithURL:fileUrl]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
