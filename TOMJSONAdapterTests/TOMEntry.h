//
//  TOMEntry.h
//  TOMJSONAdapterTests
//
//  Created by Tom Corwine on 2/13/13.
//

#import "TOMJSONAdapter.h"

typedef enum {
	TOMEntryTypePhoto,
	TOMEntryTypeVideo
} TOMEntryType;

@interface TOMEntry : NSObject <TOMJSONAdapterProtocol>

@property (strong) NSString *entryID;
@property (strong) NSArray *thumbs;
@property (strong) NSDictionary *geo;
@property (strong) NSString *owner;
@property (strong) NSArray *comments;
@property (strong) NSArray *likes;
@property (strong) NSArray *views;
@property (strong) NSNumber *type;
@property (strong) NSDate *createdAt;

@end
