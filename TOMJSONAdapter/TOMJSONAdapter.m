//
//  TOMJSONAdapter.m
//  Tom's iPhone Apps
//
//  Created by Tom Corwine on 2/13/13.
//

#import "TOMJSONAdapter.h"

static NSArray *kTOMJSONAdapterDefaultClassesToConsiderArray = nil;

@interface TOMJSONAdapter ()
@property (strong) NSMutableDictionary *objectValidationDictionary;
@end

@implementation TOMJSONAdapter

+ (void)setDefaultClassesToConsider:(NSArray *)array
{
	[TOMJSONAdapter validateClassesToConsider:array];
	kTOMJSONAdapterDefaultClassesToConsiderArray = array;
}

+ (void)validateClassesToConsider:(NSArray *)array
{
	NSAssert([array isKindOfClass:[NSArray class]], @"[TOMJSONAdapter setClassesToConsider:] parameter not a NSArray.");
	for (NSString *string in array)
		NSAssert([string isKindOfClass:[NSString class]], @"[TOMJSONAdapter setClassesToConsider:] array parameter contains object type other than NSString.");
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
		NSData *data = [string dataUsingEncoding:NSStringEncodingConversionAllowLossy];
		JSONRepresentation = [NSJSONSerialization JSONObjectWithData:data options:0 error:error];
		if (*error)
			return nil;
	}

	return [self objectFromObject:JSONRepresentation validationDictionary:nil error:error];
}

#pragma mark - Accessors

- (void)setClassesToConsider:(NSArray *)array
{
	[TOMJSONAdapter validateClassesToConsider:array];
	_classesToConsider = array;
}

#pragma mark - Helpers

- (id)objectFromObject:(id)object validationDictionary:(NSDictionary *)validationDictionary error:(NSError **)error
{
	if (object == nil)
		return nil;

	NSString *type = validationDictionary[kTOMJSONAdapterKeyForType];
	if ([object isKindOfClass:[NSArray class]])
	{
		if (type && [type hasPrefix:@"NSArray"] == NO)
		{
			NSString *errorDescription = [NSString stringWithFormat:@"TOMJSONAdapter invalid object type detcted. Expecting NSArray, got %@.", NSStringFromClass([object class])];
			*error = [NSError errorWithDomain:errorDescription code:kTOMJSONAdapterObjectFailedValidation userInfo:nil];
			object = nil;
		}
		else
		{
			NSArray *array = [type componentsSeparatedByString:@"-"];
			NSString *objectType = (array.count == 2 ? array[1] : nil);
			object = [self arrayFromArray:object objectType:objectType error:error];
		}
	}
	else if ([object isKindOfClass:[NSDictionary class]])
	{
		object = [self objectFromDictionary:object error:error];
		NSString *classString = NSStringFromClass([object class]);
		if ([classString isEqualToString:@"__NSDictionaryM"] || [classString isEqualToString:@"__NSDictionary"]) classString = @"NSDictionary";
		if ([classString isEqualToString:@"__NSArrayM"] || [classString isEqualToString:@"__NSArray"]) classString = @"NSArray";
		if ([classString isEqualToString:@"__NSCFDictionaryM"] || [classString isEqualToString:@"__NSCFDictionary"]) classString = @"NSDictionary";
		if ([classString isEqualToString:@"__NSCFArrayM"] || [classString isEqualToString:@"__NSCFArray"]) classString = @"NSArray";
		if (type && [type isEqualToString:classString] == NO)
		{
			NSString *errorDescription = [NSString stringWithFormat:@"TOMJSONAdapter invalid object type detcted. Expecting %@, got %@.", type, NSStringFromClass([object class])];
			*error = [NSError errorWithDomain:errorDescription code:kTOMJSONAdapterObjectFailedValidation userInfo:nil];
			object = nil;
		}
	}
	else if ([object isKindOfClass:[NSString class]])
	{
		NSString *classString = NSStringFromClass([object class]);
		if ([classString isEqualToString:@"__NSStringM"] || [classString isEqualToString:@"__NSString"]) classString = @"NSString";
		if ([classString isEqualToString:@"__NSCFStringM"] || [classString isEqualToString:@"__NSCFString"]) classString = @"NSString";
		if ([classString isEqualToString:@"__NSDate"]) classString = @"NSDate";
		if ([classString isEqualToString:@"__NSCFDate"]) classString = @"NSDate";
		if (type && [classString hasPrefix:@"NSString"] == NO && [classString hasPrefix:@"NSDate"] == NO)
		{
			NSString *errorDescription = [NSString stringWithFormat:@"TOMJSONAdapter invalid object type detcted. Expecting NSString, got %@.", NSStringFromClass([object class])];
			*error = [NSError errorWithDomain:errorDescription code:kTOMJSONAdapterObjectFailedValidation userInfo:nil];
			object = nil;
		}

		if (type && [type hasPrefix:@"NSDate"])
		{
			NSInteger length = type.length;
			NSString *format = [type stringByReplacingOccurrencesOfString:@"NSDate-" withString:@""];
			NSAssert(format.length == length - 7, @"No timezone or date format indentifier found.");
			NSArray *array = [format componentsSeparatedByString:@"-"];
			NSAssert(array.count > 1, @"No timezone or date format indentifier found.");
			NSString *timeZone = array[0];
			NSAssert(timeZone.length == 3, @"Timezone identifier is not 3 characters.");
			NSString *dateFormat = [format stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@-", timeZone] withString:@""];
			NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
			dateFormatter.timeZone = [NSTimeZone timeZoneWithName:timeZone];
			dateFormatter.dateFormat = dateFormat;
			object = [dateFormatter dateFromString:object];
		}
	}
	else if ([object isKindOfClass:[NSNumber class]])
	{
		if (type && [type hasPrefix:@"NSNumber"] == NO && [type hasPrefix:@"bool"] == NO)
		{
			NSString *errorDescription = [NSString stringWithFormat:@"TOMJSONAdapter invalid object type detcted. Expecting NSNumber, got %@.", NSStringFromClass([object class])];
			*error = [NSError errorWithDomain:errorDescription code:kTOMJSONAdapterObjectFailedValidation userInfo:nil];
			object = nil;
		}

		if ([type hasPrefix:@"bool"])
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

- (NSArray *)arrayFromArray:(NSArray *)array objectType:(NSString *)objectType error:(NSError **)error
{
	NSMutableArray *mutableArray = @[].mutableCopy;
	for (__strong id object in array)
	{
		NSDictionary *validationDictionary = (objectType ? @{kTOMJSONAdapterKeyForType: objectType} : nil);
		object = [self objectFromObject:object validationDictionary:validationDictionary error:error];
		if (*error)
			return nil;

		if (object)
			[mutableArray addObject:object];
	}

	return [NSArray arrayWithArray:mutableArray];
}

- (id)objectFromDictionary:(NSDictionary *)dictionary error:(NSError **)error
{
	Class class = [self classForUniqueIdentifiers:dictionary.allKeys];
	if (class == [NSDictionary class])
		return dictionary;

	id object = [[class alloc] init];
	NSDictionary *validationDictionary = [self validationDictionaryForClass:class];
	for (NSString *key in validationDictionary.allKeys)
	{
		NSDictionary *propertyValidationDictionary = validationDictionary[key];
		id value = dictionary[key];
		NSNumber *required = ([propertyValidationDictionary.allKeys containsObject:kTOMJSONAdapterKeyForRequired] ? propertyValidationDictionary[kTOMJSONAdapterKeyForRequired] : @YES); // Default to YES unless dictionary contains a kTOMJSONAdapterKeyForRequired key.
		if (required.boolValue && [dictionary.allKeys containsObject:key] == NO)
		{
			NSString *errorString = [NSString stringWithFormat:@"TOMJSONAdapter missing required parameter %@.", key];
			*error = [NSError errorWithDomain:errorString code:kTOMJSONAdapterObjectFailedValidation userInfo:nil];
			return nil;
		}
		if (nil == value)
			continue; // Property doesn't exist or is nil.
		value = [self objectFromObject:value validationDictionary:propertyValidationDictionary error:error];
		if (*error)
			return nil;

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
	for (NSString *classString in classesToConsiderArray)
	{
		Class<TOMJSONAdapterProtocol> class = NSClassFromString(classString);
		NSAssert([(NSObject *)class conformsToProtocol:@protocol(TOMJSONAdapterProtocol)], @"Models must conform to the TRKJSONAdapterProtocol protocol.");
		NSMutableArray *mutableArray = @[].mutableCopy;
		NSDictionary *validationDictionary = [self validationDictionaryForClass:class];
		for (NSString *key in validationDictionary.allKeys)
		{
			NSDictionary *propertyValidationDictionary = validationDictionary[key];
			NSNumber *identify = propertyValidationDictionary[kTOMJSONAdapterKeyForIdentify];
			if (identify.boolValue)
				[mutableArray addObject:key];
		}
		NSSet *uniqueIdentifiersSet = [NSSet setWithArray:mutableArray];
		NSSet *objectSet = [NSSet setWithArray:array];
		if ([uniqueIdentifiersSet isSubsetOfSet:objectSet])
			return class;
	}
	// If none of the kClassesToConsiderStringsArray match for unique identifier, just create a NSDictionary.
	return [NSDictionary class];
}

- (NSDictionary *)validationDictionaryForClass:(Class)class
{
	if (self.objectValidationDictionary == nil)
		self.objectValidationDictionary = @{}.mutableCopy;
	NSString *key = NSStringFromClass(class);
	NSDictionary *dictionary = self.objectValidationDictionary[key];
	if (dictionary == nil)
	{
		dictionary = [class JSONAdapterSchema];
		NSArray *keyValidationArray = @[kTOMJSONAdapterKeyForIdentify, kTOMJSONAdapterKeyForMap, kTOMJSONAdapterKeyForRequired, kTOMJSONAdapterKeyForType];
		for (NSString *objectKey in dictionary.allKeys)
		{
			NSDictionary *objectDictionary = dictionary[objectKey];
			for (NSString *key in objectDictionary.allKeys)
			{
				NSAssert([keyValidationArray containsObject:key], @"Validation key for class %@ is invalid. Key was %@, expecting one of kTOMJSONAdapterKeyForIdentify, kTOMJSONAdapterKeyForMap, kTOMJSONAdapterKeyForRequired, kTOMJSONAdapterKeyForType.", NSStringFromClass(class), key);
				id value = objectDictionary[key];
				if ([key isEqualToString:kTOMJSONAdapterKeyForType] || [key isEqualToString:kTOMJSONAdapterKeyForMap])
					NSAssert([value isKindOfClass:[NSString class]], @"Validation value for key %@ in class %@ is not a string.", key, NSStringFromClass(class));
				else if ([key isEqualToString:kTOMJSONAdapterKeyForIdentify] || [key isEqualToString:kTOMJSONAdapterKeyForRequired])
					NSAssert([value isKindOfClass:[NSNumber class]], @"Validation value for property %@ and key %@ in class %@ is not a number.", objectKey, key, NSStringFromClass(class));
			}
		}
		self.objectValidationDictionary[key] = dictionary;
	}
	return dictionary;
}

@end
