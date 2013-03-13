//
//  TOMEntry.m
//  TOMJSONAdapter
//
//  Created by Tom Corwine on 2/14/13.
//  Copyright (c) 2013 Tracks. All rights reserved.
//

#import "TOMEntry.h"

@implementation TOMEntry

#pragma mark - TOMJSONAdapterProtocol

+ (NSDictionary *)JSONAdapterSchema
{
	return @{
		@"eid": @{
			kTOMJSONAdapterKeyForIdentify: @YES,
   			kTOMJSONAdapterKeyForMap: @"entryID",
			kTOMJSONAdapterKeyForType: @"NSString"
			},
		@"created_at": @{
			kTOMJSONAdapterKeyForRequired: @NO,
			kTOMJSONAdapterKeyForMap: @"createdAt",
			kTOMJSONAdapterKeyForType: @"NSDate-GMT-yyyy-MM-dd'T'HH:mm:ss'Z'"
			},
		@"thumbs": @{
			kTOMJSONAdapterKeyForType: @"NSArray-TOMThumb"
			},
		@"comments": @{
			kTOMJSONAdapterKeyForType: @"NSArray-TOMComment"
			},
		@"geo": @{
			kTOMJSONAdapterKeyForRequired: @NO,
   			kTOMJSONAdapterKeyForType: @"NSDictionary"
			},
		@"owner": @{
			kTOMJSONAdapterKeyForType: @"NSString",
			},
		@"likes": @{
			kTOMJSONAdapterKeyForType: @"NSArray-string"
			},
		@"views": @{
			kTOMJSONAdapterKeyForType: @"NSArray-string"
			},
		@"type": @{
			kTOMJSONAdapterKeyForRequired: @NO,
			kTOMJSONAdapterKeyForType: @"NSNumber"
			}
	};
}

@end
