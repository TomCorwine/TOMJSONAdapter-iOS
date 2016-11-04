//
//  TOMJSONAdapter.m
//  TOMJSONAdapter
//
//  Created by Tom Corwine on 2/13/13.
//

#import "TOMJSONAdapter.h"

#import <UIKit/UIKit.h>
#import <objc/runtime.h>

typedef NS_ENUM(u_int8_t) {
    NSObjectReturnTypeNotFound,
    NSObjectReturnTypeUnknown,
    NSObjectReturnTypeFloat,
    NSObjectReturnTypeDouble,
    NSObjectReturnTypeInteger,
    NSObjectReturnTypeBOOL,
    NSObjectReturnTypeID
} NSObjectReturnType;

const NSInteger kTOMJSONAdapterInvalidObjectDetected = 100;
const NSInteger kTOMJSONAdapterObjectFailedValidation = 101;
const NSInteger kTOMJSONAdapterInvalidJSON = 102;

//NSString *const kTOMJSONAdapterKeyForIdentify = @"kTOMJSONAdapterKeyForIdentify";
NSString *const kTOMJSONAdapterKeyForRequired = @"kTOMJSONAdapterKeyForRequired";
NSString *const kTOMJSONAdapterKeyForMap = @"kTOMJSONAdapterKeyForMap";
NSString *const kTOMJSONAdapterKeyForArrayContents = @"kTOMJSONAdapterKeyForArrayContents";
NSString *const kTOMJSONAdapterKeyForDateFormat = @"kTOMJSONAdapterKeyForDateFormat";

NSString *const kTOMJSONAdapterKeyForType = @"kTOMJSONAdapterKeyForType";

/*
@implementation TOMJSONAdapterBool
@end
*/

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
    if ([JSONRepresentation isKindOfClass:[NSData class]]) {
        JSONRepresentation = [[NSString alloc] initWithData:JSONRepresentation encoding:NSUTF8StringEncoding];

        if (nil == JSONRepresentation) {
            [self createErrorWithType:kTOMJSONAdapterInvalidJSON additionalInfo:nil];
            return nil;
        }
    }

    if ([JSONRepresentation isKindOfClass:[NSString class]])
    {
        NSString *string = JSONRepresentation;
        NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];

        NSError *error;
        JSONRepresentation = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];

        if (error) {
            [self.errors addObject:error];
            return nil; // No point in continuing if JSON parsing failed.
        }
    }

    NSDictionary *validationDictionary = (rootClass ? @{kTOMJSONAdapterKeyForType: rootClass} : nil);

    id root = [self objectFromObject:JSONRepresentation validationDictionary:validationDictionary];

    if (NO == [[root class] isEqual:rootClass]) {
        [self createErrorWithType:kTOMJSONAdapterObjectFailedValidation additionalInfo:nil];
    }

    if (self.errors.count > 0 && errors) {
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
            [self createErrorWithType:kTOMJSONAdapterObjectFailedValidation additionalInfo:errorDescription];

            object = nil;
        }
    }
    else if ([classType isEqual:[NSString class]])
    {
        if (NO == [object isKindOfClass:[NSString class]])
        {
            NSString *errorDescription = [NSString stringWithFormat:@"Expecting NSString, got %@", NSStringFromClass([object class])];
            [self createErrorWithType:kTOMJSONAdapterObjectFailedValidation additionalInfo:errorDescription];

            object = nil;
        }
    }
    else if ([classType isEqual:[NSDate class]])
    {
        if ([object isKindOfClass:[NSString class]])
        {
            NSString *dateFormat = validationDictionary[kTOMJSONAdapterKeyForDateFormat];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0]; // TODO: Implement time zone info
            dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            dateFormatter.dateFormat = dateFormat;
            object = [dateFormatter dateFromString:object];
            NSLog(@"%@", object);
        }
        else
        {
            NSString *errorDescription = [NSString stringWithFormat:@"Expecting NSDate, got %@", NSStringFromClass([object class])];
            [self createErrorWithType:kTOMJSONAdapterObjectFailedValidation additionalInfo:errorDescription];

            object = nil;
        }
    }
    else if ([classType isEqual:[NSNumber class]])
    {
        if (NO == [object isKindOfClass:[NSNumber class]])
        {
            NSString *errorDescription = [NSString stringWithFormat:@"Expecting NSNumber, got %@", NSStringFromClass([object class])];
            [self createErrorWithType:kTOMJSONAdapterObjectFailedValidation additionalInfo:errorDescription];

            object = nil;
        }
    }
    else if ([object isKindOfClass:[NSDictionary class]])
    {
        object = [self objectOfType:classType fromDictionary:object];
    }
    else
    {
        NSString *errorDescription = [NSString stringWithFormat:@"Expecting NSDictionary, got %@", NSStringFromClass([object class])];
        [self createErrorWithType:kTOMJSONAdapterObjectFailedValidation additionalInfo:errorDescription];

        object = nil;
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

- (id)objectOfType:(Class)class fromDictionary:(NSDictionary *)dictionary
{
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
        NSString *map = propertyValidationDictionary[kTOMJSONAdapterKeyForMap];
        NSString *accessorKey = (map ?: key); // Map to accessor.

        id value;

        if (NSNotFound != [key rangeOfString:@"."].location) // YES if key contains a period
        {
            NSArray *keys = [key componentsSeparatedByString:@"."];

            if (nil == map)
            {
                NSString *string = [NSString stringWithFormat:@"A map key is required with dot notation for key %@.", key];
                [self createErrorWithType:kTOMJSONAdapterObjectFailedValidation additionalInfo:string];

                continue;
            }

            id newObject = dictionary;

            for (NSString *subKey in keys)
            {
                if ([newObject isKindOfClass:[NSDictionary class]])
                {
                    newObject = newObject[subKey];
                }
                else if ([newObject isKindOfClass:[NSArray class]])
                {
                    Class class = propertyValidationDictionary[kTOMJSONAdapterKeyForArrayContents];
                    NSArray *array = [self arrayFromArray:newObject objectType:class];

                    [object setValue:array forKey:accessorKey];
                    continue;
                }
                else
                {
                    NSString *string = [NSString stringWithFormat:@"Unable to find subkey: %@ on %@", subKey, key];
                    [self createErrorWithType:kTOMJSONAdapterObjectFailedValidation additionalInfo:string];

                    continue;
                }
            }

            value = newObject;
        }
        else
        {
            value = dictionary[key];
        }

        NSNumber *required;
        if ([propertyValidationDictionary.allKeys containsObject:kTOMJSONAdapterKeyForRequired])
        {
            required = propertyValidationDictionary[kTOMJSONAdapterKeyForRequired];
        }
        else
        {
            // Default to NO unless dictionary contains a kTOMJSONAdapterKeyForRequired key.
            required = self.defaultValidationDictionary[kTOMJSONAdapterKeyForRequired];
        }

        if (required.boolValue && NO == [dictionary.allKeys containsObject:key])
        {
            NSString *string = [NSString stringWithFormat:@"Missing required parameter %@", key];
            [self createErrorWithType:kTOMJSONAdapterObjectFailedValidation additionalInfo:string];

            continue;
        }

        if (nil == value) {
            continue; // Property doesn't exist or is nil.
        }

        NSObjectReturnType returnType = [self returnTypeForClass:[object class] property:accessorKey];

        switch (returnType)
        {
            case NSObjectReturnTypeNotFound:
            case NSObjectReturnTypeUnknown:
            {
                NSString *string = @"Unknown return type.";
                [self createErrorWithType:kTOMJSONAdapterObjectFailedValidation additionalInfo:string];

                continue;
                break;
            }
            case NSObjectReturnTypeFloat:
            case NSObjectReturnTypeDouble:
            {
                // TODO: Validate
                break;
            }
            case NSObjectReturnTypeInteger:
            {
                // TODO: Validate
                break;
            }
            case NSObjectReturnTypeBOOL:
            {
                // TODO: Validate
                break;
            }
            case NSObjectReturnTypeID:
            {
                Class propertyClass = [self returnTypeClassForClass:[object class] property:accessorKey];

                if (propertyClass)
                {
                    NSMutableDictionary *mutableDictionary = propertyValidationDictionary.mutableCopy;
                    mutableDictionary[kTOMJSONAdapterKeyForType] = propertyClass;
                    propertyValidationDictionary = mutableDictionary.copy;
                }

                value = [self objectFromObject:value validationDictionary:propertyValidationDictionary];
                break;
            }
        }

        // TODO: Take a look here and see if we can incorporate read-only and customer setter check.
        // https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtPropertyIntrospection.html#//apple_ref/doc/uid/TP40008048-CH101-SW1

        [object setValue:value forKey:accessorKey];
    }

    return object;
}

#pragma mark - Class Identification
/*
- (Class)classForUniqueIdentifiers:(NSArray *)array
{
    for (Class<TOMJSONAdapterProtocol> class in @[])
    {
        BOOL conforms = [(NSObject *)class conformsToProtocol:@protocol(TOMJSONAdapterProtocol)];
        NSAssert(conforms, [[self class] errorMessageWithClassNameForErrorMessage:@"Classes must conform to the TRKJSONAdapterProtocol protocol."]);

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
        NSArray *keyValidationArray = @[
                        kTOMJSONAdapterKeyForMap,
                        kTOMJSONAdapterKeyForRequired,
                        kTOMJSONAdapterKeyForType,
                        kTOMJSONAdapterKeyForArrayContents,
                        kTOMJSONAdapterKeyForDateFormat
                        ];

        for (NSString *objectKey in dictionary.allKeys)
        {
            NSDictionary *objectDictionary = dictionary[objectKey];

            for (NSString *key in objectDictionary.allKeys)
            {
                NSString *items = [keyValidationArray componentsJoinedByString:@", "];
                NSString *errorDescription = [NSString stringWithFormat:@"Validation key for class %@ is invalid. Key was %@, expecting one of %@.", NSStringFromClass(class), key, items];
                NSAssert([keyValidationArray containsObject:key], [self errorMessageWithClassNameForErrorMessage:errorDescription]);
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
                else if ([key isEqualToString:kTOMJSONAdapterKeyForRequired])
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

- (void)createErrorWithType:(NSUInteger)errorType additionalInfo:(NSString *)info
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
        string = [NSString stringWithFormat:@"%@ — %@.", string, info];
    } else {
        string = [string stringByAppendingString:@"."];
    }

    NSError *error = [NSError errorWithDomain:string code:errorType userInfo:nil];

    [self.errors addObject:error];
}

- (NSString *)errorMessageWithClassNameForErrorMessage:(NSString *)errorMessage
{
    return [NSString stringWithFormat:@"%@: %@", NSStringFromClass([self class]), errorMessage];
}

#pragma mark - Property Detection

- (NSObjectReturnType)returnTypeForClass:(Class)class property:(NSString *)name
{
    objc_property_t property = [self propertyForClass:class propertyName:name];

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
             || strcmp(rawPropertyType, @encode(NSUInteger)) == 0)
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

- (Class)returnTypeClassForClass:(Class)class property:(NSString *)name
{
    objc_property_t property = [self propertyForClass:class propertyName:name];
    const char *type = property_getAttributes(property);

    NSString *typeString = [NSString stringWithUTF8String:type];
    NSArray *attributes = [typeString componentsSeparatedByString:@","];
    NSString *typeAttribute = attributes.firstObject;
    NSString *propertyType = [typeAttribute substringFromIndex:1];

    propertyType = [propertyType substringFromIndex:1]; // Remove @ from front
    NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:@"\""]; // Remove surrounding quotes
    NSString *typeClassName = [propertyType stringByTrimmingCharactersInSet:characterSet];

    Class returnClass = NSClassFromString(typeClassName);
    return returnClass;
}

- (objc_property_t)propertyForClass:(Class)class propertyName:(NSString *)name
{
    unsigned int outCount;
    objc_property_t *properties = class_copyPropertyList(class, &outCount);

    for (int i = 0; i < outCount; i++)
    {
        objc_property_t property = properties[i];

        const char *propertyName = name.UTF8String;
        const char *currentPropertyName = property_getName(property);

        if (0 == strcmp(propertyName, currentPropertyName)) {
            free(properties);
            return property;
        }
    }

    free(properties);

    return nil;
}

@end
