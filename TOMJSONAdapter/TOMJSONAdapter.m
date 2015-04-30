//
//  TOMJSONAdapter.m
//  Tom's iPhone Apps
//
//  Created by Tom Corwine on 2/13/13.
//

#import "TOMJSONAdapter.h"

@implementation TOMJSONAdapterBool
// Dummy class to type BOOLEAN
@end

const NSInteger kTOMJSONAdapterInvalidObjectDetected = 100;
const NSInteger kTOMJSONAdapterObjectFailedValidation = 101;

NSString *const kTOMJSONAdapterKeyForIdentify = @"kTOMJSONAdapterKeyForIdentify";
NSString *const kTOMJSONAdapterKeyForRequired = @"kTOMJSONAdapterKeyForRequired";
NSString *const kTOMJSONAdapterKeyForMap = @"kTOMJSONAdapterKeyForMap";
NSString *const kTOMJSONAdapterKeyForType = @"kTOMJSONAdapterKeyForType";
NSString *const kTOMJSONAdapterKeyForArrayContents = @"kTOMJSONAdapterKeyForArrayContents";
NSString *const kTOMJSONAdapterKeyForDateFormat = @"kTOMJSONAdapterKeyForDateFormat";

static NSArray *kTOMJSONAdapterDefaultClassesToConsiderArray = nil;

@interface TOMJSONAdapter ()
@property (strong) NSMutableDictionary *objectValidationDictionary;
@end

@implementation TOMJSONAdapter

+ (instancetype)JSONAdapter
{
    return [[self alloc] init];
}

+ (void)setDefaultClassesToConsider:(NSArray *)array
{
	[[self class] validateClassesToConsider:array];
	kTOMJSONAdapterDefaultClassesToConsiderArray = array;
}

- (id)initWithClassesToConsider:(NSArray *)array
{
	self = [super init];
	self.classesToConsider = array;
	return self;
}

- (id)createFromJSONRepresentation:(id)JSONRepresentation error:(NSError **)error
{
	if ([JSONRepresentation isKindOfClass:[NSString class]])
	{
		NSString *string = JSONRepresentation;
		NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
		JSONRepresentation = [NSJSONSerialization JSONObjectWithData:data options:0 error:error];

    if (*error) {
			return nil;
    }
	}

	return [self objectFromObject:JSONRepresentation validationDictionary:nil error:error];
}

#pragma mark - Imparatives

- (void)setClassesToConsider:(NSArray *)array
{
	[[self class] validateClassesToConsider:array];
	_classesToConsider = array;
}

#pragma mark - Helpers

+ (void)validateClassesToConsider:(NSArray *)array
{
  NSAssert([array isKindOfClass:[NSArray class]], @"[TOMJSONAdapter setClassesToConsider:] parameter not a NSArray.");
/*
  for (Class class in array) {
    NSAssert([class isKindOfClass:[Class class]], @"[TOMJSONAdapter setClassesToConsider:] array parameter contains object type other than Class.");
  }
*/
}

- (id)objectFromObject:(id)object validationDictionary:(NSDictionary *)validationDictionary error:(NSError **)error
{
  if (nil == object) {
    return nil;
  }

	id classType = validationDictionary[kTOMJSONAdapterKeyForType];
	if ([object isKindOfClass:[NSArray class]])
	{
		if (classType && NO == [classType isEqual:[NSArray class]])
		{
			NSString *errorDescription = [NSString stringWithFormat:@"TOMJSONAdapter invalid object type detcted. Expecting NSArray, got %@.", NSStringFromClass([object class])];
			*error = [NSError errorWithDomain:errorDescription code:kTOMJSONAdapterObjectFailedValidation userInfo:nil];
			object = nil;
		}
		else
		{
			Class arrayClassType = validationDictionary[kTOMJSONAdapterKeyForArrayContents];
			object = [self arrayFromArray:object objectType:arrayClassType error:error];
		}
	}
	else if ([object isKindOfClass:[NSDictionary class]])
	{
		object = [self objectFromDictionary:object error:error];

		if (classType && NO == [object isKindOfClass:classType])
		{
			NSString *errorDescription = [NSString stringWithFormat:@"TOMJSONAdapter invalid object type detcted. Expecting %@, got %@.", classType, NSStringFromClass([object class])];
			*error = [NSError errorWithDomain:errorDescription code:kTOMJSONAdapterObjectFailedValidation userInfo:nil];
			object = nil;
		}
	}
	else if ([object isKindOfClass:[NSString class]])
	{
    if (classType && NO == [classType isEqual:[NSString class]] && NO == [classType isEqual:[NSDate class]])
		{
			NSString *errorDescription = [NSString stringWithFormat:@"TOMJSONAdapter invalid object type detcted. Expecting NSString, got %@.", NSStringFromClass([object class])];
			*error = [NSError errorWithDomain:errorDescription code:kTOMJSONAdapterObjectFailedValidation userInfo:nil];
			object = nil;
		}
    else if (classType && [classType isEqual:[NSDate class]])
		{
			NSString *dateFormat = validationDictionary[kTOMJSONAdapterKeyForDateFormat];
			NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
			dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
			dateFormatter.dateFormat = dateFormat;
			object = [dateFormatter dateFromString:object];
		}
	}
	else if ([object isKindOfClass:[NSNumber class]])
	{
		if (classType && NO == [classType isEqual:[NSNumber class]] && NO == [classType isEqual:[TOMJSONAdapterBool class]])
		{
			NSString *errorDescription = [NSString stringWithFormat:@"TOMJSONAdapter invalid object type detcted. Expecting NSNumber, got %@.", NSStringFromClass([object class])];
			*error = [NSError errorWithDomain:errorDescription code:kTOMJSONAdapterObjectFailedValidation userInfo:nil];
			object = nil;
		}

		if ([classType isKindOfClass:[TOMJSONAdapterBool class]])
		{
			NSNumber *number = object;
			if (number.boolValue != YES && number.boolValue != NO)
			{
				*error = [NSError errorWithDomain:@"TOMJSONAdapter invalid object type detcted." code:kTOMJSONAdapterObjectFailedValidation userInfo:nil];
				object = nil;
			}
		}
	}
	else if ([object isKindOfClass:[NSNull class]])
	{
		object = nil; // Return nil in place of NSNull object.
	}
	else
	{
		// Not a valid object type.
		*error = [NSError errorWithDomain:@"TOMJSONAdapter invalid object type detcted." code:kTOMJSONAdapterInvalidObjectDetected userInfo:nil];
		object = nil;
	}

	return object;
}

- (NSArray *)arrayFromArray:(NSArray *)array objectType:(Class)objectType error:(NSError **)error
{
	NSMutableArray *mutableArray = @[].mutableCopy;
	for (__strong id object in array)
	{
		NSDictionary *validationDictionary = (objectType ? @{kTOMJSONAdapterKeyForType: objectType} : nil);
		object = [self objectFromObject:object validationDictionary:validationDictionary error:error];

    if (*error) {
      return nil;
    }

    if (object) {
      [mutableArray addObject:object];
    }
	}

	return [NSArray arrayWithArray:mutableArray];
}

- (id)objectFromDictionary:(NSDictionary *)dictionary error:(NSError **)error
{
	Class class = [self classForUniqueIdentifiers:dictionary.allKeys];
  if (class == [NSDictionary class]) {
		return dictionary;
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
			NSString *errorString = [NSString stringWithFormat:@"TOMJSONAdapter missing required parameter %@.", key];
			*error = [NSError errorWithDomain:errorString code:kTOMJSONAdapterObjectFailedValidation userInfo:nil];
			return nil;
		}

    if (nil == value) {
			continue; // Property doesn't exist or is nil.
    }

		value = [self objectFromObject:value validationDictionary:propertyValidationDictionary error:error];
    if (*error) {
			return nil;
    }

		NSString *map = propertyValidationDictionary[kTOMJSONAdapterKeyForMap];
		NSString *accessorKey = (map ? map : key); // Map to accessor.
		[object setValue:value forKey:accessorKey];
	}

	return object;
}

- (Class)classForUniqueIdentifiers:(NSArray *)array
{
	NSArray *classesToConsiderArray = (self.classesToConsider ? self.classesToConsider : kTOMJSONAdapterDefaultClassesToConsiderArray);
	NSAssert(classesToConsiderArray, @"[TOMJSONAdapter setClassesToConsider:] must be called before attempting to parse JSON.");

	for (Class<TOMJSONAdapterProtocol> class in classesToConsiderArray)
	{
		NSAssert([(NSObject *)class conformsToProtocol:@protocol(TOMJSONAdapterProtocol)], @"Models must conform to the TRKJSONAdapterProtocol protocol.");
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
				NSAssert([keyValidationArray containsObject:key], @"Validation key for class %@ is invalid. Key was %@, expecting one of kTOMJSONAdapterKeyForIdentify, kTOMJSONAdapterKeyForMap, kTOMJSONAdapterKeyForRequired, kTOMJSONAdapterKeyForType.", NSStringFromClass(class), key);
				id value = objectDictionary[key];
/*
        if ([key isEqualToString:kTOMJSONAdapterKeyForType] || [key isEqualToString:kTOMJSONAdapterKeyForMap])
        {
					NSAssert([value isKindOfClass:[NSString class]], @"TOMJSONAdapter validation value for key %@ in class %@ is not a string.", key, NSStringFromClass(class));
                }
				else */if ([key isEqualToString:kTOMJSONAdapterKeyForIdentify] || [key isEqualToString:kTOMJSONAdapterKeyForRequired])
        {
					NSAssert([value isKindOfClass:[NSNumber class]], @"TOMJSONAdapter validation value for property %@ and key %@ in class %@ is not a number.", objectKey, key, NSStringFromClass(class));
        }
			}
		}
		self.objectValidationDictionary[key] = dictionary;
	}
	return dictionary;
}

@end
