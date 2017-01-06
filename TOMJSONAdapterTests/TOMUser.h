//
//  TOMUser.h
//  TOMJSONAdapterTests
//
//  Created by Tom Corwine on 2/13/13.
//

#import "TOMJSONAdapter.h"

@interface TOMUser : NSObject <TOMJSONAdapterProtocol>

@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *country;
@property (nonatomic, strong) NSString *timeZone;
@property (nonatomic, strong) NSString *locationName;
@property (nonatomic, strong) NSArray *thumbs;
@property (nonatomic, strong) NSString *postalCode;

@property (nonatomic, strong) NSArray *personalFriends;
@property (nonatomic, strong) NSArray *professionalFriends;

@end
