//
//  TOMUser.h
//  TOMJSONAdapter
//
//  Created by Tom Corwine on 2/14/13.
//  Copyright (c) 2013 Tracks. All rights reserved.
//

#import "TOMJSONAdapter.h"

@interface TOMUser : NSObject <TOMJSONAdapterProtocol>

@property (strong) NSString *userID;
@property (strong) NSString *name;
@property (strong) NSString *country;
@property (strong) NSString *timeZone;
@property (strong) NSArray *thumbs;

@end
