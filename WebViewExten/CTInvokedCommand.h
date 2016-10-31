//
//  CTInvokedCommand.h
//
//  Created by frank on 13-8-31.
//  Copyright (c) 2013年 . All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    CTStatusCodeOK = 1101, // 接口调用成功
    CTStatusCodeClassNotfound = 1102, // 调用对象不存在
    CTStatusCodeMethodNotFound = 1103, // 调用方法不存在
    CTStatusCodeIllegalArgument = 1104, // 参数不合法
} CTStatusCode;

/**
 * 所有JS调用方法，统一参数
 */
@interface CTInvokedCommand : NSObject

/**
 * 页面提交的参数数组
 */
@property (nonatomic, strong, readonly) NSArray *arguments;
/**
 * 页面提交的JSON字符串数组
 */
@property (nonatomic, strong, readonly) NSString *strArguments;
/**
 * 调用的类名
 */
@property (nonatomic, strong, readonly) NSString *className;
/**
 * 调用的方法名
 */
@property (nonatomic, strong, readonly) NSString *methodName;

/**
 * 初始化调用命令
 */
- (id)initWithArguments:(NSString *)strArguments arguments:(NSArray *)arguments className:(NSString*)classNam methodName:(NSString*)methodName;

/**
 * 获取参数数组的内容；数组没有这个内容或为Null时返回nil
 * index 参数内容在数组的索引
 */
- (id)argumentAtIndex:(NSUInteger)index;

/**
 * 获取参数数组的内容
 * index 参数内容在数组的索引
 * defaultValue 数组没有这个内容或为NULL时返回defaultValue
 */
- (id)argumentAtIndex:(NSUInteger)index withDefault:(id)defaultValue;

/**
 * 获取参数数组的内容
 * index 参数内容在数组的索引
 * defaultValue 数组没有这个内容或为NULL或类型不一样时返回时返回defaultValue
 * aClass 这个参数的对象类型；如NSNumber NSString 之类
 */
- (id)argumentAtIndex:(NSUInteger)index withDefault:(id)defaultValue andClass:(Class)aClass;

/**
 * 检查参数数组的内容类型并返回错误日志，只要匹配到有类型错误就停止继续匹配；类型为[NSNull class]不作检查
 * types 类型数组，如：[[NSString class], [NSNumber class]]
 * 返回值: nil 类型都正确，NSString 参数类型错误描述
 */
- (NSString *)checkParamType:(NSArray *)types;

/**
 * 获取统一接口调用错误内容
 */
- (NSString *)getErrorStr:(CTStatusCode)statusCode msg:(NSString *)msg;

@end
