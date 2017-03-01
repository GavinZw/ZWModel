//
//  ZWIMModel.m
//  ZWModel
//
//  Created by Gavin on 17/3/1.
//  Copyright © 2017年 Gavin. All rights reserved.
//

#import "ZWIMModel.h"

@implementation ZWIMModel

+ (NSDictionary *)modelCustomPropertyMapper {
  return @{@"pages":@"p",
           @"des":@"describe"};
}


+ (NSDictionary *)modelContainerPropertyGenericClass {
  return @{@"test":[SkyTestModel class]};
}


@end
