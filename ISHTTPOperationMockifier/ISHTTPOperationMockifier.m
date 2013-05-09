#import "ISHTTPOperationMockifier.h"
#import "ISHTTPOperation.h"

#import <objc/runtime.h>

static void ISSwizzleInstanceMethod(Class c, SEL original, SEL alternative)
{
    Method orgMethod = class_getInstanceMethod(c, original);
    Method altMethod = class_getInstanceMethod(c, alternative);
    
    if(class_addMethod(c, original, method_getImplementation(altMethod), method_getTypeEncoding(altMethod))) {
        class_replaceMethod(c, alternative, method_getImplementation(orgMethod), method_getTypeEncoding(orgMethod));
    } else {
        method_exchangeImplementations(orgMethod, altMethod);
    }
}

static NSURL *ISStripURL(NSURL *URL)
{
    if (![URL.query length]) {
        return URL;
    }
    NSString *query = [@"?" stringByAppendingString:URL.query];
    NSString *string = [URL.absoluteString stringByReplacingOccurrencesOfString:query withString:@""];
    
    return [NSURL URLWithString:string];
}

static NSMutableDictionary *ISMockDictionary()
{
    static NSMutableDictionary *dictionary = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dictionary = [NSMutableDictionary dictionary];
    });
    
    return dictionary;
}

@implementation ISHTTPOperation (Mock)

+ (void)load
{
    @autoreleasepool {
        ISSwizzleInstanceMethod([self class], @selector(main), @selector(_main));
    }
}

- (void)_main
{
    NSURL *URL = ISStripURL(self.request.URL);
    NSMutableDictionary *dictionary = ISMockDictionary();
    ISHTTPOperationMockifier *mockifier = [[dictionary objectForKey:URL] nonretainedObjectValue];
    if (!mockifier) {
        [self _main];
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSInteger statusCode = mockifier.statusCode;
        id object = mockifier.object;
        NSError *error = mockifier.error;
        
        NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:self.request.URL
                                                                  statusCode:statusCode
                                                                 HTTPVersion:@"1.1"
                                                                headerFields:nil];
        
        self.handler(response, object, error);
    });
    
    [self completeOperation];
}

@end

@interface ISHTTPOperationMockifier ()

@property (nonatomic) BOOL mockified;

@end

@implementation ISHTTPOperationMockifier

- (id)initWithURL:(NSURL *)URL
{
    self = [super init];
    if (self) {
        _URL = URL;
        _statusCode = 200;
    }
    return self;
}

- (void)dealloc
{
    if (self.isMockified) {
        [self unmockify];
    }
}

- (void)mockify
{
    if (self.isMockified) {
        return;
    }
    
    NSURL *URL = ISStripURL(self.URL);
    NSMutableDictionary *dictionary = ISMockDictionary();
    NSValue *value = [NSValue valueWithNonretainedObject:self];
    [dictionary setObject:value forKey:URL];
    
    self.mockified = YES;
}

- (void)unmockify
{
    if (!self.isMockified) {
        return;
    }
    
    NSURL *URL = ISStripURL(self.URL);
    NSMutableDictionary *dictionary = ISMockDictionary();
    [dictionary removeObjectForKey:URL];
    
    self.mockified = NO;
}

@end
