//
//  NSObject+MMRunTimeManager.h
//  FMDB增删查改
//
//  Created by John on 16/4/5.
//  Copyright © 2016年 John.peng. All rights reserved.
//
#import <Foundation/Foundation.h>
typedef void(^MMBlock)(NSString *propertyName,NSString *propertyAttributes);
@interface NSObject (MMRunTimeManager)

-(NSArray *)getAllProperties:(MMBlock)block;
+(NSArray *)getClassAllProperties:(MMBlock)block;
-(NSArray *)getAllMemberVariables:(MMBlock)block;

-(id)getPropertyWithName:(NSString *)name;

-(void)setPropertyWithSEL:(SEL)setter forValue:(id)value;
-(SEL)propertySetterWithKey:(NSString *)key;
@end
