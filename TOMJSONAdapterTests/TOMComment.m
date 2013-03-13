//
//  TOMComment.m
//  TOMJSONAdapter
//
//  Created by Tom Corwine on 2/14/13.
//  Copyright (c) 2013 Tracks. All rights reserved.
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
			kTOMJSONAdapterKeyForType: @"NSString"
			},
		@"message": @{
			kTOMJSONAdapterKeyForMap: @"text",
			kTOMJSONAdapterKeyForType: @"NSString"
			},
		@"owner": @{
			kTOMJSONAdapterKeyForType: @"NSString"
			}
	};
}

@end
