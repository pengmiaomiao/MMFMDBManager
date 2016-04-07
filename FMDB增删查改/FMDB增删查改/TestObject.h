//
//  TestObject.h
//  FMDB增删查改
//
//  Created by John on 16/4/5.
//  Copyright © 2016年 John.peng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TestObject : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *age;
@property (nonatomic, strong) NSString *atomicProperty;
@end
