//
//  NSObject+Properties.m
//  TOMJSONAdapter
//
//  Created by Tom Corwine on 2/2/16.
//

#import "NSObject+Properties.h"

#import <objc/runtime.h>

@implementation NSObject (Properties)

+ (NSObjectReturnType)returnTypeForProperty:(NSString *)propertyName
{
  unsigned int outCount;

  objc_property_t *properties = class_copyPropertyList(self, &outCount);

  for (int i = 0; i < outCount; i++)
  {
    objc_property_t property = properties[i];

    NSString *currentPropertyName = [NSString stringWithUTF8String:property_getName(property)];

    if (NO == [currentPropertyName isEqualToString:propertyName]) {
      continue;
    }

    NSLog(@"PropertyName: %@", propertyName);

    const char *type = property_getAttributes(property);

    NSString *typeString = [NSString stringWithUTF8String:type];
    NSArray *attributes = [typeString componentsSeparatedByString:@","];
    NSString *typeAttribute = [attributes objectAtIndex:0];
    NSString *propertyType = [typeAttribute substringFromIndex:1];
    const char *rawPropertyType = propertyType.UTF8String;

    if (strcmp(rawPropertyType, @encode(float)) == 0) {
      return NSObjectReturnTypeFloat;
    } else if (strcmp(rawPropertyType, @encode(int)) == 0 || strcmp(rawPropertyType, @encode(uint)) == 0) {
      return NSObjectReturnTypeInteger;
    } else if (strcmp(rawPropertyType, @encode(id)) == 0) {
      return NSObjectReturnTypeID;
    } else if (strcmp(rawPropertyType, @encode(BOOL)) == 0) {
      return NSObjectReturnTypeBOOL;
    }

    if ([propertyType hasPrefix:@"@"])
    {
      propertyType = [propertyType substringFromIndex:1]; // Remove @ from front
      NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:@"\""]; // Remove surrounding quotes
      NSString *typeClassName = [typeAttribute stringByTrimmingCharactersInSet:characterSet];

      if ([typeClassName isEqualToString:NSStringFromClass([NSString class])]) {
        return NSObjectReturnTypeNSString;
      } else if ([typeClassName isEqualToString:NSStringFromClass([NSArray class])]) {
        return NSObjectReturnTypeNSArray;
      } else if ([typeClassName isEqualToString:NSStringFromClass([NSDictionary class])]) {
        return NSObjectReturnTypeNSDictionary;
      } else if ([typeClassName isEqualToString:NSStringFromClass([NSNumber class])]) {
        return NSObjectReturnTypeNSNumber;
      }
    }
  }

  return NSObjectReturnTypeUnknown;
}

+ (NSString *)classNameForReturnType:(NSObjectReturnType)returnType
{
  switch (returnType)
  {
    case NSObjectReturnTypeUnknown:
    case NSObjectReturnTypeID:
    case NSObjectReturnTypeFloat:
    case NSObjectReturnTypeDouble:
    case NSObjectReturnTypeInteger:
    case NSObjectReturnTypeBOOL:
    {
      return nil;
      break;
    }
    case NSObjectReturnTypeNSString:
    {
      return @"NSString";
      break;
    }
    case NSObjectReturnTypeNSArray:
    {
      return @"NSArray";
      break;
    }
    case NSObjectReturnTypeNSNumber:
    {
      return @"NSNumber";
      break;
    }
    case NSObjectReturnTypeNSDictionary:
    {
      return @"NSDictionary";
      break;
    }
  }
}

@end
