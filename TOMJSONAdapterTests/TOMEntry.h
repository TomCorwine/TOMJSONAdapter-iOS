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

@property (nonatomic, strong) NSString *entryID;
@property (nonatomic, strong) NSArray *thumbs;
@property (nonatomic, strong) NSDictionary *geo;
@property (nonatomic, strong) NSString *owner;
@property (nonatomic, strong) NSArray *comments;
@property (nonatomic, strong) NSArray *likes;
@property (nonatomic, strong) NSArray *views;
@property (nonatomic) int type;
@property (nonatomic, getter=isEnabled) BOOL enabled;
@property (nonatomic, strong) NSDate *createdAt;

@property (nonatomic, strong) NSArray *coordinates;

@end
