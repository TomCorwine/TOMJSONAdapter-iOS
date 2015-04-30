//
//  TOMComment.h
//  TOMJSONAdapterTests
//
//  Created by Tom Corwine on 2/13/13.
//

#import "TOMJSONAdapter.h"

@interface TOMComment : NSObject <TOMJSONAdapterProtocol>

@property (strong) NSString *commentID;
@property (strong) NSString *text;
@property (strong) NSString *owner;

@end
