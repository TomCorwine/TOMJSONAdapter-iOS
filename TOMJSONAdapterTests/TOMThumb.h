//
//  TOMThumb.h
//  TOMJSONAdapter
//
//  Created by Tom Corwine on 2/14/13.
//  Copyright (c) 2013 Tracks. All rights reserved.
//

#import "TOMJSONAdapter.h"

@interface TOMThumb : NSObject <TOMJSONAdapterProtocol>

@property (strong) NSString *url;
@property (strong) NSNumber *x;
@property (strong) NSNumber *y;

@end
