//
//  TOMTrack.h
//  TOMJSONAdapterTests
//
//  Created by Tom Corwine on 2/13/13.
//

#import "TOMJSONAdapter.h"

@interface TOMTrack : NSObject <TOMJSONAdapterProtocol>

@property (nonatomic, strong) NSString *trackID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *owner;
@property (nonatomic, strong) NSArray *entries;
@property (nonatomic, strong) NSArray *members;
@property (nonatomic) BOOL isPublic;

@end
