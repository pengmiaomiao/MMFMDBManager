//
//  NSObject+MMRunTimeManager.m
//  FMDB增删查改
//
//  Created by John on 16/4/5.
//  Copyright © 2016年 John.peng. All rights reserved.
//

#import "NSObject+MMRunTimeManager.h"
#import <objc/runtime.h>
#import <objc/message.h>

@implementation NSObject (MMRunTimeManager)
#pragma mark - 获取所有属性
-(NSArray *)getAllProperties:(MMBlock)block{
    NSMutableArray *array = [NSMutableArray new];
    unsigned int coutCount = 0;
    objc_property_t *properties = class_copyPropertyList(self.class, &coutCount);
    for (int i = 0; i<coutCount; i++) {
        objc_property_t property = properties[i];
        const char *propertyName = property_getName(property);
        const char *propertyAttributes = property_getAttributes(property);
        NSLog(@"propertyName:%s  propertyAttributes:%s",propertyName,propertyAttributes);
        NSString *key = [NSString stringWithUTF8String:propertyName];
        NSString *keyAttributes = [NSString stringWithUTF8String:propertyAttributes];
        // 继承于NSObject的类都会有这几个在NSObject中的属性
        if ([key isEqualToString:@"description"]
            || [key isEqualToString:@"debugDescription"]
            || [key isEqualToString:@"hash"]
            || [key isEqualToString:@"superclass"]) {
            continue;
        }
        if (block) {
            block(key,keyAttributes);
        }
        [array addObject:@[key,keyAttributes]];
    }
    free(properties);
    return array;
}
+(NSArray *)getClassAllProperties:(MMBlock)block{
    NSMutableArray *array = [NSMutableArray new];
    unsigned int coutCount = 0;
    objc_property_t *properties = class_copyPropertyList(self, &coutCount);
    for (int i = 0; i<coutCount; i++) {
        objc_property_t property = properties[i];
        const char *propertyName = property_getName(property);
        const char *propertyAttributes = property_getAttributes(property);
        NSLog(@"propertyName:%s  propertyAttributes:%s",propertyName,propertyAttributes);
        NSString *key = [NSString stringWithUTF8String:propertyName];
        NSString *keyAttributes = [NSString stringWithUTF8String:propertyAttributes];
        // 继承于NSObject的类都会有这几个在NSObject中的属性
        if ([key isEqualToString:@"description"]
            || [key isEqualToString:@"debugDescription"]
            || [key isEqualToString:@"hash"]
            || [key isEqualToString:@"superclass"]) {
            continue;
        }
        if (block) {
            block(key,keyAttributes);
        }
        [array addObject:@[key,keyAttributes]];
    }
    free(properties);
    return array;
}
#pragma mark - 访问成员变量
-(NSArray *)getAllMemberVariables:(MMBlock)block{
    NSMutableArray *array = [NSMutableArray new];
    unsigned int outCount = 0;
    Ivar *ivars = class_copyIvarList(self.class, &outCount);
    for (int i = 0; i< outCount; i++) {
        Ivar ivar = ivars[i];
        const char *name = ivar_getName(ivar);
        const char *type = ivar_getTypeEncoding(ivar);
        NSLog(@"name: %s encodeType: %s", name, type);
        NSString *key = [NSString stringWithUTF8String:name];
        NSString *keyAttributes = [NSString stringWithUTF8String:type];
        if (block) {
            block(key,keyAttributes);
        }
        [array addObject:@[key,keyAttributes]];
    }
    free(ivars);
    return array;
}
#pragma mark - 给属性赋值
-(void)setPropertyWithSEL:(SEL)setter forValue:(id)value{
//    第一种方法
    /*
    if ([self respondsToSelector:sel]) {
        ///2.3 把值通过setter方法赋值给实体类的属性
        [self performSelectorOnMainThread:sel
                               withObject:value
                            waitUntilDone:[NSThread isMainThread]];
    }
    */
//    第二种方法
    if (setter != nil) {
        ((void(*)(id,SEL,id))objc_msgSend)(self,setter,value);
    }
}
#pragma mark - 获取属性的值
-(id)getPropertyWithName:(NSString *)name{
    SEL getter = [self propertyGetterWithKey:name];
    if (getter != nil) {
        //            获取方法签名
        NSMethodSignature *signature = [self methodSignatureForSelector:getter];
        //            根据方法签名获取NSInvocation对象
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
        //            设置target
        [invocation setTarget:self];
        //            设置selector
        [invocation setSelector:getter];
        //            方法调用
        [invocation invoke];
        //            接收返回值
        __unsafe_unretained NSObject *propertyValue = nil;
        [invocation getReturnValue:&propertyValue];
        
        if (propertyValue == nil) {
            NSLog(@"获取失败：%@",name);
        }
        NSLog(@"%@",propertyValue);
        return propertyValue;
    }
    return nil;
}
#pragma mark - 生成setter方法
-(SEL)propertySetterWithKey:(NSString *)key{
    NSString *propertySetter = [key stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[key substringToIndex:1] uppercaseString]];//首字母大写
    propertySetter = [NSString stringWithFormat:@"set%@:",propertySetter];
    SEL setter = NSSelectorFromString(propertySetter);
    if ([self respondsToSelector:setter]) {
        return setter;
    }
    return nil;
}
#pragma mark - 生成getter方法
-(SEL)propertyGetterWithKey:(NSString *)key{
    if (key != nil) {
        SEL getter = NSSelectorFromString(key);
        if ([self respondsToSelector:getter]) {
            return getter;
        }
    }
    return nil;
}
#pragma mark - 正则匹配
-(BOOL)predicateWithMatches:(NSString *)matches forString:(NSString *)string{
    // 创建谓词对象并设定条件的表达式
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", matches];
    // 对字符串进行判断
    if ([predicate evaluateWithObject:string]) {
        return YES;
    }
    return NO;
}
@end
