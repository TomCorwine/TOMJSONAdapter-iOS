//
//  TOMEntry.h
//  TOMJSONAdapter
//
//  Created by Tom Corwine on 2/14/13.
//  Copyright (c) 2013 Tracks. All rights reserved.
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
