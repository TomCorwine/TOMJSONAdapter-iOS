//
//  TOMJSONAdapter.h
//  Tom's iPhone Apps
//
//  Created by Tom Corwine on 2/13/13.
//

#import <Foundation/Foundation.h>
#import <Availability.h>

#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_4_3
	#error TOMJSONAdapter requires iOS 4.3 or later
#endif

extern const NSInteger kTOMJSONAdapterInvalidObjectDetected;
extern const NSInteger kTOMJSONAdapterObjectFailedValidation;

extern NSString *const kTOMJSONAdapterKeyForIdentify;
extern NSString *const kTOMJSONAdapterKeyForRequired;
extern NSString *const kTOMJSONAdapterKeyForMap;
extern NSString *const kTOMJSONAdapterKeyForType;

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
 	@"is_enabled": @{
 		kTOMJSONAdapterKeyForRequired: @NO,
 		kTOMJSONAdapterKeyForMap: @"enabled",
 		kTOMJSONAdapterKeyForType: @"bool",
 		},
 	@"type": @{
 		kTOMJSONAdapterKeyForRequired: @NO,
 		kTOMJSONAdapterKeyForType: [NSNumber class]
 		}
 }
 */
+ (NSDictionary *)JSONAdapterSchema;

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
