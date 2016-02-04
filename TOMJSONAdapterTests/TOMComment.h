//
//  TOMComment.h
//  TOMJSONAdapterTests
//
//  Created by Tom Corwine on 2/13/13.
//

#import "TOMJSONAdapter.h"

@interface TOMComment : NSObject <TOMJSONAdapterProtocol>

@property (nonatomic, strong) NSString *commentID;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString *owner;

@end
