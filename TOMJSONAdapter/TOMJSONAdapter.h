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

@protocol TOMJSONAdapterProtocol <NSObject>
/*
 Format for JSONAdapterSchema dictionary:
 @{
 	@"oid": @{
 		kTOMJSONAdapterKeyForMap: @"objectID"
 		},
 	@"name": @{,
 		},
 	@"count": @{
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

- (void)JSONAdapterWillConfigureWithDictionary:(NSDictionary *)dictionary;
- (void)JSONAdapterDidConfigureWithDictionary:(NSDictionary *)dictionary;

@optional

// Alternate way of creating an object
- (id)initWithDictionary:(NSDictionary *)dictionary;

@end

@interface TOMJSONAdapter : NSObject

/*
 Right now only supports kTOMJSONAdapterKeyForRequired.
 */
@property (nonatomic, strong) NSDictionary *defaultValidationDictionary;

+ (instancetype)JSONAdapter;

/*
 @pramas
 JSONRepresentation can be either a NSArray, NSDictionary, NSString or NSData.
 rootClass is the class root object of response is expected to be (optional).
 */
- (id)createFromJSONRepresentation:(id)JSONRepresentation expectedRootClass:(Class)rootClass errors:(NSArray **)errors;

@end
