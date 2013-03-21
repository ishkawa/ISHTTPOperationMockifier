mockify ISHTTPOperation.

## Requirements

- iOS 4.0 or later
- ARC

## Example

```objectivec
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
```

## License

Copyright (c) 2013 Yosuke Ishikawa

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
