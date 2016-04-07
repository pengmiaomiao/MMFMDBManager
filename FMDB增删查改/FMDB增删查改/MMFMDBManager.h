//
//  FMDBManager.h
//  FMDB增删查改
//
//  Created by John on 16/4/5.
//  Copyright © 2016年 John.peng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MMFMDBManager : NSObject
+(instancetype)sharedInstance;
/**
 *  创建表格
 */
-(void)createrTableWithName:(NSString *)name forObject:(id)object;
/**
 *  曾
 */
-(void)insertDataForObject:(id)object;
/**
 *  改
 */
-(void)updataForObject:(id)object forPropretyName:(NSString *)name;
/**
 *  删
 */
-(void)deleteDataForObject:(id)object forPropretyName:(NSString *)name;
/**
 *  查
 */
-(void)selectTableAllDataWithClassName:(NSString *)className forArray:(void(^)(NSArray *array))block;
-(void)selectTableWithClassName:(NSString *)className andPreprotyName:(NSString *)preprotyName setValue:(id)value forArray:(void(^)(NSArray *array))block;
@end
