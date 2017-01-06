//
//  TOMJSONAdapter.h
//  TOMJSONAdapter
//
//  Created by Tom Corwine on 2/13/13.
//

#import <Foundation/Foundation.h>
#import <Availability.h>

#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_5_0
//	#error TOMJSONAdapter requires iOS 5.0 or later
#endif

extern const NSInteger kTOMJSONAdapterInvalidObjectDetected;
extern const NSInteger kTOMJSONAdapterObjectFailedValidation;
extern const NSInteger kTOMJSONAdapterInvalidJSON;

//extern NSString *const kTOMJSONAdapterKeyForIdentify;
extern NSString *const kTOMJSONAdapterKeyForRequired;
extern NSString *const kTOMJSONAdapterKeyForMap;
extern NSString *const kTOMJSONAdapterKeyForArrayContents;
extern NSString *const kTOMJSONAdapterKeyForDateFormat;
extern NSString *const kTOMJSONAdapterKeyForFallbackToNumber;

@protocol TOMJSONAdapterProtocol <NSObject>
/*
 Format for JSONAdapterSchema dictionary:
 @{
 	@"oid": @{
 		kTOMJSONAdapterKeyForMap: @"objectID"
 		},
 	@"name": @{
 		},
 	@"count": @{
    kTOMJSONAdapterKeyForFallbackToNumber: @YES
 		},
  @"items": @{
    kTOMJSONAdapterKeyForArrayContents: [TOMEntry class]
    },
  @"items": @{
    kTOMJSONAdapterKeyForDateFormat: @"yyyy-MM-dd-HH:mm:ss"
    },
 	@"is_enabled": @{
 		kTOMJSONAdapterKeyForRequired: @NO,
 		kTOMJSONAdapterKeyForMap: @"enabled"
 		},
 	@"type": @{
 		kTOMJSONAdapterKeyForRequired: @NO
 		}
 }
 */
+ (NSDictionary *)JSONAdapterSchema;

@optional

// Specify a factory class method used to create new object. If not implemented,
// object will be created using [[Class alloc] init].
+ (instancetype)JSONAdapterFactory;

// Hook to do work after object is created, but before it is configured.
// If a NSDictionary is returned, it is used instead of the supplied dictionary.
// This allows for modification of dictionary before object configuration.
// If nil is returned, then original dictionary is used. No need to pass original
// dictionary through.
- (NSDictionary *)JSONAdapterWillConfigureWithDictionary:(NSMutableDictionary *)dictionary;

// Hook to do work after object is configured.
// NSDictionary provided is the dictionary that was used to configure the object.
- (void)JSONAdapterDidConfigureWithDictionary:(NSDictionary *)dictionary;

// Alternate way of creating an object
- (id)initWithDictionary:(NSDictionary *)dictionary;

@end

@interface TOMJSONAdapter : NSObject

/*
 Right now only supports kTOMJSONAdapterKeyForRequired and kTOMJSONAdapterKeyForFallbackToNumber.
 */
@property (nonatomic, strong) NSDictionary *defaultValidationDictionary;

+ (instancetype)JSONAdapter;

/*
 @pramas
 JSONRepresentation can be either a NSArray, NSDictionary, NSString or NSData.
 rootClass is the class root object of response is expected to be (optional).
 */
- (id)createFromJSONRepresentation:(id)JSONRepresentation rootClass:(Class)rootClass errors:(NSArray **)errors;

@end
