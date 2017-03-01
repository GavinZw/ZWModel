//
//  ZWModel.h
//  ZWModel
//
//  Created by Gavin on 17/3/1.
//  Copyright © 2017年 Gavin. All rights reserved.
//

#import <Foundation/Foundation.h>

#if __has_include(<ZWModel/ZWModel.h>)

//! Project version number for ZWModel.
FOUNDATION_EXPORT double ZWModelVersionNumber;
//! Project version string for ZWModel.
FOUNDATION_EXPORT const unsigned char ZWModelVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <ZWModel/PublicHeader.h>
#import <ZWModel/NSObject+ZWModel.h>
#import <ZWModel/ZWClassInfo.h>
#import <ZWModel/ZWBaseModel.h>

#else

#import "NSObject+ZWModel.h"
#import "ZWClassInfo.h"
#import "ZWBaseModel.h"

#endif
