//
//  TOMTrack.h
//  TOMJSONAdapter
//
//  Created by Tom Corwine on 2/14/13.
//  Copyright (c) 2013 Tracks. All rights reserved.
//

#import "TOMJSONAdapter.h"

@interface TOMTrack : NSObject <TOMJSONAdapterProtocol>

@property (strong) NSString *trackID;
@property (strong) NSString *name;
@property (strong) NSString *owner;
@property (strong) NSArray *entries;
@property (strong) NSArray *members;
@property (strong) NSNumber *isPublic;

@end
