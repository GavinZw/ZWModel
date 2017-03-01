//
//  ZWBaseModel.h
//  ZWModel
//
//  Created by Gavin on 17/3/1.
//  Copyright © 2017年 Gavin. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * 一个公共对象模型.
 * 实现了<NSCoding,NSCopying>
 * 子类只需要继承,即可以进行对象归档.
 */
@interface ZWBaseModel : NSObject <
 NSCoding,
 NSCopying
>


@end
