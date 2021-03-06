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

  NSArray *errors;
	TOMComment *comment = [self parseJson:json expectedClass:[TOMComment class] errors:errors];
  XCTAssertNil(errors, @"There are errors.");

  if (nil == comment) {
    return;
  }

  XCTAssertTrue([comment.commentID isEqualToString:@"511fe8718768a126bc000032"], @"commentID doesn’t match");
  XCTAssertTrue([comment.text isEqualToString:@"Congrats!"], @"text doesn’t match");
  XCTAssertTrue([comment.owner isEqualToString:@"50e5ecfe8768a1336c000019"], @"owner doesn't match");

  XCTAssertTrue(comment.willConfigureTriggered, @"JSONAdapterWillConfigure was not called.");
  XCTAssertTrue(comment.didConfigureTriggered, @"JSONAdapterDidConfigure was not called.");
}

- (void)test02User
{
	NSString *json = @"{\"uid\": \"511fe8718768a126bc000032\",\
  \"name\": \"Congrats!\", \
  \"country\": \"US\", \
	\"tz\": \"America/New_York\",\
  \"location\": [],\
  \"postal_code\": 32606,\
  \"friends\": {\
    \"personal\": [\
      8745,\
      9287\
    ],\
    \"professional\": [\
      568,\
      212,\
      4256\
    ]\
    }\
  }";

  NSArray *errors;
	TOMUser *user = [self parseJson:json expectedClass:[TOMUser class] errors:errors];
  XCTAssert(1 == errors.count, @"Expected 1 error.");

  if (nil == user) {
    return;
  }

  XCTAssertTrue([user.userID isEqualToString:@"511fe8718768a126bc000032"], @"userID doesn’t match");
  XCTAssertTrue([user.country isEqualToString:@"US"], @"country doesn’t match");
  XCTAssertTrue([user.timeZone isEqualToString:@"America/New_York"], @"timeZone doesn’t match");

  XCTAssertTrue([user.postalCode isEqualToString:@"32606"], @"postalCode didn’t transform number to string.");

  // TODO: Rewrite these to insure exception won’t be thrown if array isn’t created properly.
  XCTAssertTrue([user.personalFriends isKindOfClass:[NSArray class]]);
  NSArray *array = user.personalFriends;
  XCTAssertTrue(array.count == 2);
  XCTAssertTrue([array[0] isEqualToNumber:@8745]);
  XCTAssertTrue([array[1] isEqualToNumber:@9287]);

  XCTAssertTrue([user.professionalFriends isKindOfClass:[NSArray class]]);
  array = user.professionalFriends;
  XCTAssertTrue(array.count == 3);
  XCTAssertTrue([array[0] isEqualToNumber:@568]);
  XCTAssertTrue([array[1] isEqualToNumber:@212]);
  XCTAssertTrue([array[2] isEqualToNumber:@4256]);
}

- (void)test03Thumb
{
	NSString *json = @"{\"url\": \"http://localhost/43247328927343\", \
    \"x\": 576, \
    \"y\": 344}";

  NSArray *errors;
	TOMThumb *thumb = [self parseJson:json expectedClass:[TOMThumb class] errors:errors];
  XCTAssertNil(errors, @"There are errors.");

  if (nil == thumb) {
    return;
  }

  XCTAssertTrue([thumb.url isEqualToString:@"http://localhost/43247328927343"], @"url doesn’t match");
  XCTAssertTrue(thumb.x == 576.0f, @"x doesn’t match");
  XCTAssertTrue(thumb.y == 344.0f, @"y doesn’t match");
}

- (void)test04Entry
{
	NSString *json = @"{\
	\"eid\": \"511fe8718768a126bc000031\", \
	\"owner\": \"501fd8718768a126bc000001\", \
	\"created_at\": \"2013-03-13-12:04:03\", \
	\"type\": 1, \
  \"enabled\": true, \
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

  NSArray *errors;
	TOMEntry *entry = [self parseJson:json expectedClass:[TOMEntry class] errors:errors];
  XCTAssertNil(errors, @"There are errors.");

  if (nil == entry) {
    return;
  }

	XCTAssertTrue([entry.entryID isEqualToString:@"511fe8718768a126bc000031"], @"entryID doesn’t match");
	XCTAssertTrue([entry.owner isEqualToString:@"501fd8718768a126bc000001"], @"owner doesn’t match");
	XCTAssertTrue(entry.type == 1, @"type isn’t 1");
  XCTAssertTrue(entry.enabled == YES, @"enabled isn’t YES");
	XCTAssertTrue([entry.thumbs isKindOfClass:[NSArray class]], @"Expecting a NSArray, got %@.", NSStringFromClass([entry.thumbs class]));
	XCTAssertTrue([entry.comments isKindOfClass:[NSArray class]], @"Expecting a NSArray, got %@.", NSStringFromClass([entry.comments class]));
	XCTAssertTrue([entry.likes isKindOfClass:[NSArray class]], @"Expecting a NSArray, got %@.", NSStringFromClass([entry.likes class]));
	XCTAssertTrue([entry.views isKindOfClass:[NSArray class]], @"Expecting a NSArray, got %@.", NSStringFromClass([entry.views class]));

  BOOL isCorrectClass = [entry.coordinates isKindOfClass:[NSArray class]];
  XCTAssertTrue(isCorrectClass, @"Expecting a NSArray, got %@.", NSStringFromClass([entry.coordinates class]));
  if (isCorrectClass)
  {
    NSArray *coordinatesArray = entry.coordinates;
    NSNumber *longitude = coordinatesArray[0];
    NSNumber *latitude = coordinatesArray[1];
    XCTAssertTrue(longitude.doubleValue == -40.34324344, @"Longitude is not correct.");
    XCTAssertTrue(latitude.doubleValue == 70.434388743, @"Latitude is not correct.");
  }

  isCorrectClass = [entry.createdAt isKindOfClass:[NSDate class]];
  XCTAssertTrue(isCorrectClass, @"Expecting a NSDate, got %@.", NSStringFromClass([entry.createdAt class]));
  if (isCorrectClass) {
    XCTAssertTrue(entry.createdAt.timeIntervalSince1970, @"createdAt doesn’t match");
  }

	for (TOMComment *comment in entry.comments)
	{
    BOOL isCorrectClass = [comment isKindOfClass:[TOMComment class]];
		XCTAssertTrue(isCorrectClass, @"Expecting a TOMComment, got %@.", NSStringFromClass([comment class]));

    if (isCorrectClass)
    {
      XCTAssertTrue([comment.commentID isEqualToString:@"511fe8718768a126bc000032"], @"commentID doesn’t match");
      XCTAssertTrue([comment.text isEqualToString:@"Congrats!"], @"text doesn’t match");
      XCTAssertTrue([comment.owner isEqualToString:@"50e5ecfe8768a1336c000019"], @"owner doesn’t match");
    }
	}

	for (TOMThumb *thumb in entry.thumbs)
	{
    BOOL isCorrectClass = [thumb isKindOfClass:[TOMThumb class]];
		XCTAssertTrue(isCorrectClass, @"Expecting a TOMThumb, got %@.", NSStringFromClass([thumb class]));

    if (isCorrectClass)
    {
      XCTAssertTrue([thumb.url isEqualToString:@"http://localhost/43247328927343"], @"url doesn’t match");
      XCTAssertTrue(thumb.x == 576.0f, @"x doesn't match");
      XCTAssertTrue(thumb.y == 344.0f, @"y doesn't match");
    }
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

  XCTAssertTrue(entry.coordinates.count == 2, @"Expecting 'coordinates' property to be a 2 item NSArray.");
  NSNumber *lon = entry.coordinates[0];
  NSNumber *lat = entry.coordinates[1];
  XCTAssertTrue(lon.doubleValue == -40.34324344);
  XCTAssertTrue(lat.doubleValue == 70.434388743);
}

#pragma mark - Helpers

- (id)parseJson:(NSString *)json expectedClass:(Class)class errors:(NSArray *)errors
{
	TOMJSONAdapter *jsonAdapter = [TOMJSONAdapter JSONAdapter];
	id object = [jsonAdapter createFromJSONRepresentation:json rootClass:class errors:&errors];

  XCTAssertNotNil(object, @"Root object is nil.");

  BOOL isCorrectClass = [object isKindOfClass:class];
  if (isCorrectClass)
  {
    return object;
  }
  else
  {
    XCTFail(@"Expecting a %@, got %@.", NSStringFromClass(class), NSStringFromClass([object class]));
    XCTFail(@"Skipping tests for %@ as wrong kind of class was returned.", NSStringFromClass(class));

    return nil;
  }
}

@end
