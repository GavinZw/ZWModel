//
//  ZWClassInfo.m
//  ZWModel  <https://github.com/ibireme/YYModel>
//
//  Created by Gavin on 17/3/1.
//  Copyright © 2017年 Gavin. All rights reserved.
//

#import "ZWClassInfo.h"
#import <objc/runtime.h>

ZWEncodingType ZWEncodingGetType(const char *typeEncoding) {
  char *type = (char *)typeEncoding;
  if (!type) return ZWEncodingTypeUnknown;
  size_t len = strlen(type);
  if (len == 0) return ZWEncodingTypeUnknown;
  
  ZWEncodingType qualifier = 0;
  bool prefix = true;
  while (prefix) {
    switch (*type) {
      case 'r': {
        qualifier |= ZWEncodingTypeQualifierConst;
        type++;
      } break;
      case 'n': {
        qualifier |= ZWEncodingTypeQualifierIn;
        type++;
      } break;
      case 'N': {
        qualifier |= ZWEncodingTypeQualifierInout;
        type++;
      } break;
      case 'o': {
        qualifier |= ZWEncodingTypeQualifierOut;
        type++;
      } break;
      case 'O': {
        qualifier |= ZWEncodingTypeQualifierBycopy;
        type++;
      } break;
      case 'R': {
        qualifier |= ZWEncodingTypeQualifierByref;
        type++;
      } break;
      case 'V': {
        qualifier |= ZWEncodingTypeQualifierOneway;
        type++;
      } break;
      default: { prefix = false; } break;
    }
  }
  
  len = strlen(type);
  if (len == 0) return ZWEncodingTypeUnknown | qualifier;
  
  switch (*type) {
    case 'v': return ZWEncodingTypeVoid | qualifier;
    case 'B': return ZWEncodingTypeBool | qualifier;
    case 'c': return ZWEncodingTypeInt8 | qualifier;
    case 'C': return ZWEncodingTypeUInt8 | qualifier;
    case 's': return ZWEncodingTypeInt16 | qualifier;
    case 'S': return ZWEncodingTypeUInt16 | qualifier;
    case 'i': return ZWEncodingTypeInt32 | qualifier;
    case 'I': return ZWEncodingTypeUInt32 | qualifier;
    case 'l': return ZWEncodingTypeInt32 | qualifier;
    case 'L': return ZWEncodingTypeUInt32 | qualifier;
    case 'q': return ZWEncodingTypeInt64 | qualifier;
    case 'Q': return ZWEncodingTypeUInt64 | qualifier;
    case 'f': return ZWEncodingTypeFloat | qualifier;
    case 'd': return ZWEncodingTypeDouble | qualifier;
    case 'D': return ZWEncodingTypeLongDouble | qualifier;
    case '#': return ZWEncodingTypeClass | qualifier;
    case ':': return ZWEncodingTypeSEL | qualifier;
    case '*': return ZWEncodingTypeCString | qualifier;
    case '^': return ZWEncodingTypePointer | qualifier;
    case '[': return ZWEncodingTypeCArray | qualifier;
    case '(': return ZWEncodingTypeUnion | qualifier;
    case '{': return ZWEncodingTypeStruct | qualifier;
    case '@': {
      if (len == 2 && *(type + 1) == '?')
        return ZWEncodingTypeBlock | qualifier;
      else
        return ZWEncodingTypeObject | qualifier;
    }
    default: return ZWEncodingTypeUnknown | qualifier;
  }
}

@implementation ZWClassIvarInfo

- (instancetype)initWithIvar:(Ivar)ivar {
  if (!ivar) return nil;
  self = [super init];
  _ivar = ivar;
  const char *name = ivar_getName(ivar);
  if (name) {
    _name = [NSString stringWithUTF8String:name];
  }
  _offset = ivar_getOffset(ivar);
  const char *typeEncoding = ivar_getTypeEncoding(ivar);
  if (typeEncoding) {
    _typeEncoding = [NSString stringWithUTF8String:typeEncoding];
    _type = ZWEncodingGetType(typeEncoding);
  }
  return self;
}

@end

@implementation ZWClassMethodInfo

- (instancetype)initWithMethod:(Method)method {
  if (!method) return nil;
  self = [super init];
  _method = method;
  _sel = method_getName(method);
  _imp = method_getImplementation(method);
  const char *name = sel_getName(_sel);
  if (name) {
    _name = [NSString stringWithUTF8String:name];
  }
  const char *typeEncoding = method_getTypeEncoding(method);
  if (typeEncoding) {
    _typeEncoding = [NSString stringWithUTF8String:typeEncoding];
  }
  char *returnType = method_copyReturnType(method);
  if (returnType) {
    _returnTypeEncoding = [NSString stringWithUTF8String:returnType];
    free(returnType);
  }
  unsigned int argumentCount = method_getNumberOfArguments(method);
  if (argumentCount > 0) {
    NSMutableArray *argumentTypes = [NSMutableArray new];
    for (unsigned int i = 0; i < argumentCount; i++) {
      char *argumentType = method_copyArgumentType(method, i);
      NSString *type = argumentType ? [NSString stringWithUTF8String:argumentType] : nil;
      [argumentTypes addObject:type ? type : @""];
      if (argumentType) free(argumentType);
    }
    _argumentTypeEncodings = argumentTypes;
  }
  return self;
}

@end

@implementation ZWClassPropertyInfo

- (instancetype)initWithProperty:(objc_property_t)property {
  if (!property) return nil;
  self = [super init];
  _property = property;
  const char *name = property_getName(property);
  if (name) {
    _name = [NSString stringWithUTF8String:name];
  }
  
  ZWEncodingType type = 0;
  unsigned int attrCount;
  objc_property_attribute_t *attrs = property_copyAttributeList(property, &attrCount);
  for (unsigned int i = 0; i < attrCount; i++) {
    switch (attrs[i].name[0]) {
      case 'T': { // Type encoding
        if (attrs[i].value) {
          _typeEncoding = [NSString stringWithUTF8String:attrs[i].value];
          type = ZWEncodingGetType(attrs[i].value);
          
          if ((type & ZWEncodingTypeMask) == ZWEncodingTypeObject && _typeEncoding.length) {
            NSScanner *scanner = [NSScanner scannerWithString:_typeEncoding];
            if (![scanner scanString:@"@\"" intoString:NULL]) continue;
            
            NSString *clsName = nil;
            if ([scanner scanUpToCharactersFromSet: [NSCharacterSet characterSetWithCharactersInString:@"\"<"] intoString:&clsName]) {
              if (clsName.length) _cls = objc_getClass(clsName.UTF8String);
            }
            
            NSMutableArray *protocols = nil;
            while ([scanner scanString:@"<" intoString:NULL]) {
              NSString* protocol = nil;
              if ([scanner scanUpToString:@">" intoString: &protocol]) {
                if (protocol.length) {
                  if (!protocols) protocols = [NSMutableArray new];
                  [protocols addObject:protocol];
                }
              }
              [scanner scanString:@">" intoString:NULL];
            }
            _protocols = protocols;
          }
        }
      } break;
      case 'V': { // Instance variable
        if (attrs[i].value) {
          _ivarName = [NSString stringWithUTF8String:attrs[i].value];
        }
      } break;
      case 'R': {
        type |= ZWEncodingTypePropertyReadonly;
      } break;
      case 'C': {
        type |= ZWEncodingTypePropertyCopy;
      } break;
      case '&': {
        type |= ZWEncodingTypePropertyRetain;
      } break;
      case 'N': {
        type |= ZWEncodingTypePropertyNonatomic;
      } break;
      case 'D': {
        type |= ZWEncodingTypePropertyDynamic;
      } break;
      case 'W': {
        type |= ZWEncodingTypePropertyWeak;
      } break;
      case 'G': {
        type |= ZWEncodingTypePropertyCustomGetter;
        if (attrs[i].value) {
          _getter = NSSelectorFromString([NSString stringWithUTF8String:attrs[i].value]);
        }
      } break;
      case 'S': {
        type |= ZWEncodingTypePropertyCustomSetter;
        if (attrs[i].value) {
          _setter = NSSelectorFromString([NSString stringWithUTF8String:attrs[i].value]);
        }
      } // break; commented for code coverage in next line
      default: break;
    }
  }
  if (attrs) {
    free(attrs);
    attrs = NULL;
  }
  
  _type = type;
  if (_name.length) {
    if (!_getter) {
      _getter = NSSelectorFromString(_name);
    }
    if (!_setter) {
      _setter = NSSelectorFromString([NSString stringWithFormat:@"set%@%@:", [_name substringToIndex:1].uppercaseString, [_name substringFromIndex:1]]);
    }
  }
  return self;
}

@end

@implementation ZWClassInfo{
   BOOL _needUpdate;
}

- (instancetype)initWithClass:(Class)cls {
  if (!cls) return nil;
  self = [super init];
  _cls = cls;
  _superCls = class_getSuperclass(cls);
  _isMeta = class_isMetaClass(cls);
  if (!_isMeta) {
    _metaCls = objc_getMetaClass(class_getName(cls));
  }
  _name = NSStringFromClass(cls);
  [self _update];
  
  _superClassInfo = [self.class classInfoWithClass:_superCls];
  return self;
}

- (void)_update {
  _ivarInfos = nil;
  _methodInfos = nil;
  _propertyInfos = nil;
  
  Class cls = self.cls;
  unsigned int methodCount = 0;
  Method *methods = class_copyMethodList(cls, &methodCount);
  if (methods) {
    NSMutableDictionary *methodInfos = [NSMutableDictionary new];
    _methodInfos = methodInfos;
    for (unsigned int i = 0; i < methodCount; i++) {
      ZWClassMethodInfo *info = [[ZWClassMethodInfo alloc] initWithMethod:methods[i]];
      if (info.name) methodInfos[info.name] = info;
    }
    free(methods);
  }
  unsigned int propertyCount = 0;
  objc_property_t *properties = class_copyPropertyList(cls, &propertyCount);
  if (properties) {
    NSMutableDictionary *propertyInfos = [NSMutableDictionary new];
    _propertyInfos = propertyInfos;
    for (unsigned int i = 0; i < propertyCount; i++) {
      ZWClassPropertyInfo *info = [[ZWClassPropertyInfo alloc] initWithProperty:properties[i]];
      if (info.name) propertyInfos[info.name] = info;
    }
    free(properties);
  }
  
  unsigned int ivarCount = 0;
  Ivar *ivars = class_copyIvarList(cls, &ivarCount);
  if (ivars) {
    NSMutableDictionary *ivarInfos = [NSMutableDictionary new];
    _ivarInfos = ivarInfos;
    for (unsigned int i = 0; i < ivarCount; i++) {
      ZWClassIvarInfo *info = [[ZWClassIvarInfo alloc] initWithIvar:ivars[i]];
      if (info.name) ivarInfos[info.name] = info;
    }
    free(ivars);
  }
  
  if (!_ivarInfos) _ivarInfos = @{};
  if (!_methodInfos) _methodInfos = @{};
  if (!_propertyInfos) _propertyInfos = @{};
  
  _needUpdate = NO;
}

- (void)setNeedUpdate {
  _needUpdate = YES;
}

- (BOOL)needUpdate {
  return _needUpdate;
}

+ (instancetype)classInfoWithClass:(Class)cls {
  if (!cls) return nil;
  static CFMutableDictionaryRef classCache;
  static CFMutableDictionaryRef metaCache;
  static dispatch_once_t onceToken;
  static dispatch_semaphore_t lock;
  dispatch_once(&onceToken, ^{
    classCache = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    metaCache = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    lock = dispatch_semaphore_create(1);
  });
  dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
  ZWClassInfo *info = CFDictionaryGetValue(class_isMetaClass(cls) ? metaCache : classCache, (__bridge const void *)(cls));
  if (info && info->_needUpdate) {
    [info _update];
  }
  dispatch_semaphore_signal(lock);
  if (!info) {
    info = [[ZWClassInfo alloc] initWithClass:cls];
    if (info) {
      dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
      CFDictionarySetValue(info.isMeta ? metaCache : classCache, (__bridge const void *)(cls), (__bridge const void *)(info));
      dispatch_semaphore_signal(lock);
    }
  }
  return info;
}

+ (instancetype)classInfoWithClassName:(NSString *)className {
  Class cls = NSClassFromString(className);
  return [self classInfoWithClass:cls];
}

@end
