//
//  FMDBManager.m
//  FMDB增删查改
//
//  Created by John on 16/4/5.
//  Copyright © 2016年 John.peng. All rights reserved.
//

#import "MMFMDBManager.h"
#import "FMDB.h"
#import "NSObject+MMRunTimeManager.h"

@interface MMFMDBManager()
{
    NSString *_filePath;
    NSString *_fileName;
}
@property(nonatomic,strong)FMDatabaseQueue *fmQueue;
@end

@implementation MMFMDBManager
static MMFMDBManager  *manager = nil;
+(instancetype)sharedInstance{
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}
+(NSString *)getPathUrl{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentUrl = [paths objectAtIndex:0];
    return documentUrl;
}
-(void)createrTableWithName:(NSString *)name forObject:(id)object{
    _fileName = name;
    _filePath = [[MMFMDBManager getPathUrl] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite",name]];
    [self.fmQueue inDatabase:^(FMDatabase *db) {
        if ([db open]) {
            if (![db tableExists:name]) {
                NSString *sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS '%@' %@",name,[self getSqlCreaterTableWithObject:object]];
                NSLog(@"%@",sql);
                BOOL res = [db executeUpdate:sql];
                if (!res) {
                    NSLog(@"创建表失败");
                }else{
                    NSLog(@"创建表成功");
                }
            }
            [db close];
        }
    }];
}
-(void)insertDataForObject:(id)object{
    [self.fmQueue inDatabase:^(FMDatabase *db) {
        if ([db open]) {
            NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@ %@ VALUES %@",_fileName,[self getSqlInsertTableWithObject:object],[self getSqlInsertTableWithValueForObject:object]];
            NSLog(@"%@",sql);
            BOOL res = [db executeUpdate:sql];
            if (res) {
                NSLog(@"插入成功");
            }
            else{
                NSLog(@"插入失败");
            }
            [db close];
        }
    }];
}
-(void)updataForObject:(id)object forPropretyName:(NSString *)name{
    [self.fmQueue inDatabase:^(FMDatabase *db) {
        if ([db open]) {
            NSString *sql = [NSString stringWithFormat:@"UPDATE %@ SET %@",_fileName,[self getSqlUpdateTableWithObject:object forPropretyName:name]];
            NSLog(@"%@",sql);
            BOOL res = [db executeUpdate:sql];
            if (res) {
                NSLog(@"更新成功");
            }
            else{
                NSLog(@"更新失败");
            }
            [db close];
        }
    }];
}
-(void)deleteDataForObject:(id)object forPropretyName:(NSString *)name{
    [self.fmQueue inDatabase:^(FMDatabase *db) {
        if ([db open]) {
            NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ %@",_fileName,[self getSqlDelegateTableWithOject:object forPropretyName:name]];
            NSLog(@"%@",sql);
            BOOL res = [db executeUpdate:sql];
            if (res) {
                NSLog(@"删除成功");
            }
            else{
                NSLog(@"插入失败");
            }
            [db close];
        }
    }];
}
-(void)selectTableAllDataWithClassName:(NSString *)className forArray:(void(^)(NSArray *array))block{
    Class myClass = NSClassFromString(className);
    NSMutableArray *array = [NSMutableArray new];
    [self.fmQueue inDatabase:^(FMDatabase *db) {
        if ([db open]) {
            NSString *sql = [NSString stringWithFormat:@"select * from %@",_fileName];
            NSLog(@"%@",sql);
            FMResultSet *set = [db executeQuery:sql];
            while ([set next]) {
                NSObject *obj = [myClass new];
                NSArray *pArray = [obj getAllProperties:nil];
                for (NSArray *sub in pArray) {
                    NSString *value = [set stringForColumn:sub[0]];
                    [obj setPropertyWithSEL:[obj propertySetterWithKey:sub[0]] forValue:value];
                }
                [array addObject:obj];
            }
            [db close];
            if (block) {
                block(array);
            }
        }
    }];
}
-(void)selectTableWithClassName:(NSString *)className andPreprotyName:(NSString *)preprotyName setValue:(id)value forArray:(void(^)(NSArray *array))block{
    Class myClass = NSClassFromString(className);
    NSMutableArray *array = [NSMutableArray new];
    [self.fmQueue inDatabase:^(FMDatabase *db) {
        if ([db open]) {
            NSString *sql = [NSString stringWithFormat:@"select * from %@ where %@ = %@",_fileName,preprotyName,value];
            NSLog(@"%@",sql);
            FMResultSet *set = [db executeQuery:sql];
            while ([set next]) {
                NSObject *obj = [myClass new];
                NSArray *pArray = [obj getAllProperties:nil];
                for (NSArray *sub in pArray) {
                    NSString *value = [set stringForColumn:sub[0]];
                    [obj setPropertyWithSEL:[obj propertySetterWithKey:sub[0]] forValue:value];
                }
                [array addObject:obj];
            }
            [db close];
            if (block) {
                block(array);
            }
        }
    }];
}
#pragma mark - 创建sql表语句
-(NSString *)getSqlCreaterTableWithObject:(id)object{
    NSString *sql = nil;
    NSArray *array = [object getAllProperties:nil];
    for (int i = 0; i<array.count; i++) {
        NSArray *subArr = array[i];
        if (i < 1) {
            sql = [NSString stringWithFormat:@"('%@' %@,",subArr[0],[self getObjectPropretyForSqlWithKey:subArr[1]]];
        }
        else if (i<array.count-1){
            sql = [NSString stringWithFormat:@"%@ '%@' %@,",sql,subArr[0],[self getObjectPropretyForSqlWithKey:subArr[1]]];
        }
        else{
            sql = [NSString stringWithFormat:@"%@ '%@' %@)",sql,subArr[0],[self getObjectPropretyForSqlWithKey:subArr[1]]];
        }
    }
    return sql;
}
#pragma mark - 创建sql插入语句
-(NSString *)getSqlInsertTableWithObject:(id)object{
    NSString *sql = nil;
    NSArray *array = [object getAllProperties:nil];
    for (int i = 0; i<array.count; i++) {
        NSArray *subArr = array[i];
        if (i < 1) {
            sql = [NSString stringWithFormat:@"('%@',",subArr[0]];
        }
        else if (i<array.count-1){
            sql = [NSString stringWithFormat:@"%@ '%@',",sql,subArr[0]];
        }
        else{
            sql = [NSString stringWithFormat:@"%@ '%@')",sql,subArr[0]];
        }
    }
    return sql;
}
#pragma mark - 创建sql插入值语句
-(NSString *)getSqlInsertTableWithValueForObject:(id)object{
    NSString *sql = nil;
    NSArray *array = [object getAllProperties:nil];
    for (int i = 0; i<array.count; i++) {
        NSArray *subArr = array[i];
        id obj = [object getPropertyWithName:subArr[0]];
        if (i < 1) {
            sql = [NSString stringWithFormat:@"('%@',",obj];
        }
        else if (i<array.count-1){
            sql = [NSString stringWithFormat:@"%@ '%@',",sql,obj];
        }
        else{
            sql = [NSString stringWithFormat:@"%@ '%@')",sql,obj];
        }
    }
    return sql;
}
#pragma mark - 创建sql更新语句
-(NSString *)getSqlUpdateTableWithObject:(id)object forPropretyName:(NSString *)name{
    NSString *sql = nil;
    NSString *whereQsl = nil;
    NSArray *array = [object getAllProperties:nil];
    for (int i = 0; i<array.count; i++) {
        NSArray *subArr = array[i];
        id obj = [object getPropertyWithName:subArr[0]];
        if ([subArr[0] isEqualToString:name]) {
            whereQsl = [NSString stringWithFormat:@" WHERE %@ = '%@'",name,obj];
        }
        else{
            if (i<1) {
                sql = [NSString stringWithFormat:@"%@ = '%@',",subArr[0],obj];
            }
            else if (i<array.count-1){
                sql = [NSString stringWithFormat:@"%@ %@ = '%@',",sql,subArr[0],obj];
            }
            else{
                sql = [NSString stringWithFormat:@"%@ %@ = '%@'",sql,subArr[0],obj];
            }
        }
    }
    sql = [NSString stringWithFormat:@"%@%@",sql,whereQsl];
    return sql;
}
#pragma mark - 创建sql删除语句
-(NSString *)getSqlDelegateTableWithOject:(id)object forPropretyName:(NSString *)name{
    NSString *sql = nil;
    NSArray *array = [object getAllProperties:nil];
    for (int i = 0; i<array.count; i++) {
        NSArray *subArr = array[i];
        id obj = [object getPropertyWithName:subArr[0]];
        if ([subArr[0] isEqualToString:name]) {
            sql = [NSString stringWithFormat:@" WHERE %@ = '%@'",name,obj];
        }
    }
    return sql;
}
#pragma mark - 获取类的属性中的对象类型
-(NSString *)getObjectPropretyForSqlWithKey:(NSString *)key{
    NSArray *array = [key componentsSeparatedByString:@","];
    if (array.count>0) {
        NSString *SQL = array[0];
        if ([self predicateWithMatches:@"(T@\".*?\")" forString:SQL]) {
            if ([SQL isEqualToString:@"T@\"NSString\""]) {
                return @"TEXT";
            }
            else if ([SQL isEqualToString:@"T@\"NSNumber\""]){
                return @"INTEGER";
            }
            else{
                return @"BLOB";
            }
        }
        else if ([self predicateWithMatches:@"T((?:[a-z,A-Z][a-z0-9_]*))" forString:SQL]){
            if ([SQL isEqualToString:@"Ti"]) {
                return @"INTEGER";
            }
            else{
                return @"REAL";
            }
        }
        else if ([SQL isEqualToString:@"T@"]){
            return @"BLOB";
        }
        else{
            return @"TEXT";
        }
    }
    return nil;
}
#pragma mark - 正则匹配
-(BOOL)predicateWithMatches:(NSString *)matches forString:(NSString *)string{
    // 编写正则表达式：只能是数字或英文，或两者都存在
//    NSString *regex = @"(T@\".*?\")";
    // 创建谓词对象并设定条件的表达式
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", matches];
    // 对字符串进行判断
    if ([predicate evaluateWithObject:string]) {
        return YES;
    }
    return NO;
}
#pragma mark - setter,getter
-(FMDatabaseQueue *)fmQueue{
    if (_fmQueue == nil) {
        _fmQueue = [FMDatabaseQueue databaseQueueWithPath:_filePath];
        NSLog(@"%@",_filePath);
    }
    return _fmQueue;
}
@end
