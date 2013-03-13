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

const static NSInteger kTOMJSONAdapterInvalidObjectDetected = 100;
const static NSInteger kTOMJSONAdapterObjectFailedValidation = 101;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"
static NSString *kTOMJSONAdapterKeyForIdentify = @"kTOMJSONAdapterKeyForIdentify";
static NSString *kTOMJSONAdapterKeyForRequired = @"kTOMJSONAdapterKeyForRequired";
static NSString *kTOMJSONAdapterKeyForMap = @"kTOMJSONAdapterKeyForMap";
static NSString *kTOMJSONAdapterKeyForType = @"kTOMJSONAdapterKeyForType";
#pragma clang diagnostic pop

@protocol TOMJSONAdapterProtocol <NSObject>
/*
 Format for JSONAdapterSchema dictionary:
 @{
 	@"oid": @{
 		kTOMJSONAdapterKeyForIdentify: @YES,
 		kTOMJSONAdapterKeyForMap: @"objectID",
 		kTOMJSONAdapterKeyForType: @"NSString"
 		},
 	@"name": @{,
 		kTOMJSONAdapterKeyForType: @"NSString"
 		},
 	@"count": @{
 		kTOMJSONAdapterKeyForType: @"NSNumber"
 		},
 	@"is_enabled": @{
 		kTOMJSONAdapterKeyForRequired: @NO,
 		kTOMJSONAdapterKeyForMap: @"enabled",
 		kTOMJSONAdapterKeyForType: @"bool",
 		},
 	@"type": @{
 		kTOMJSONAdapterKeyForRequired: @NO,
 		kTOMJSONAdapterKeyForType: @"NSNumber"
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

/*
 @pramas
 JSONRepresentation can be either a NSArray, NSDictionary or NSString.
 */
- (id)createFromJSONRepresentation:(id)JSONRepresentation error:(NSError **)error;

@end
