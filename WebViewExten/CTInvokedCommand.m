//
//  CTInvokedCommand.m
//
//  Created by frank on 13-8-31.
//  Copyright (c) 2013年 . All rights reserved.
//

#import "CTInvokedCommand.h"

@implementation CTInvokedCommand

@synthesize arguments = _arguments;
@synthesize strArguments = _strArguments;
@synthesize className = _className;
@synthesize methodName = _methodName;

- (id)initWithArguments:(NSString *)strArguments arguments:(NSArray *)arguments className:(NSString*)className methodName:(NSString*)methodName
{
    if ((self = [super init]))
    {
        _strArguments = strArguments;
        _arguments = arguments;
        _className = className;
        _methodName = methodName;
    }
    return self;
}

- (id)argumentAtIndex:(NSUInteger)index
{
    return [self argumentAtIndex:index withDefault:nil];
}

- (id)argumentAtIndex:(NSUInteger)index withDefault:(id)defaultValue
{
    return [self argumentAtIndex:index withDefault:defaultValue andClass:nil];
}

- (id)argumentAtIndex:(NSUInteger)index withDefault:(id)defaultValue andClass:(Class)aClass
{
    if (index >= [_arguments count]) {
        return defaultValue;
    }
    id ret = [_arguments objectAtIndex:index];
    if (ret == [NSNull null]) {
        ret = defaultValue;
    }
    if ((aClass != nil) && ![ret isKindOfClass:aClass]) {
        ret = defaultValue;
    }
    return ret;
}

- (NSString *)checkParamType:(NSArray *)types
{
    int i = -1;
    for (Class classes in types)
    {
        ++i;
        if (classes == [NSNull class])
            continue;
        if ([self argumentAtIndex:i withDefault:nil andClass:classes] == nil)
        {
            return [self getErrorStr:CTStatusCodeIllegalArgument msg:[NSString stringWithFormat:@"第%d个参数类型不是%@\n输入的参数为：%@", i + 1, classes, _strArguments]];
        }
    }
    
    return nil;
}

- (NSString *)deStatusCode:(CTStatusCode)statusCode
{
    switch (statusCode)
    {
        case CTStatusCodeClassNotfound:
            return @"ClassNotfound";
            break;
        case CTStatusCodeMethodNotFound:
            return @"MethodNotFound";
            break;
        case CTStatusCodeIllegalArgument:
            return @"IllegalArgument";
            break;
        default:
            break;
    }
    return nil;
}

- (NSString *)getErrorStr:(CTStatusCode)statusCode msg:(NSString *)msg
{
    return [NSString stringWithFormat:@"调用接口className=%@；methodName=%@错误：%@；errorMsg=%@", _className, _methodName, [self deStatusCode:statusCode], msg];
}

@end
