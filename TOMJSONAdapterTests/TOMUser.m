//
//  TOMUser.m
//  TOMJSONAdapter
//
//  Created by Tom Corwine on 2/14/13.
//  Copyright (c) 2013 Tracks. All rights reserved.
//

#import "TOMUser.h"

@implementation TOMUser

#pragma mark - TOMJSONAdapterProtocol

+ (NSDictionary *)JSONAdapterSchema
{
	return @{
		@"uid": @{
			kTOMJSONAdapterKeyForIdentify: @YES,
			kTOMJSONAdapterKeyForMap: @"userID",
			kTOMJSONAdapterKeyForType: @"NSString"
			},
		@"name": @{
			kTOMJSONAdapterKeyForType: @"NSString"
			},
		@"country": @{
			kTOMJSONAdapterKeyForType: @"NSString"
			},
		@"tz": @{
			kTOMJSONAdapterKeyForMap: @"timeZone",
			kTOMJSONAdapterKeyForType: @"NSString"
			},
		@"thumbs": @{
			kTOMJSONAdapterKeyForRequired: @NO,
			kTOMJSONAdapterKeyForType: @"NSArray-TOMThumb"
			}
	};
}

@end
