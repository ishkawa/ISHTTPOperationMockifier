#import <Foundation/Foundation.h>

@interface ISHTTPOperationMockifier : NSObject

@property (nonatomic) NSInteger statusCode;
@property (nonatomic, strong) id object;
@property (nonatomic, strong) NSError *error;
@property (nonatomic, readonly, getter = isMockified) BOOL mockified;

- (void)mockify;
- (void)unmockify;

@end
