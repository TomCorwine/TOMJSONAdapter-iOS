//
//  TOMComment.m
//  TOMJSONAdapterTests
//
//  Created by Tom Corwine on 2/13/13.
//

#import "TOMComment.h"

@implementation TOMComment

#pragma mark - TOMJSONAdapterProtocol

+ (NSDictionary *)JSONAdapterSchema
{
	return @{
		@"cid": @{
			kTOMJSONAdapterKeyForIdentify: @YES,
			kTOMJSONAdapterKeyForMap: @"commentID",
			kTOMJSONAdapterKeyForType: [NSString class]
			},
		@"message": @{
			kTOMJSONAdapterKeyForMap: @"text",
			kTOMJSONAdapterKeyForType: [NSString class]
			},
		@"owner": @{
			kTOMJSONAdapterKeyForType: [NSString class]
			}
	};
}

@end
