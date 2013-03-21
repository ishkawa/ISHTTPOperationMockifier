#import "DemoTests.h"
#import "ISHTTPOperation.h"
#import "ISHTTPOperationMockifier.h"

@implementation DemoTests {
    NSURLRequest *_request;
    BOOL _waiting;
}

- (void)setUp
{
    [super setUp];
    
    _request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.example.com"]];
}

- (void)tearDown
{
    _request = nil;
    
    [super tearDown];
}

#pragma mark - wait for asynchronous operations

- (void)beginWaiting
{
    _waiting = YES;
    
    do {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:.1]];
    } while (_waiting);
}

- (void)endWaiting
{
    _waiting = NO;
}

#pragma mark - tests

- (void)testSuccessCase
{
    NSDictionary *dictionary =  @{@"hogeKey": @"hogeValue",
                                  @"fugaKey": @"fugaValue",
                                  @"piyoKey": @"piyoValue", };
    
    ISHTTPOperationMockifier *mockfier = [[ISHTTPOperationMockifier alloc] init];
    mockfier.statusCode = 200;
    mockfier.object = dictionary;
    mockfier.error = nil;
    [mockfier mockify];
    
    [ISHTTPOperation sendRequest:_request handler:^(NSHTTPURLResponse *response, id object, NSError *error) {
        STAssertEqualObjects([object objectForKey:@"hogeKey"], [dictionary objectForKey:@"hogeKey"], nil);
        STAssertEqualObjects([object objectForKey:@"fugaKey"], [dictionary objectForKey:@"fugaKey"], nil);
        STAssertEqualObjects([object objectForKey:@"piyoKey"], [dictionary objectForKey:@"piyoKey"], nil);
        
        [self endWaiting];
    }];
    
    [self beginWaiting];
}

- (void)testFailureCase
{
    NSError *mockError = [NSError errorWithDomain:@"ISHTTPOperationDomain"
                                             code:-1234
                                         userInfo:nil];
    
    ISHTTPOperationMockifier *mockfier = [[ISHTTPOperationMockifier alloc] init];
    mockfier.statusCode = 0;
    mockfier.object = nil;
    mockfier.error = mockError;
    [mockfier mockify];
    
    [ISHTTPOperation sendRequest:_request handler:^(NSHTTPURLResponse *response, id object, NSError *error) {
        STAssertEqualObjects(error, mockError, nil);
        STAssertNil(object, nil);
        
        [self endWaiting];
    }];
    
    [self beginWaiting];
}


@end
