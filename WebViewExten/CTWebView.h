//
//  CTWebView.h
//
//  Created by frank on 12-12-19.
//  Copyright (c) 2012年 . All rights reserved.
//

#import <UIKit/UIKit.h>

@class CTInvokedCommand;
@class CTPlugin;

/**
 * webView扩展代理类
 */
@protocol CTWebViewDelegate<UIWebViewDelegate>

@optional

/**
 * 在此返回需要在页面Onload前调用的JS
 */
- (NSString *)webViewOnloadShouldBegin:(UIWebView *)webView;

@end

/**
 * JS和原生互调基础WebView类
 */
@interface CTWebView : UIWebView
<UIAlertViewDelegate>
{
    BOOL _gobackOrForward;
    
    // 重写WebView的Alert时需要的参数
    UIAlertView *_ctConfirmView;
    BOOL _diagStat;
    BOOL _alertIsShow;
}

@property (nonatomic, assign) id<CTWebViewDelegate> delegate;
/**
 * webView所在的视图控制器
 * 必传参数
 */
@property (nonatomic, assign) UIViewController *viewController;

#pragma mark - Public methods

/**
 * 使用主线程调用JS方法
 */
- (void)evaluatingJavaScriptOnMain:(NSString *)script;

/**
 * 调用js并获取结果；
 */
- (id)evaluateJavaScriptAutoCall:(NSString *)script;

/**
 * 获取接口调用实例
 * pluginName 接口对象名称
 * 实例不存在或创建错误时返回nil
 */
- (CTPlugin *)getCommandInstance:(NSString*)pluginName errorStr:(NSString **)errorStr;

/**
 * 执行有返回值的方法
 */
- (id)execute:(CTInvokedCommand *)command;

/**
 * 执行没有返回值的方法；该方法在主线程执行
 */
- (void)execVoidCmd:(CTInvokedCommand *)command;

/**
 * 转换输入的对象为字符串JS对象内容
 * 字符串会在外层添加双引号如：@"abc"=>@"\"abc\""
 * NSDictionary或NSArray为字符串json对象
 * NSNumber 返回字符串的数字，其它类型都返回@""
 */
- (NSString *)convertStringJSObject:(id)object;

@end
