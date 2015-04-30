//
//  TOMTrack.m
//  TOMJSONAdapter
//
//  Created by Tom Corwine on 2/14/13.
//  Copyright (c) 2013 Tracks. All rights reserved.
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
			kTOMJSONAdapterKeyForType: [NSString class]
			},
		@"name": @{
			kTOMJSONAdapterKeyForType: [NSString class]
			},
		@"owner": @{
			kTOMJSONAdapterKeyForType: [NSString class],
			},
		@"entries": @{
			kTOMJSONAdapterKeyForType: [NSArray class],
      kTOMJSONAdapterKeyForArrayContents: [TOMEntry class]
			},
		@"members": @{
			kTOMJSONAdapterKeyForType: [NSArray class],
      kTOMJSONAdapterKeyForArrayContents: [TOMUser class]
			},
		@"public": @{
			kTOMJSONAdapterKeyForRequired: @NO,
			kTOMJSONAdapterKeyForMap: @"setIsPublic",
			kTOMJSONAdapterKeyForType: [TOMJSONAdapterBool class]
			}
	};
}

@end
