//
//  ViewController.m
//  FMDB增删查改
//
//  Created by John on 16/4/5.
//  Copyright © 2016年 John.peng. All rights reserved.
//

#import "ViewController.h"
#import "TestObject.h"
#import "NSObject+MMRunTimeManager.h"
#import "MMFMDBManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    TestObject *test = [TestObject new];
    test.title = @"ni hao";
    test.age = @"3";
//    test.names = @[@"john,rose"];
    test.atomicProperty = @"2";
//    test.headImage = [UIImage imageNamed:@""];
    MMFMDBManager *manager = [MMFMDBManager sharedInstance];
    [manager createrTableWithName:@"table_user" forObject:test];
    [manager insertDataForObject:test];
//    test.title = @"ss";
//    test.age = @"3";
//    test.atomicProperty = @"ddd";
//    [manager updataForObject:test forPropretyName:@"age"];
//    [manager deleteDataForObject:test forPropretyName:@"age"];
    [manager selectTableAllDataWithClassName:@"TestObject" forArray:nil];
    [manager selectTableWithClassName:@"TestObject" andPreprotyName:@"title" setValue:@"1" forArray:^(NSArray *array) {
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
