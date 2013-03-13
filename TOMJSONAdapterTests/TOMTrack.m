//
//  TOMTrack.m
//  TOMJSONAdapter
//
//  Created by Tom Corwine on 2/14/13.
//  Copyright (c) 2013 Tracks. All rights reserved.
//

#import "TOMTrack.h"

@implementation TOMTrack

#pragma mark - TOMJSONAdapterProtocol

+ (NSDictionary *)JSONAdapterSchema
{
	return @{
		@"tid": @{
			kTOMJSONAdapterKeyForIdentify: @YES,
			kTOMJSONAdapterKeyForMap: @"trackID",
			kTOMJSONAdapterKeyForType: @"NSString"
			},
		@"name": @{
			kTOMJSONAdapterKeyForType: @"NSString"
			},
		@"owner": @{
			kTOMJSONAdapterKeyForType: @"NSString",
			},
		@"entries": @{
			kTOMJSONAdapterKeyForType: @"NSArray-TOMEntry"
			},
		@"members": @{
			kTOMJSONAdapterKeyForType: @"NSArray-TOMUser",
			},
		@"public": @{
			kTOMJSONAdapterKeyForRequired: @NO,
			kTOMJSONAdapterKeyForMap: @"setIsPublic",
			kTOMJSONAdapterKeyForType: @"bool"
			}
	};
}

@end
