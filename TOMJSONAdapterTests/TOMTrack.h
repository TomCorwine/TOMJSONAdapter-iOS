//
//  TOMTrack.h
//  TOMJSONAdapterTests
//
//  Created by Tom Corwine on 2/13/13.
//

#import "TOMJSONAdapter.h"

@interface TOMTrack : NSObject <TOMJSONAdapterProtocol>

@property (strong) NSString *trackID;
@property (strong) NSString *name;
@property (strong) NSString *owner;
@property (strong) NSArray *entries;
@property (strong) NSArray *members;
@property (nonatomic) BOOL isPublic;

@end
