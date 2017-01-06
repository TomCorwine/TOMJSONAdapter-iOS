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
NSString *const kTOMJSONAdapterKeyForFallbackToNumber = @"kTOMJSONAdapterKeyForFallbackToNumber";

NSString *const kTOMJSONAdapterKeyForType = @"kTOMJSONAdapterKeyForType";

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

- (id)createFromJSONRepresentation:(id)JSONRepresentation rootClass:(__unsafe_unretained Class)rootClass errors:(NSArray *__autoreleasing *)errors
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

    NSString *errorMessage;
    id root = [self objectFromObject:JSONRepresentation validationDictionary:validationDictionary errorMessage:&errorMessage];

    if (errorMessage)
    {
        NSString *string = [self errorString:errorMessage forExpectedClass:rootClass accessor:@"rootObject"];
        [self createErrorWithType:kTOMJSONAdapterObjectFailedValidation additionalInfo:string];
    }

    if (NO == [[root class] isEqual:rootClass]) {
        [self createErrorWithType:kTOMJSONAdapterObjectFailedValidation additionalInfo:nil];
    }

    if (self.errors.count > 0 && errors) {
        *errors = [NSArray arrayWithArray:self.errors];
    }

    return root;
}

#pragma mark - Object Creation Helpers

- (id)objectFromObject:(id)object validationDictionary:(NSDictionary *)validationDictionary errorMessage:(NSString **)errorMessage
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
            object = [self arrayFromArray:object objectType:arrayClassType errorMessage:errorMessage];
        }
        else
        {
            *errorMessage = [self errorStringForExpectedClass:[NSArray class] actualClass:[object class]];

            object = nil;
        }
    }
    else if ([classType isEqual:[NSString class]])
    {
        NSNumber *shouldFallbackToNumber = self.defaultValidationDictionary[kTOMJSONAdapterKeyForFallbackToNumber];
        NSNumber *classShouldFallbackToNumber = validationDictionary[kTOMJSONAdapterKeyForFallbackToNumber];

        if (classShouldFallbackToNumber) {
            shouldFallbackToNumber = classShouldFallbackToNumber;
        }

        if ([object isKindOfClass:[NSString class]])
        {
            // No work needed in this case.
        }
        else if ([object isKindOfClass:[NSNumber class]] && shouldFallbackToNumber.boolValue)
        {
            object = [object stringValue];
        }
        else
        {
            *errorMessage = [self errorStringForExpectedClass:[NSString class] actualClass:[object class]];

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

            if (nil == object) {
                *errorMessage = @"Unable to parse date string";
            }
        }
        else
        {
            *errorMessage = [self errorStringForExpectedClass:[NSDate class] actualClass:[object class]];

            object = nil;
        }
    }
    else if ([classType isEqual:[NSNumber class]])
    {
        if (NO == [object isKindOfClass:[NSNumber class]])
        {
            *errorMessage = [self errorStringForExpectedClass:[NSNumber class] actualClass:[object class]];

            object = nil;
        }
    }
    else if ([object isKindOfClass:[NSDictionary class]])
    {
        object = [self objectOfType:classType fromDictionary:object];
    }
    else
    {
        *errorMessage = [self errorStringForExpectedClass:[NSDictionary class] actualClass:[object class]];

        object = nil;
    }

    return object;
}

- (NSArray *)arrayFromArray:(NSArray *)array objectType:(Class)objectType errorMessage:(NSString **)errorMessage
{
    NSMutableArray *mutableArray = @[].mutableCopy;
    for (__strong id object in array)
    {
        NSDictionary *validationDictionary = (objectType ? @{kTOMJSONAdapterKeyForType: objectType} : nil);
        object = [self objectFromObject:object validationDictionary:validationDictionary errorMessage:errorMessage];

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

    if ([class instancesRespondToSelector:@selector(initWithDictionary:)]) {
        return [[class alloc] initWithDictionary:dictionary]; // Alternate way of initializing object.
    }

    id object;

    if ([class respondsToSelector:@selector(JSONAdapterFactory)]) {
        object = [class JSONAdapterFactory];
    } else {
        object = [[class alloc] init];
    }

    if ([object respondsToSelector:@selector(JSONAdapterWillConfigureWithDictionary:)])
    {
        NSDictionary *newDictionary = [object JSONAdapterWillConfigureWithDictionary:dictionary.mutableCopy];
        if (newDictionary) {
            dictionary = newDictionary;
        }
    }

    NSDictionary *validationDictionary = [self validationDictionaryForClass:class];

    for (NSString *key in validationDictionary.allKeys)
    {
        NSDictionary *propertyValidationDictionary = validationDictionary[key];
        NSString *map = propertyValidationDictionary[kTOMJSONAdapterKeyForMap];
        NSString *accessor = (map ?: key); // Map to accessor.

        id value;

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

        if (NSNotFound != [key rangeOfString:@"."].location) // YES if key contains a period
        {
            NSArray *keys = [key componentsSeparatedByString:@"."];

            if (nil == map) {
                accessor = keys.lastObject;
            }

            id newObject = dictionary;

            for (NSString *subKey in keys)
            {
                BOOL isLastKey = [keys.lastObject isEqualToString:subKey];

                if ([newObject isKindOfClass:[NSDictionary class]])
                {
                    newObject = newObject[subKey];
                }
                /*
                else if ([newObject isKindOfClass:[NSArray class]])
                {
                    Class arrayContentsClass = propertyValidationDictionary[kTOMJSONAdapterKeyForArrayContents];

                    Class propertyClass = [self returnTypeClassForClass:[object class] property:accessor];
                    if (propertyClass != [NSArray class])
                    {
                        NSString *string = [self errorStringForExpectedClass:[NSNumber class] actualClass:[object class]];
                        [self createErrorWithType:kTOMJSONAdapterObjectFailedValidation additionalInfo:string];

                        continue;
                    }

                    NSString *errorMessage;
                    NSArray *array = [self arrayFromArray:newObject objectType:arrayContentsClass errorMessage:&errorMessage];

                    if (errorMessage)
                    {
                        NSString *string = [self errorString:errorMessage forExpectedClass:[object class] accessor:accessor];
                        [self createErrorWithType:kTOMJSONAdapterObjectFailedValidation additionalInfo:string];
                    }

                    [object setValue:array forKey:accessor];

                    continue;
                }
                 */
                else if (newObject && NO == isLastKey) // Subkey exists, but is not a dictionary.
                {
                    NSString *string = [NSString stringWithFormat:@"Subkey: '%@' is not a NSDictonary", subKey];
                    [self createErrorWithType:kTOMJSONAdapterObjectFailedValidation additionalInfo:string];
                }
                else if (NO == required.boolValue)
                {
                    // It doesn’t exist and it doesn’t matter.
                }
                else
                {
                    NSString *string = [NSString stringWithFormat:@"Unable to find subkey: '%@' on '%@'", subKey, key];
                    [self createErrorWithType:kTOMJSONAdapterObjectFailedValidation additionalInfo:string];
                }
            }

            value = newObject;
        }
        else
        {
            value = dictionary[key];
        }

        if (nil == value) // Property doesn't exist or is nil.
        {
            if (required.boolValue) // If this property is required, this is an error.
            {
                NSString *string = [NSString stringWithFormat:@"Missing required parameter '%@'", key];
                [self createErrorWithType:kTOMJSONAdapterObjectFailedValidation additionalInfo:string];
            }

            continue;
        }

        if ([value isKindOfClass:[NSNull class]]) {
            continue; // property is a NSNull object, just let it be nil.
        }

        NSObjectReturnType returnType = [self returnTypeForClass:[object class] property:accessor];

        switch (returnType)
        {
            case NSObjectReturnTypeNotFound:
            case NSObjectReturnTypeUnknown:
            {
                NSString *string = [NSString stringWithFormat:@"Unknown return type on '%@' for key '%@'.", NSStringFromClass([object class]), accessor];
                [self createErrorWithType:kTOMJSONAdapterObjectFailedValidation additionalInfo:string];

                continue;
                break;
            }
            case NSObjectReturnTypeFloat:
            case NSObjectReturnTypeDouble:
            case NSObjectReturnTypeInteger:
            case NSObjectReturnTypeBOOL:
            {
                if (NO == [value isKindOfClass:[NSNumber class]])
                {
                    NSString *errorMessage = [self errorStringForExpectedClass:[NSNumber class] actualClass:[value class]];
                    NSString *string = [self errorString:errorMessage forExpectedClass:[object class] accessor:accessor];
                    [self createErrorWithType:kTOMJSONAdapterObjectFailedValidation additionalInfo:string];

                    continue;
                }

                break;
            }
            case NSObjectReturnTypeID:
            {
                Class propertyClass = [self returnTypeClassForClass:[object class] property:accessor];

                if (propertyClass)
                {
                    NSMutableDictionary *mutableDictionary = propertyValidationDictionary.mutableCopy;
                    mutableDictionary[kTOMJSONAdapterKeyForType] = propertyClass;
                    propertyValidationDictionary = mutableDictionary.copy;
                }

                NSString *errorMessage;
                value = [self objectFromObject:value validationDictionary:propertyValidationDictionary errorMessage:&errorMessage];

                if (errorMessage)
                {
                    NSString *string = [self errorString:errorMessage forExpectedClass:[object class] accessor:accessor];
                    [self createErrorWithType:kTOMJSONAdapterObjectFailedValidation additionalInfo:string];
                }

                break;
            }
        }

        [object setValue:value forKey:accessor];
    }

    if ([object respondsToSelector:@selector(JSONAdapterDidConfigureWithDictionary:)]) {
        [object JSONAdapterDidConfigureWithDictionary:dictionary];
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
        NSAssert([class respondsToSelector:@selector(JSONAdapterSchema)], @"%@ must implement JSONAdapterSchema class method.", NSStringFromClass(class));

        dictionary = @{};
        // Allow for models to have a super class implementation of properties.
        Class aClass = class;
        for (; aClass; aClass = [aClass superclass])
        {
            if ([aClass respondsToSelector:@selector(JSONAdapterSchema)])
            {
                NSMutableDictionary *superDictionary = [aClass JSONAdapterSchema].mutableCopy;
                [superDictionary addEntriesFromDictionary:dictionary];
                dictionary = superDictionary.copy;
            }
        }

        NSArray *keyValidationArray = @[
                        kTOMJSONAdapterKeyForMap,
                        kTOMJSONAdapterKeyForRequired,
                        kTOMJSONAdapterKeyForType,
                        kTOMJSONAdapterKeyForArrayContents,
                        kTOMJSONAdapterKeyForDateFormat,
                        kTOMJSONAdapterKeyForFallbackToNumber
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
                else if ([key isEqualToString:kTOMJSONAdapterKeyForRequired] || [key isEqualToString:kTOMJSONAdapterKeyForFallbackToNumber])
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

- (NSString *)errorStringForExpectedClass:(Class)expectedClass actualClass:(Class)actualClass
{
    NSString *string = [NSString stringWithFormat:@"Expecting %@, got %@", NSStringFromClass(expectedClass), NSStringFromClass(actualClass)];

    return string;
}

- (NSString *)errorString:(NSString *)errorString forExpectedClass:(Class)class accessor:(NSString *)accessor
{
    NSString *string = [NSString stringWithFormat:@"%@ on %@ for property '%@'", errorString, NSStringFromClass(class), accessor];
    return string;
}

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
        string = [NSString stringWithFormat:@"%@ - %@.", string, info];
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
    // Allow for models to have a super class implementation of properties.
    Class aClass = class;
    for (; aClass; aClass = [aClass superclass])
    {
        unsigned int outCount;
        objc_property_t *properties = class_copyPropertyList(aClass, &outCount);

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
    }

    return nil;
}

@end
