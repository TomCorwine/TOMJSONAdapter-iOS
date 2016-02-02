//
//  NSObject+Properties.h
//  TOMJSONAdapter
//
//  Created by Tom Corwine on 2/2/16.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(u_int8_t) {
  NSObjectReturnTypeUnknown,
  NSObjectReturnTypeFloat,
  NSObjectReturnTypeDouble,
  NSObjectReturnTypeInteger,
  NSObjectReturnTypeBOOL,
  NSObjectReturnTypeNSString,
  NSObjectReturnTypeNSArray,
  NSObjectReturnTypeNSDictionary,
  NSObjectReturnTypeNSNumber,
  NSObjectReturnTypeID
} NSObjectReturnType;

@interface NSObject (Properties)

+ (NSObjectReturnType)returnTypeForProperty:(NSString *)propertyName;
+ (NSString *)classNameForReturnType:(NSObjectReturnType)returnType;

@end
