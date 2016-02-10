//
//  NSObject+Properties.m
//  TOMJSONAdapter
//
//  Created by Tom Corwine on 2/2/16.
//

#import "NSObject+Properties.h"

#import <UIKit/UIKit.h>
#import <objc/runtime.h>

@implementation NSObject (Properties)

+ (NSObjectReturnType)returnTypeForProperty:(NSString *)name
{
  objc_property_t property = [self propertyFromPropertyName:name];

  if (nil == property) {
    return NSObjectReturnTypeNotFound;
  }

  const char *type = property_getAttributes(property);

  NSString *typeString = [NSString stringWithUTF8String:type];
  NSArray *attributes = [typeString componentsSeparatedByString:@","];
  NSString *typeAttribute = [attributes objectAtIndex:0];
  NSString *propertyType = [typeAttribute substringFromIndex:1];
  const char *rawPropertyType = propertyType.UTF8String;

  if (strcmp(rawPropertyType, @encode(float)) == 0
      || strcmp(rawPropertyType, @encode(double)) == 0
      || strcmp(rawPropertyType, @encode(CGFloat)) == 0)
  {
    return NSObjectReturnTypeFloat;
  }
  else if (strcmp(rawPropertyType, @encode(int)) == 0
             || strcmp(rawPropertyType, @encode(uint)) == 0
             || strcmp(rawPropertyType, @encode(NSInteger)) == 0
             || strcmp(rawPropertyType, @encode(NSUInteger)) == 0
             )
  {
    return NSObjectReturnTypeInteger;
  }
  else if (strcmp(rawPropertyType, @encode(BOOL)) == 0)
  {
    return NSObjectReturnTypeBOOL;
  }
  else if (strcmp(rawPropertyType, @encode(id)) == 0 || [propertyType hasPrefix:@"@"])
  {
    return NSObjectReturnTypeID;
  }
  else
  {
    return NSObjectReturnTypeUnknown;
  }
}

+ (Class)returnTypeClassForProperty:(NSString *)name
{
  objc_property_t property = [self propertyFromPropertyName:name];
  const char *type = property_getAttributes(property);

  NSString *typeString = [NSString stringWithUTF8String:type];
  NSArray *attributes = [typeString componentsSeparatedByString:@","];
  NSString *typeAttribute = [attributes objectAtIndex:0];
  NSString *propertyType = [typeAttribute substringFromIndex:1];

  propertyType = [propertyType substringFromIndex:1]; // Remove @ from front
  NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:@"\""]; // Remove surrounding quotes
  NSString *typeClassName = [typeAttribute stringByTrimmingCharactersInSet:characterSet];

  return NSClassFromString(typeClassName);
}

+ (objc_property_t)propertyFromPropertyName:(NSString *)name
{
  unsigned int outCount;
  objc_property_t *properties = class_copyPropertyList(self, &outCount);

  for (int i = 0; i < outCount; i++)
  {
    objc_property_t property = properties[i];

    const char *propertyName = name.UTF8String;
    const char *currentPropertyName = property_getName(property);

    if (0 == strcmp(propertyName, currentPropertyName)) {
      return property;
    }
  }

  return nil;
}

@end
