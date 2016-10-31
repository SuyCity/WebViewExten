//
//  Test.m
//  WebViewExtenTest
//
//  Created by FanFrank on 16/10/31.
//  Copyright © 2016年 com.frankfan. All rights reserved.
//

#import "Test.h"

@implementation Test

- (NSString *)getName:(CTInvokedCommand *)command {
    return @"Mark!";
}

- (void)showName:(CTInvokedCommand *)command {
    NSString *name = [command argumentAtIndex:0 withDefault:@"None Name" andClass:[NSString class]];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:name delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [alert show];
}

@end
