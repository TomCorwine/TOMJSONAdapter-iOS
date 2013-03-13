//
//  TOMComment.h
//  TOMJSONAdapter
//
//  Created by Tom Corwine on 2/14/13.
//  Copyright (c) 2013 Tracks. All rights reserved.
//

#import "TOMJSONAdapter.h"

@interface TOMComment : NSObject <TOMJSONAdapterProtocol>

@property (strong) NSString *commentID;
@property (strong) NSString *text;
@property (strong) NSString *owner;

@end
