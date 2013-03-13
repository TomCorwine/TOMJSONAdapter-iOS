//
//  TOMThumb.m
//  TOMJSONAdapter
//
//  Created by Tom Corwine on 2/14/13.
//  Copyright (c) 2013 Tracks. All rights reserved.
//

#import "TOMThumb.h"

@implementation TOMThumb

+ (NSDictionary *)JSONAdapterSchema
{
	return @{
	@"url": @{
			kTOMJSONAdapterKeyForIdentify: @YES,
   			kTOMJSONAdapterKeyForType: @"NSString"
   },
	@"x": @{
		 	kTOMJSONAdapterKeyForIdentify: @YES,
   			kTOMJSONAdapterKeyForType: @"NSNumber"
   },
	@"y": @{
		 	kTOMJSONAdapterKeyForIdentify: @YES,
			kTOMJSONAdapterKeyForType: @"NSNumber"
   }
	};
}

@end
