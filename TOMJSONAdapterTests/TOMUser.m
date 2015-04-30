//
//  TOMUser.m
//  TOMJSONAdapter
//
//  Created by Tom Corwine on 2/14/13.
//  Copyright (c) 2013 Tracks. All rights reserved.
//

#import "TOMUser.h"

#import "TOMThumb.h"

@implementation TOMUser

#pragma mark - TOMJSONAdapterProtocol

+ (NSDictionary *)JSONAdapterSchema
{
	return @{
		@"uid": @{
			kTOMJSONAdapterKeyForIdentify: @YES,
			kTOMJSONAdapterKeyForMap: @"userID",
			kTOMJSONAdapterKeyForType: [NSString class]
			},
		@"name": @{
			kTOMJSONAdapterKeyForType: [NSString class]
			},
		@"country": @{
			kTOMJSONAdapterKeyForType: [NSString class]
			},
		@"tz": @{
			kTOMJSONAdapterKeyForMap: @"timeZone",
			kTOMJSONAdapterKeyForType: [NSString class]
			},
		@"thumbs": @{
			kTOMJSONAdapterKeyForRequired: @NO,
			kTOMJSONAdapterKeyForType: [NSArray class],
      kTOMJSONAdapterKeyForArrayContents: [TOMThumb class]
			}
	};
}

@end
