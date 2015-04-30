//
//  TOMUser.h
//  TOMJSONAdapterTests
//
//  Created by Tom Corwine on 2/13/13.
//

#import "TOMJSONAdapter.h"

@interface TOMUser : NSObject <TOMJSONAdapterProtocol>

@property (strong) NSString *userID;
@property (strong) NSString *name;
@property (strong) NSString *country;
@property (strong) NSString *timeZone;
@property (strong) NSArray *thumbs;

@end
