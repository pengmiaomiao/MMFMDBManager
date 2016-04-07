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
//@property (nonatomic, copy) NSString *rr;
//@property (nonatomic, strong) NSArray *names;
//@property (nonatomic, assign) int count;
//@property (nonatomic, assign) float xx;
//@property (nonatomic, assign) unsigned int tt;
//@property (nonatomic, weak) id delegate;
@property (nonatomic, strong) NSString *atomicProperty;
//@property (nonatomic, strong) UIImage *headImage;
//@property (nonatomic, strong) TestObject *obj;
@end
