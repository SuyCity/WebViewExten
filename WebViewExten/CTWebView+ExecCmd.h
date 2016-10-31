//
//  CTWebView+ExecCmd.h
//
//  Created by frank on 13-8-31.
//  Copyright (c) 2013年 . All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class CTWebView;

/**
 * JS调用原生方法命令类
 */
@interface CTWebView_ExecCmd : NSObject

@property (nonatomic, weak) UIViewController *viewController;
@property (nonatomic, weak) CTWebView *webView;

#pragma mark - Public methods

/**
 * 输出调试信息；可使用类别扩展该方法使用自定义日志输出
 * msg 要输出的内容
 */
- (void)log:(NSString *)msg;

/**
 * 执行没有返回结果的内容；该方法会在主线程调用
 * className 字符串类名
 * methodName 字符串方法名
 * args 字符串数组参数
 */
- (void)execVoidCmd:(NSString *)className methodName:(NSString *)methodName args:(NSString *)args;

/**
 * 执行有返回结果的内容；该方法会在浏览器线程调用
 * className 字符串类名
 * methodName 字符串方法名
 * args 字符串数组参数
 */
- (NSString *)execCmd:(NSString *)className methodName:(NSString *)methodName args:(NSString *)args;

@end
