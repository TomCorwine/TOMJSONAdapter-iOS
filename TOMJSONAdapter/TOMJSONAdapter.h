//
//  TOMJSONAdapter.h
//  TOMJSONAdapter
//
//  Created by Tom Corwine on 2/13/13.
//

#import <Foundation/Foundation.h>
#import <Availability.h>

#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_5_0
	#error TOMJSONAdapter requires iOS 5.0 or later
#endif

@interface TOMJSONAdapterBool : NSObject
// Dummy class to type BOOLEAN
@end

extern const NSInteger kTOMJSONAdapterInvalidObjectDetected;
extern const NSInteger kTOMJSONAdapterObjectFailedValidation;
extern const NSInteger kTOMJSONAdapterInvalidJSON;

extern NSString *const kTOMJSONAdapterKeyForIdentify;
extern NSString *const kTOMJSONAdapterKeyForRequired;
extern NSString *const kTOMJSONAdapterKeyForMap;
extern NSString *const kTOMJSONAdapterKeyForType;
extern NSString *const kTOMJSONAdapterKeyForArrayContents;
extern NSString *const kTOMJSONAdapterKeyForDateFormat;

@protocol TOMJSONAdapterProtocol <NSObject>
/*
 Format for JSONAdapterSchema dictionary:
 @{
 	@"oid": @{
 		kTOMJSONAdapterKeyForIdentify: @YES,
 		kTOMJSONAdapterKeyForMap: @"objectID",
 		kTOMJSONAdapterKeyForType: [NSString class]
 		},
 	@"name": @{,
 		kTOMJSONAdapterKeyForType: [NSString class]
 		},
 	@"count": @{
 		kTOMJSONAdapterKeyForType: [NSNumber class]
 		},
  @"items": @{
    kTOMJSONAdapterKeyForType: [NSArray class],
    kTOMJSONAdapterKeyForArrayContents: [TOMEntry class]
    },
  @"items": @{
    kTOMJSONAdapterKeyForType: [NSDate class],
    kTOMJSONAdapterKeyForDateFormat: @"yyyy-MM-dd'T'HH:mm:ss'Z'"
    },
 	@"is_enabled": @{
 		kTOMJSONAdapterKeyForRequired: @NO,
 		kTOMJSONAdapterKeyForMap: @"enabled",
 		kTOMJSONAdapterKeyForType: [TOMJSONAdapterBool class],
 		},
 	@"type": @{
 		kTOMJSONAdapterKeyForRequired: @NO,
 		kTOMJSONAdapterKeyForType: [NSNumber class]
 		}
 }
 */
+ (NSDictionary *)JSONAdapterSchema;

@optional
- (id)initWithDictionary:(NSDictionary *)dictionary;

@end

@interface TOMJSONAdapter : NSObject
/*
 @pramas
 array: A NSArray of NSString objects declaring which classes to consider when parsing JSON.
 */
@property (nonatomic, strong) NSArray *classesToConsider;

+ (void)setDefaultClassesToConsider:(NSArray *)array;
- (id)initWithClassesToConsider:(NSArray *)array;

+ (instancetype)JSONAdapter;

/*
 @pramas
 JSONRepresentation can be either a NSArray, NSDictionary or NSString.
 */
- (id)createFromJSONRepresentation:(id)JSONRepresentation error:(NSError **)error;

@end
