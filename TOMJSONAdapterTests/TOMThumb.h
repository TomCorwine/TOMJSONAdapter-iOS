//
//  TOMThumb.h
//  TOMJSONAdapterTests
//
//  Created by Tom Corwine on 2/13/13.
//

#import "TOMJSONAdapter.h"

@interface TOMThumb : NSObject <TOMJSONAdapterProtocol>

@property (strong) NSString *url;
@property (nonatomic) float x;
@property (nonatomic) float y;

@end
