//
//  TOMTrack.m
//  TOMJSONAdapterTests
//
//  Created by Tom Corwine on 2/13/13.
//

#import "TOMTrack.h"

#import "TOMUser.h"
#import "TOMEntry.h"

@implementation TOMTrack

#pragma mark - TOMJSONAdapterProtocol

+ (NSDictionary *)JSONAdapterSchema
{
	return @{
		@"tid": @{
			kTOMJSONAdapterKeyForIdentify: @YES,
			kTOMJSONAdapterKeyForMap: @"trackID",
			//kTOMJSONAdapterKeyForType: [NSString class]
			},
		@"name": @{
			//kTOMJSONAdapterKeyForType: [NSString class]
			},
		@"owner": @{
			//kTOMJSONAdapterKeyForType: [NSString class],
			},
		@"entries": @{
			//kTOMJSONAdapterKeyForType: [NSArray class],
      kTOMJSONAdapterKeyForArrayContents: [TOMEntry class]
			},
		@"members": @{
			//kTOMJSONAdapterKeyForType: [NSArray class],
      kTOMJSONAdapterKeyForArrayContents: [TOMUser class]
			},
		@"public": @{
			kTOMJSONAdapterKeyForRequired: @NO,
			kTOMJSONAdapterKeyForMap: @"isPublic",
			//kTOMJSONAdapterKeyForType: [TOMJSONAdapterBool class]
			}
	};
}

@end
