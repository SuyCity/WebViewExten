//
//  CTWebView.m
//
//  Created by frank on 12-12-19.
//  Copyright (c) 2012年 . All rights reserved.
//

#import "CTWebView.h"
#import <objc/runtime.h>
#import "CTWebView+ExecCmd.h"
#import "CTPlugin.h"

/**
 * 获取本地化字符串；当Localizable.strings没有定义这个key且comment不为空返回comment
 */
#define CTLocalizedString(key, comment) \
([[[NSBundle mainBundle] localizedStringForKey:key value:key table:nil] isEqualToString:key] && comment !=nil ? comment : [[NSBundle mainBundle] localizedStringForKey:key value:key table:nil])

@class WebFrame;

@interface CTWebView()
{
}

@property (nonatomic, strong) CTWebView_ExecCmd *execCmd;
@property (nonatomic, strong) NSMutableDictionary *pluginObjects;
@property (nonatomic, readonly) id windowScriptObject;

- (void)addScriptObject:(id)windowObject;

@end

@implementation CTWebView

@synthesize viewController = _viewController;
@synthesize windowScriptObject = _windowScriptObject;
@synthesize delegate = _delegate;
@synthesize execCmd = _execCmd;
@synthesize pluginObjects = _pluginObjects;

- (void)dealloc
{
    self.viewController = nil;
    _windowScriptObject = nil;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    // 加快webView滚动速度
    UIScrollView *sv = (UIScrollView *)[[self subviews] objectAtIndex:0];
    if ([sv isKindOfClass:[UIScrollView class]])
    {
        [sv setDecelerationRate:UIScrollViewDecelerationRateNormal];
    }
}

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        // 加快webView滚动速度
        UIScrollView *sv = (UIScrollView *)[[self subviews] objectAtIndex:0];
        if ([sv isKindOfClass:[UIScrollView class]])
        {
            [sv setDecelerationRate:UIScrollViewDecelerationRateNormal];
        }
    }
    
    return self;
}

#pragma mark - GetOrSet

- (void)setDelegate:(id<CTWebViewDelegate>)delegate
{
    _delegate = delegate;
    [super setDelegate:delegate];
}

- (CTWebView_ExecCmd *)execCmd
{
    if (_execCmd == nil)
    {
        _execCmd = [[CTWebView_ExecCmd alloc] init];
        _execCmd.webView = self;
        _execCmd.viewController = _viewController;
    }
    return _execCmd;
}

- (NSMutableDictionary *)pluginObjects
{
    if (_pluginObjects == nil)
    {
        _pluginObjects = [NSMutableDictionary dictionary];
    }
    
    return _pluginObjects;
}

#pragma mark - Private methods

- (void)addScriptObject:(id)windowObject
{
    [windowObject setValue:self.execCmd forKey:@"ctsCmd"];
    
    if ([self.delegate respondsToSelector:@selector(webViewOnloadShouldBegin:)])
    {
        NSString *js = [(id<CTWebViewDelegate>)self.delegate webViewOnloadShouldBegin:self];
        if (js)
        {
            [self stringByEvaluatingJavaScriptFromString:js];
        }
    }
    
    // 使用脚本监听JS错误
    [self stringByEvaluatingJavaScriptFromString:@"window.onerror = function (desc,page,line) {ctsCmd.log('sourceURL=' + page + '\\nline=' + line +'\\nexception=' + desc);}"];
}

// 注册插件
- (void)registerPlugin:(CTPlugin *)plugin withClassName:(NSString*)className
{
    if ([plugin respondsToSelector:@selector(setViewController:)])
    {
        [plugin setViewController:self.viewController];
    }
    
    if ([plugin respondsToSelector:@selector(setWebView:)])
    {
        [plugin setWebView:self];
    }
    
    [self.pluginObjects setObject:plugin forKey:className];
}

/**
 * 创建接口调用实例
 */
- (CTPlugin *)getCommandInstance:(NSString*)pluginName errorStr:(NSString **)errorStr
{
    // 根据className获取pluginsMap对应的对象名；注:pluginName不区分大小写
    NSString *className = pluginName;
    
    id obj = [self.pluginObjects objectForKey:className];
    if (!obj)
    {
        obj = [[NSClassFromString(className) alloc] init];
        
        if (obj != nil)
        {
            [self registerPlugin:obj withClassName:className];
        }
        else
        {
            *errorStr = [NSString stringWithFormat:@"iOS平台不存在插件名为：%@的CTPlugin class %@；请检查你项目是否存在该插件！", pluginName, className];
        }
    }
    return obj;
}

#pragma mark - Public methods

- (void)goBack
{
    [super goBack];
    if ([self canGoBack])
    {
        _gobackOrForward = YES;
    }
}

- (void)goForward
{
    [super goForward];
    if ([self canGoForward])
    {
        _gobackOrForward = YES;
    }
}

- (void)webViewMainFrameDidFinishLoad:(id)sender
{
    if (_gobackOrForward)
    {
        _gobackOrForward = NO;
        [self addScriptObject:_windowScriptObject];
    }
}

- (void)webView:(id)sender didClearWindowObject:(id)windowObject forFrame:(WebFrame*)frame
{
    _windowScriptObject = windowObject;
    [self addScriptObject:windowObject];
}

- (void)evaluatingJavaScriptOnMain:(NSString *)script
{
    [self performSelectorOnMainThread:@selector(stringByEvaluatingJavaScriptFromString:) withObject:script waitUntilDone:NO];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
- (id)evaluateJavaScriptOnWindowObject:(NSString *)script
{
    if ([_windowScriptObject respondsToSelector:NSSelectorFromString(@"evaluateWebScript:")])
        return [_windowScriptObject performSelector:NSSelectorFromString(@"evaluateWebScript:") withObject:script];
    return nil;
}
#pragma clang diagnostic pop

- (id)evaluateJavaScriptAutoCall:(NSString *)script
{
    if ([NSThread isMainThread])
        return [self stringByEvaluatingJavaScriptFromString:script];
    return [self evaluateJavaScriptOnWindowObject:script];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

- (id)executeCommon:(CTInvokedCommand *)command returnValue:(BOOL)returnValue;
{
    NSString *errorStr = nil;
    CTStatusCode errorCode = CTStatusCodeOK;
    
    CTPlugin *obj = [self getCommandInstance:command.className errorStr:&errorStr];
    if (obj != nil)
    {
        NSString *methodName = [NSString stringWithFormat:@"%@:", command.methodName];
        SEL normalSelector = NSSelectorFromString(methodName);
        
        if ([obj respondsToSelector:normalSelector])
        {
            if (returnValue)
            {
                return [obj performSelector:normalSelector withObject:command];
            }
            else
            {
                [obj performSelector:normalSelector withObject:command];
                return nil;
            }
        }
        else
        {
            errorCode = CTStatusCodeMethodNotFound;
            errorStr = @"请检查你调的方法名称是否正确或联系接口开发人员确认该接口方法";
        }
    }
    else
    {
        errorCode = CTStatusCodeClassNotfound;
    }
    
    [self.execCmd log:[command getErrorStr:errorCode msg:[NSString stringWithFormat:@"%@\nsourceURL=%@", errorStr,  self.request.URL.absoluteString]]];
    
    return nil;
}
#pragma clang diagnostic pop

// 执行接口命令
- (id)execute:(CTInvokedCommand *)command
{
    return [self executeCommon:command returnValue:YES];
}

- (void)execVoidCommandCmd:(CTInvokedCommand *)command
{
    [self executeCommon:command returnValue:NO];
}

- (void)execVoidCmd:(CTInvokedCommand *)command
{
    [self performSelectorOnMainThread:@selector(execVoidCommandCmd:) withObject:command waitUntilDone:NO];
}

- (NSString *)convertStringJSObject:(id)object
{
    if ([object isKindOfClass:[NSDictionary class]] || [object isKindOfClass:[NSArray class]])
    {
        NSError *error = nil;
        NSString* jsonString = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:object options:0 error:nil] encoding:NSUTF8StringEncoding];
        if (error)
        {
            [self.execCmd log:[NSString stringWithFormat:@"对象转成JSON字符串失败，%@", error]];
        }
        return jsonString;
    }
    
    if ([object isKindOfClass:[NSString class]])
    {
        object = [object stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
        return [NSString stringWithFormat:@"\"%@\"", object];
    }
    
    if ([object isKindOfClass:[NSNumber class]])
    {
        return [NSString stringWithFormat:@"%@", object];
    }
    
    return @"";
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([[self superclass] instancesRespondToSelector:@selector(scrollViewDidScroll:)])
    {
        [super scrollViewDidScroll:scrollView];
    }
    if ([_viewController respondsToSelector:@selector(scrollViewDidScroll:)])
    {
        [(id)_viewController scrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if ([[self superclass] instancesRespondToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)])
    {
        [super scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
    if ([_viewController respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)])
    {
        [(id)_viewController scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ([[self superclass] instancesRespondToSelector:@selector(scrollViewWillBeginDragging:)])
    {
        [super scrollViewWillBeginDragging:scrollView];
    }
    if ([_viewController respondsToSelector:@selector(scrollViewWillBeginDragging:)])
    {
        [(id)_viewController scrollViewWillBeginDragging:scrollView];
    }
}

@end
