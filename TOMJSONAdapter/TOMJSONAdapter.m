//
//  TOMJSONAdapter.m
//  TOMJSONAdapter
//
//  Created by Tom Corwine on 2/13/13.
//

#import "TOMJSONAdapter.h"

@implementation TOMJSONAdapterBool
// Dummy class to type BOOLEAN
@end

const NSInteger kTOMJSONAdapterInvalidObjectDetected = 100;
const NSInteger kTOMJSONAdapterObjectFailedValidation = 101;
const NSInteger kTOMJSONAdapterInvalidJSON = 102;

NSString *const kTOMJSONAdapterKeyForIdentify = @"kTOMJSONAdapterKeyForIdentify";
NSString *const kTOMJSONAdapterKeyForRequired = @"kTOMJSONAdapterKeyForRequired";
NSString *const kTOMJSONAdapterKeyForMap = @"kTOMJSONAdapterKeyForMap";
NSString *const kTOMJSONAdapterKeyForType = @"kTOMJSONAdapterKeyForType";
NSString *const kTOMJSONAdapterKeyForArrayContents = @"kTOMJSONAdapterKeyForArrayContents";
NSString *const kTOMJSONAdapterKeyForDateFormat = @"kTOMJSONAdapterKeyForDateFormat";

@interface TOMJSONAdapter ()
@property (strong) NSMutableDictionary *objectValidationDictionary;
@property (nonatomic, strong) NSMutableArray *errors;
@end

@implementation TOMJSONAdapter

#pragma mark - Initialization

+ (instancetype)JSONAdapter
{
  return [[self alloc] init];
}

- (id)init
{
  self = [super init];

  self.errors = @[].mutableCopy;

  return self;
}

#pragma mark - Object Creation

- (id)createFromJSONRepresentation:(id)JSONRepresentation expectedRootClass:(__unsafe_unretained Class)rootClass errors:(NSArray *__autoreleasing *)errors
{
	if ([JSONRepresentation isKindOfClass:[NSString class]])
	{
		NSString *string = JSONRepresentation;
		NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];

    NSError *error;
    JSONRepresentation = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];

    if (error) {
      [self.errors addObject:error];
    }
	}

  id root = [self objectFromObject:JSONRepresentation validationDictionary:@{kTOMJSONAdapterKeyForType: rootClass}];
  if (nil == rootClass || [root class] == rootClass) {
    //return root;
  } else {
    *error = [[self class] errorWithType:kTOMJSONAdapterObjectFailedValidation additionalInfo:nil];
    //return nil;
  }

  if (self.errors.count > 0 && nil != errors) {
    *errors = [NSArray arrayWithArray:self.errors];
  }

  return root;
}

#pragma mark - Object Creation Helpers

- (id)objectFromObject:(id)object validationDictionary:(NSDictionary *)validationDictionary
{
  if (nil == object || [object isKindOfClass:[NSNull class]]) {
    return nil;
  }

	id classType = validationDictionary[kTOMJSONAdapterKeyForType];

  if (nil == classType) {
    return object; // If no classType is specified, then just return whatever the object is without validating its type.
  }

	if ([classType isEqual:[NSArray class]])
	{
		if ([object isKindOfClass:[NSArray class]])
    {
      Class arrayClassType = validationDictionary[kTOMJSONAdapterKeyForArrayContents];
      object = [self arrayFromArray:object objectType:arrayClassType];
    }
    else
		{
			NSString *errorDescription = [NSString stringWithFormat:@"Expecting NSArray, got %@", NSStringFromClass([object class])];
      NSError *error = [[self class] errorWithType:kTOMJSONAdapterObjectFailedValidation additionalInfo:errorDescription];
      [self.errors addObject:error];
			object = nil;
		}
	}
  else if ([classType isEqual:[NSString class]])
  {
    if (NO == [object isKindOfClass:[NSString class]])
    {
      NSString *errorDescription = [NSString stringWithFormat:@"Expecting NSString, got %@", NSStringFromClass([object class])];
      NSError *error = [[self class] errorWithType:kTOMJSONAdapterObjectFailedValidation additionalInfo:errorDescription];
      [self.errors addObject:error];
      object = nil;
    }
  }
	else if ([classType isEqual:[NSDate class]])
	{
    if ([object isKindOfClass:[NSString class]])
		{
			NSString *dateFormat = validationDictionary[kTOMJSONAdapterKeyForDateFormat];
			NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
			dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
			dateFormatter.dateFormat = dateFormat;
			object = [dateFormatter dateFromString:object];
		}
    else
    {
      NSString *errorDescription = [NSString stringWithFormat:@"Expecting NSDate, got %@", NSStringFromClass([object class])];
      NSError *error = [[self class] errorWithType:kTOMJSONAdapterObjectFailedValidation additionalInfo:errorDescription];
      [self.errors addObject:error];
      object = nil;
    }
	}
  else if ([classType isEqual:[NSNumber class]])
  {
		if (NO == [object isKindOfClass:[NSNumber class]])
		{
			NSString *errorDescription = [NSString stringWithFormat:@"Expecting NSNumber, got %@", NSStringFromClass([object class])];
      NSError *error = [[self class] errorWithType:kTOMJSONAdapterObjectFailedValidation additionalInfo:errorDescription];
      [self.errors addObject:error];
			object = nil;
		}
  }
  else if ([classType isEqual:[TOMJSONAdapterBool class]])
  {
    if ([object isKindOfClass:[NSNumber class]])
    {
      NSNumber *number = object;
      if (number.boolValue != YES && number.boolValue != NO)
      {
        NSError *error = [[self class] errorWithType:kTOMJSONAdapterObjectFailedValidation additionalInfo:@"Expecting a NSNumber that's a BOOL"];
        [self.errors addObject:error];
        object = nil;
      }
    }
    else
    {
      NSString *errorDescription = [NSString stringWithFormat:@"Expecting TOMJSONAdapterBool, got %@", NSStringFromClass([object class])];
      NSError *error = [[self class] errorWithType:kTOMJSONAdapterObjectFailedValidation additionalInfo:errorDescription];
      [self.errors addObject:error];
      object = nil;
    }
  }
  else
  {
    object = [self objectFromDictionary:object];

    if (NO == [object isKindOfClass:classType])
    {
      NSString *errorDescription = [NSString stringWithFormat:@"Expecting %@, got %@", classType, NSStringFromClass([object class])];
      NSError *error = [[self class] errorWithType:kTOMJSONAdapterObjectFailedValidation additionalInfo:errorDescription];
      [self.errors addObject:error];
      object = nil;
    }
  }

	return object;
}

- (NSArray *)arrayFromArray:(NSArray *)array objectType:(Class)objectType
{
	NSMutableArray *mutableArray = @[].mutableCopy;
	for (__strong id object in array)
	{
		NSDictionary *validationDictionary = (objectType ? @{kTOMJSONAdapterKeyForType: objectType} : nil);
		object = [self objectFromObject:object validationDictionary:validationDictionary];

    if (object) {
      [mutableArray addObject:object];
    }
	}

	return [NSArray arrayWithArray:mutableArray];
}

- (id)objectFromDictionary:(NSDictionary *)dictionary
{
	Class class = [self classForUniqueIdentifiers:dictionary.allKeys];
  if (class == [NSDictionary class]) {
		return dictionary;
  }

  if ([class respondsToSelector:@selector(initWithDictionary:)]) {
    return [[class alloc] initWithDictionary:dictionary]; // Alternate way of initializing object.
  }

	id object = [[class alloc] init];
	NSDictionary *validationDictionary = [self validationDictionaryForClass:class];
	for (NSString *key in validationDictionary.allKeys)
	{
		NSDictionary *propertyValidationDictionary = validationDictionary[key];
		id value = dictionary[key];
		NSNumber *required = ([propertyValidationDictionary.allKeys containsObject:kTOMJSONAdapterKeyForRequired] ? propertyValidationDictionary[kTOMJSONAdapterKeyForRequired] : @YES); // Default to YES unless dictionary contains a kTOMJSONAdapterKeyForRequired key.

    if (required.boolValue && NO == [dictionary.allKeys containsObject:key])
		{
			NSString *string = [NSString stringWithFormat:@"Missing required parameter %@", key];
      NSError *error = [[self class] errorWithType:kTOMJSONAdapterObjectFailedValidation additionalInfo:string];
      [self.errors addObject:error];
			return nil;
		}

    if (nil == value) {
			continue; // Property doesn't exist or is nil.
    }

		value = [self objectFromObject:value validationDictionary:propertyValidationDictionary];

		NSString *map = propertyValidationDictionary[kTOMJSONAdapterKeyForMap];
		NSString *accessorKey = (map ?: key); // Map to accessor.
		[object setValue:value forKey:accessorKey];
	}

	return object;
}

#pragma mark - Class Identification
/*
- (Class)classForUniqueIdentifiers:(NSArray *)array
{
	NSArray *classesToConsiderArray = (self.classesToConsider ?: kTOMJSONAdapterDefaultClassesToConsiderArray);
	NSAssert(classesToConsiderArray, [[self class] classesToConsiderErrorForMessage:@"Must be called before attempting to parse JSON."]);

	for (Class<TOMJSONAdapterProtocol> class in classesToConsiderArray)
	{
		NSAssert([(NSObject *)class conformsToProtocol:@protocol(TOMJSONAdapterProtocol)], [[self class] errorMessageWithClassNameForErrorMessage:@"Classes must conform to the TRKJSONAdapterProtocol protocol."]);
		NSMutableArray *mutableArray = @[].mutableCopy;
		NSDictionary *validationDictionary = [self validationDictionaryForClass:class];

		for (NSString *key in validationDictionary.allKeys)
		{
			NSDictionary *propertyValidationDictionary = validationDictionary[key];
			NSNumber *identify = propertyValidationDictionary[kTOMJSONAdapterKeyForIdentify];
      if (identify.boolValue) {
				[mutableArray addObject:key];
      }
		}

    NSSet *uniqueIdentifiersSet = [NSSet setWithArray:mutableArray];
		NSSet *objectSet = [NSSet setWithArray:array];

    if ([uniqueIdentifiersSet isSubsetOfSet:objectSet]) {
			return class;
    }
	}

	// If none of the kClassesToConsiderStringsArray match for unique identifier, just create a NSDictionary.
	return [NSDictionary class];
}
*/
#pragma mark - Validation

- (NSDictionary *)validationDictionaryForClass:(Class)class
{
  if (nil == self.objectValidationDictionary) {
		self.objectValidationDictionary = @{}.mutableCopy;
  }

	NSString *key = NSStringFromClass(class);
	NSDictionary *dictionary = self.objectValidationDictionary[key];

	if (nil == dictionary)
	{
		dictionary = [class JSONAdapterSchema];
		NSArray *keyValidationArray = @[kTOMJSONAdapterKeyForIdentify, kTOMJSONAdapterKeyForMap, kTOMJSONAdapterKeyForRequired, kTOMJSONAdapterKeyForType, kTOMJSONAdapterKeyForArrayContents, kTOMJSONAdapterKeyForDateFormat];

		for (NSString *objectKey in dictionary.allKeys)
		{
			NSDictionary *objectDictionary = dictionary[objectKey];
			for (NSString *key in objectDictionary.allKeys)
			{
        NSString *items = [keyValidationArray componentsJoinedByString:@", "];
        NSString *errorDescription = [NSString stringWithFormat:@"Validation key for class %@ is invalid. Key was %@, expecting one of %@.", NSStringFromClass(class), key, items];
        NSAssert([keyValidationArray containsObject:key], [[self class] errorMessageWithClassNameForErrorMessage:errorDescription]);
        id value = objectDictionary[key];

        if ([key isEqualToString:kTOMJSONAdapterKeyForType] || [key isEqualToString:kTOMJSONAdapterKeyForArrayContents])
        {
          NSString *string = [NSString stringWithFormat:@"Validation value for key %@ in class %@ is not an object type Class.", key, NSStringFromClass(class)];
          // This comparision warrants some 'splaining. value == [value class] evaluates to true if 'value' is of type "Class".
          // SO Post http://stackoverflow.com/questions/355312/in-objective-c-how-can-i-tell-the-difference-between-a-class-and-an-instance-of
          NSAssert(value == [value class], [[self class] errorMessageWithClassNameForErrorMessage:string]);
        }
        else if ([key isEqualToString:kTOMJSONAdapterKeyForDateFormat] || [key isEqualToString:kTOMJSONAdapterKeyForMap])
        {
          NSString *string = [NSString stringWithFormat:@"Validation value for key %@ in class %@ is not a NSString.", key, NSStringFromClass(class)];
                    NSAssert([value isKindOfClass:[NSString class]], [[self class] errorMessageWithClassNameForErrorMessage:string]);
        }
                else if ([key isEqualToString:kTOMJSONAdapterKeyForIdentify] || [key isEqualToString:kTOMJSONAdapterKeyForRequired])
        {
          NSString *string = [NSString stringWithFormat:@"Validation value for property %@ and key %@ in class %@ is not a NSNumber.", objectKey, key, NSStringFromClass(class)];
                    NSAssert([value isKindOfClass:[NSNumber class]], [[self class] errorMessageWithClassNameForErrorMessage:string]);
        }
			}
		}
		self.objectValidationDictionary[key] = dictionary;
	}

	return dictionary;
}

#pragma mark - Error Message Helpers

+ (NSError *)errorWithType:(NSUInteger)errorType additionalInfo:(NSString *)info
{
  NSString *string;
  switch (errorType)
  {
    case kTOMJSONAdapterObjectFailedValidation:
    {
      string = @"Object failed validation";
      break;
    }
    case kTOMJSONAdapterInvalidObjectDetected:
    {
      string = @"Invalid object type";
      break;
    }
    case kTOMJSONAdapterInvalidJSON:
    {
        string = @"JSON can not be parsed";
        break;
    }
    default:
    {
      NSAssert(NO, @"Error type not known.");
      break;
    }
  }

  string = [self errorMessageWithClassNameForErrorMessage:string];
  if (info.length) {
    string = [NSString stringWithFormat:@"%@ - %@.", string, info];
  } else {
    string = [string stringByAppendingString:@"."];
  }

  return [NSError errorWithDomain:string code:errorType userInfo:nil];
}

+ (NSString *)classesToConsiderErrorForMessage:(NSString *)errorMessage
{
  return [NSString stringWithFormat:@"[%@ setClassesToConsider:] - %@", NSStringFromClass([self class]), errorMessage];
}

+ (NSString *)errorMessageWithClassNameForErrorMessage:(NSString *)errorMessage
{
  return [NSString stringWithFormat:@"%@: %@", NSStringFromClass([self class]), errorMessage];
}

@end
