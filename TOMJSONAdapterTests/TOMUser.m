//
//  TOMUser.m
//  TOMJSONAdapterTests
//
//  Created by Tom Corwine on 2/13/13.
//

#import "TOMUser.h"

#import "TOMThumb.h"

#import "TOMJSONAdapter.h"

@implementation TOMUser

#pragma mark - TOMJSONAdapterProtocol

+ (NSDictionary *)JSONAdapterSchema
{
	return @{
		@"uid": @{
			//kTOMJSONAdapterKeyForIdentify: @YES,
			kTOMJSONAdapterKeyForMap: @"userID",
			//kTOMJSONAdapterKeyForType: [NSString class]
			},
		@"name": @{
			//kTOMJSONAdapterKeyForType: [NSString class]
			},
		@"country": @{
			//kTOMJSONAdapterKeyForType: [NSString class]
			},
		@"tz": @{
			kTOMJSONAdapterKeyForMap: @"timeZone",
			//kTOMJSONAdapterKeyForType: [NSString class]
			},
        @"location": @{
                kTOMJSONAdapterKeyForMap: @"locationName"
                },
		@"thumbs": @{
			kTOMJSONAdapterKeyForRequired: @NO,
			//kTOMJSONAdapterKeyForType: [NSArray class],
            kTOMJSONAdapterKeyForArrayContents: [TOMThumb class]
			},
        @"postal_code": @{
                kTOMJSONAdapterKeyForMap: @"postalCode",
                kTOMJSONAdapterKeyForFallbackToNumber: @YES
                },
        @"location.name": @{
                kTOMJSONAdapterKeyForMap: @"locationName"
                },
        @"friends.personal": @{
                kTOMJSONAdapterKeyForMap: @"personalFriends",
                kTOMJSONAdapterKeyForArrayContents: [NSNumber class]
                },
        @"friends.professional": @{
                kTOMJSONAdapterKeyForMap: @"professionalFriends",
                kTOMJSONAdapterKeyForArrayContents: [NSNumber class]
                }
	};
}

@end
