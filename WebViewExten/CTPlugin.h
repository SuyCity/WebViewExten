//
//  CTPlugin.h
//
//  Created by frank on 13-9-4.
//  Copyright (c) 2013年 . All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CTInvokedCommand.h"

@class CTWebView;

/**
 * 所有插件类的基类
 */
@interface CTPlugin : NSObject

@property (nonatomic, weak) CTWebView *webView;
@property (nonatomic, weak) UIViewController *viewController;

@end

/*
 插件类例子
@interface Test : CTPlugin

- (NSString *)getName:(CTInvokedCommand *)command;

- (void)showName:(CTInvokedCommand *)command;

@end

JS调用例子:
 
 // 有返回值时使用execCmd
 alert(ctsCmd.execCmd("Test","getName","[]"));
 
 // 没返回值的必须使用execVoidCmd
 ctsCmd.execVoidCmd("Test","showName","[]");
 
*/