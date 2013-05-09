#import <Foundation/Foundation.h>

@interface ISHTTPOperationMockifier : NSObject

@property (nonatomic) NSInteger statusCode;
@property (nonatomic, strong) id object;
@property (nonatomic, strong) NSError *error;

@property (nonatomic, readonly) NSURL *URL;
@property (nonatomic, readonly, getter = isMockified) BOOL mockified;

- (id)initWithURL:(NSURL *)URL;

- (void)mockify;
- (void)unmockify;

@end
