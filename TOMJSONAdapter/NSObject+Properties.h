//
//  NSObject+Properties.h
//  TOMJSONAdapter
//
//  Created by Tom Corwine on 2/2/16.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(u_int8_t) {
  NSObjectReturnTypeNotFound,
  NSObjectReturnTypeUnknown,
  NSObjectReturnTypeFloat,
  NSObjectReturnTypeDouble,
  NSObjectReturnTypeInteger,
  NSObjectReturnTypeBOOL,
  NSObjectReturnTypeID
} NSObjectReturnType;

@interface NSObject (Properties)

+ (NSObjectReturnType)returnTypeForProperty:(NSString *)name;
+ (Class)returnTypeClassForProperty:(NSString *)name;

@end
