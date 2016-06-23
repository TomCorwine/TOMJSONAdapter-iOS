//
//  TOMThumb.m
//  TOMJSONAdapterTests
//
//  Created by Tom Corwine on 2/13/13.
//

#import "TOMThumb.h"

#import "TOMJSONAdapter.h"

@implementation TOMThumb

+ (NSDictionary *)JSONAdapterSchema
{
	return @{
    @"url": @{
        //kTOMJSONAdapterKeyForIdentify: @YES,
        //kTOMJSONAdapterKeyForType: [NSString class]
     },
    @"x": @{
        //kTOMJSONAdapterKeyForIdentify: @YES,
        //kTOMJSONAdapterKeyForType: [NSNumber class]
     },
    @"y": @{
        //kTOMJSONAdapterKeyForIdentify: @YES,
        //kTOMJSONAdapterKeyForType: [NSNumber class]
     }
	};
}

@end
