//
//  ZWIMModel.h
//  ZWModel
//
//  Created by Gavin on 17/3/1.
//  Copyright © 2017年 Gavin. All rights reserved.
//

#import <ZWModel/ZWModel.h>
#import "SkyTestModel.h"

@interface ZWIMModel : ZWBaseModel

@property (nonatomic, copy) NSString *des;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSUInteger pages;

@property (nonatomic, strong) SkyTestModel *test;

@end
