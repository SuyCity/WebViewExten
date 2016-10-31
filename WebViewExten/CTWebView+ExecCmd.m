//
//  CTWebView+ExecCmd.m
//
//  Created by frank on 13-8-31.
//  Copyright (c) 2013年 . All rights reserved.
//

#import "CTWebView+ExecCmd.h"
#import "CTWebView.h"
#import "CTInvokedCommand.h"

@interface CTWebView_ExecCmd()

@property (nonatomic, strong) NSMutableDictionary *pluginsMap;

@end

@implementation CTWebView_ExecCmd

@synthesize pluginsMap = _pluginsMap;
@synthesize webView = _webView;
@synthesize viewController = _viewController;

- (void)dealloc
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    _webView = nil;
    _viewController = nil;
}

- (id)jsonValue:(NSString *)strJson error:(NSError **)error
{
    id result = [NSJSONSerialization JSONObjectWithData:[strJson dataUsingEncoding:NSUTF8StringEncoding] options:0 error:error];
    return result;
}

#pragma mark - Public methods

+ (BOOL)isSelectorExcludedFromWebScript:(SEL)sel
{
    // 全部方法都不排除
    return NO;
}

// 返回JS调用的函数名称
+ (NSString *)webScriptNameForSelector:(SEL)sel
{
    if (sel == @selector(log:))
        return @"log";
    if (sel == @selector(execVoidCmd:methodName:args:))
        return @"execVoidCmd";
    if (sel == @selector(execCmd:methodName:args:))
        return @"execCmd";
    return nil;
}

#pragma mark - JS call methods

- (void)log:(NSString *)msg
{
    NSLog(@"\n-------------------------WebDebugger Log:-------------------------\n%@\n------------------------------------------------------------------", msg);
}

- (void)execVoidCmd:(NSString *)className methodName:(NSString *)methodName args:(NSString *)args
{
    NSError *error = nil;
    CTInvokedCommand *command = [[CTInvokedCommand alloc] initWithArguments:args arguments:[self jsonValue:args error:&error] className:className methodName:methodName];
    
    if (error)
    {
        [self log:[command getErrorStr:CTStatusCodeIllegalArgument msg:[NSString stringWithFormat:@"JSON参数转成对象失败，%@", error]]];
    }
    
    [_webView execVoidCmd:command];
}

- (NSString *)execCmd:(NSString *)className methodName:(NSString *)methodName args:(NSString *)args
{
    NSError *error = nil;
    CTInvokedCommand *command = [[CTInvokedCommand alloc] initWithArguments:args arguments:[self jsonValue:args error:&error] className:className methodName:methodName];
    
    if (error)
    {
        [self log:[command getErrorStr:CTStatusCodeIllegalArgument msg:[NSString stringWithFormat:@"JSON参数转成对象失败，%@", error]]];
    }
    
    return [_webView execute:command];
}

@end
