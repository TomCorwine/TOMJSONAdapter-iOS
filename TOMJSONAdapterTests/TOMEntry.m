//
//  TOMEntry.m
//  TOMJSONAdapter
//
//  Created by Tom Corwine on 2/14/13.
//  TOMJSONAdapterTests
//
//  Created by Tom Corwine on 2/13/13.
//

#import "TOMEntry.h"

#import "TOMThumb.h"
#import "TOMComment.h"

@implementation TOMEntry

#pragma mark - TOMJSONAdapterProtocol

+ (NSDictionary *)JSONAdapterSchema
{
	return @{
		@"eid": @{
			kTOMJSONAdapterKeyForIdentify: @YES,
      kTOMJSONAdapterKeyForMap: @"entryID",
			kTOMJSONAdapterKeyForType: [NSString class]
			},
		@"created_at": @{
			kTOMJSONAdapterKeyForRequired: @NO,
			kTOMJSONAdapterKeyForMap: @"createdAt",
			kTOMJSONAdapterKeyForType: [NSDate class],
      kTOMJSONAdapterKeyForDateFormat: @"yyyy-MM-dd'T'HH:mm:ss'Z'"
			},
		@"thumbs": @{
			kTOMJSONAdapterKeyForType: [NSArray class],
      kTOMJSONAdapterKeyForArrayContents: [TOMThumb class]
			},
		@"comments": @{
			kTOMJSONAdapterKeyForType: [NSArray class],
      kTOMJSONAdapterKeyForArrayContents: [TOMComment class]
			},
		@"geo": @{
			kTOMJSONAdapterKeyForRequired: @NO,
      kTOMJSONAdapterKeyForType: [NSDictionary class]
			},
		@"owner": @{
			kTOMJSONAdapterKeyForType: [NSString class],
			},
		@"likes": @{
			kTOMJSONAdapterKeyForType: [NSArray class],
      kTOMJSONAdapterKeyForArrayContents: [NSString class]
			},
		@"views": @{
			kTOMJSONAdapterKeyForType: [NSArray class],
      kTOMJSONAdapterKeyForArrayContents: [NSString class]
			},
		@"type": @{
			kTOMJSONAdapterKeyForRequired: @NO,
			kTOMJSONAdapterKeyForType: [NSNumber class]
			}
	};
}

@end
