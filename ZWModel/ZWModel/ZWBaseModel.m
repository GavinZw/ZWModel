//
//  ZWBaseModel.m
//  ZWModel
//
//  Created by Gavin on 17/3/1.
//  Copyright © 2017年 Gavin. All rights reserved.
//

#import "ZWBaseModel.h"
#import "NSObject+ZWModel.h"
#import "ZWClassInfo.h"

@implementation ZWBaseModel 

- (void)encodeWithCoder:(NSCoder *)aCoder { [self zw_modelEncodeWithCoder:aCoder]; }
- (id)initWithCoder:(NSCoder *)aDecoder { self = [super init]; return [self zw_modelInitWithCoder:aDecoder]; }
- (id)copyWithZone:(NSZone *)zone { return [self zw_modelCopy]; }
- (NSUInteger)hash { return [self zw_modelHash]; }
- (BOOL)isEqual:(id)object { return [self zw_modelIsEqual:object]; }
- (NSString *)description { return [self zw_modelDescription]; }
  
@end
