//
//  Test.h
//  WebViewExtenTest
//
//  Created by FanFrank on 16/10/31.
//  Copyright © 2016年 com.frankfan. All rights reserved.
//

#import <WebViewExten/WebViewExten.h>

//插件类例子
@interface Test : CTPlugin

- (NSString *)getName:(CTInvokedCommand *)command;

- (void)showName:(CTInvokedCommand *)command;

@end
