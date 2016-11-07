//
//  TOMComment.m
//  TOMJSONAdapterTests
//
//  Created by Tom Corwine on 2/13/13.
//

#import "TOMComment.h"

#import "TOMJSONAdapter.h"

@interface TOMComment ()

@property (nonatomic) BOOL willConfigureTriggered;
@property (nonatomic) BOOL didConfigureTriggered;

@end

@implementation TOMComment

#pragma mark - TOMJSONAdapterProtocol

+ (NSDictionary *)JSONAdapterSchema
{
	return @{
		@"cid": @{
                //kTOMJSONAdapterKeyForIdentify: @YES,
			kTOMJSONAdapterKeyForMap: @"commentID",
			//kTOMJSONAdapterKeyForType: [NSString class]
			},
		@"message": @{
			kTOMJSONAdapterKeyForMap: @"text",
			//kTOMJSONAdapterKeyForType: [NSString class]
			},
		@"owner": @{
			//kTOMJSONAdapterKeyForType: [NSString class]
			}
	};
}

- (void)JSONAdapterWillConfigure
{
    self.willConfigureTriggered = YES;
}

- (void)JSONAdapterDidConfigure
{
    self.didConfigureTriggered = YES;
}

@end
