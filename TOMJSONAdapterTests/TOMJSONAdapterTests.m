//
//  TOMJSONAdapterTests.m
//  TOMJSONAdapterTests
//
//  Created by Tom Corwine on 2/13/13.
//

#import <XCTest/XCTest.h>

#import "TOMJSONAdapter.h"
#import "TOMTrack.h"
#import "TOMEntry.h"
#import "TOMUser.h"
#import "TOMComment.h"
#import "TOMThumb.h"

@interface TOMJSONAdapterTests : XCTestCase
@end

@implementation TOMJSONAdapterTests

- (void)setUp
{
  [super setUp];

  // Set-up code here.
}

- (void)tearDown
{
  // Tear-down code here.
  [super tearDown];
}

- (void)test01Comment
{
	NSString *json = @"{\"cid\": \"511fe8718768a126bc000032\", \
    \"message\": \"Congrats!\", \
    \"owner\": \"50e5ecfe8768a1336c000019\"}";
	TOMComment *comment = [self parseJson:json expectedClass:[TOMComment class]];
	XCTAssertTrue([comment isKindOfClass:[TOMComment class]], @"Expecting a TOMComment, got %@.", NSStringFromClass([comment class]));
	XCTAssertTrue([comment.commentID isEqualToString:@"511fe8718768a126bc000032"], @"commentID doesn't match");
	XCTAssertTrue([comment.text isEqualToString:@"Congrats!"], @"text doesn't match");
	XCTAssertTrue([comment.owner isEqualToString:@"50e5ecfe8768a1336c000019"], @"owner doesn't match");
}

- (void)test02User
{
	NSString *json = @"{\"uid\": \"511fe8718768a126bc000032\", \
    \"name\": \"Congrats!\", \
    \"country\": \"US\", \
	\"tz\": \"America/New_York\"}";
	TOMUser *user = [self parseJson:json expectedClass:[TOMUser class]];
	XCTAssertTrue([user isKindOfClass:[TOMUser class]], @"Expecting a TOMUser, got %@.", NSStringFromClass([user class]));
	XCTAssertTrue([user.userID isEqualToString:@"511fe8718768a126bc000032"], @"userID doesn't match");
	XCTAssertTrue([user.country isEqualToString:@"US"], @"country doesn't match");
	XCTAssertTrue([user.timeZone isEqualToString:@"America/New_York"], @"timeZone doesn't match");
}

- (void)test03Thumb
{
	NSString *json = @"{\"url\": \"http://localhost/43247328927343\", \
    \"x\": 576, \
    \"y\": 344}";
	TOMThumb *thumb = [self parseJson:json expectedClass:[TOMThumb class]];
	XCTAssertTrue([thumb isKindOfClass:[TOMThumb class]], @"Expecting a TOMThumb, got %@.", NSStringFromClass([thumb class]));
	XCTAssertTrue([thumb.url isEqualToString:@"http://localhost/43247328927343"], @"url doesn't match");
	XCTAssertTrue(thumb.x.integerValue == 576, @"x doesn't match");
	XCTAssertTrue(thumb.y.integerValue == 344, @"y doesn't match");
}

- (void)test04Entry
{
	NSString *json = @"{\
	\"eid\": \"511fe8718768a126bc000031\", \
	\"owner\": \"501fd8718768a126bc000001\", \
	\"created_at\": \"2013-03-13'T'12:04:03'Z'\", \
	\"type\": 1, \
	\"geo\": {\"type\": \"Point\", \"coordinates\": [-40.34324344, 70.434388743]}, \
	\"comments\": [{\"cid\": \"511fe8718768a126bc000032\", \
    	\"message\": \"Congrats!\", \
    	\"owner\": \"50e5ecfe8768a1336c000019\"}], \
	\"thumbs\": [{\"url\": \"http://localhost/43247328927343\", \
    	\"x\": 576, \
    	\"y\": 344}], \
	\"likes\": [\"501fd8718768a126bc000001\", \"511fe8718768a126bc000032\"], \
	\"views\": [\"501fd8718768a126bc000001\", \"511fe8718768a126bc000032\"] \
	}";
	TOMEntry *entry = [self parseJson:json expectedClass:[TOMEntry class]];
	XCTAssertTrue([entry isKindOfClass:[TOMEntry class]], @"Expecting a TOMEntry, got %@.", NSStringFromClass([entry class]));
	XCTAssertTrue([entry.entryID isEqualToString:@"511fe8718768a126bc000031"], @"entryID doesn't match");
	XCTAssertTrue([entry.owner isEqualToString:@"501fd8718768a126bc000001"], @"owner doesn't match");
	//XCTAssertTrue([entry.createdAt isKindOfClass:[NSDate class]], @"Expecting a NSDate, got %@.", NSStringFromClass([entry.createdAt class]));
	//XCTAssertTrue(entry.createdAt.timeIntervalSince1970, @"createdAt doesn't match");
	XCTAssertTrue(entry.type.integerValue == 1, @"type doesn't match");
	XCTAssertTrue([entry.geo isKindOfClass:[NSDictionary class]], @"Expecting a NSDictionary, got %@.", NSStringFromClass([entry.geo class]));
	XCTAssertTrue([entry.thumbs isKindOfClass:[NSArray class]], @"Expecting a NSArray, got %@.", NSStringFromClass([entry.thumbs class]));
	XCTAssertTrue([entry.comments isKindOfClass:[NSArray class]], @"Expecting a NSArray, got %@.", NSStringFromClass([entry.comments class]));
	XCTAssertTrue([entry.likes isKindOfClass:[NSArray class]], @"Expecting a NSArray, got %@.", NSStringFromClass([entry.likes class]));
	XCTAssertTrue([entry.views isKindOfClass:[NSArray class]], @"Expecting a NSArray, got %@.", NSStringFromClass([entry.views class]));
	for (TOMComment *comment in entry.comments)
	{
		XCTAssertTrue([comment isKindOfClass:[TOMComment class]], @"Expecting a TOMComment, got %@.", NSStringFromClass([comment class]));
		XCTAssertTrue([comment.commentID isEqualToString:@"511fe8718768a126bc000032"], @"commentID doesn't match");
		XCTAssertTrue([comment.text isEqualToString:@"Congrats!"], @"text doesn't match");
		XCTAssertTrue([comment.owner isEqualToString:@"50e5ecfe8768a1336c000019"], @"owner doesn't match");
	}
	for (TOMThumb *thumb in entry.thumbs)
	{
		XCTAssertTrue([thumb isKindOfClass:[TOMThumb class]], @"Expecting a TOMThumb, got %@.", NSStringFromClass([thumb class]));
		XCTAssertTrue([thumb.url isEqualToString:@"http://localhost/43247328927343"], @"url doesn't match");
		XCTAssertTrue(thumb.x.integerValue == 576, @"x doesn't match");
		XCTAssertTrue(thumb.y.integerValue == 344, @"y doesn't match");
	}
	for (NSString *like in entry.likes)
	{
		XCTAssertTrue([like isKindOfClass:[NSString class]], @"Expecting a NSString, got %@.", NSStringFromClass([like class]));
		XCTAssertTrue([like isEqualToString:@"501fd8718768a126bc000001"] || [like isEqualToString:@"511fe8718768a126bc000032"], @"like doesn't match.");
	}
	for (NSString *view in entry.views)
	{
		XCTAssertTrue([view isKindOfClass:[NSString class]], @"Expecting a NSString, got %@.", NSStringFromClass([view class]));
		XCTAssertTrue([view isEqualToString:@"501fd8718768a126bc000001"] || [view isEqualToString:@"511fe8718768a126bc000032"], @"view doesn't match.");
	}
}

- (id)parseJson:(NSString *)json expectedClass:(Class)class
{
	NSArray *errors;
	TOMJSONAdapter *jsonAdapter = [TOMJSONAdapter JSONAdapter];
	id object = [jsonAdapter createFromJSONRepresentation:json expectedRootClass:class errors:&errors];
  XCTAssertNil(errors, @"%@", @"There are errors.");
	XCTAssertNotNil(object, @"Root object is nil.");
	return object;
}

@end
