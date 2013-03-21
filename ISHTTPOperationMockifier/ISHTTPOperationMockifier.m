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

static char *const TRHTTPMockStatusCodeKey = "TRHTTPMockStatusCodeKey";
static char *const TRHTTPMockObjectKey     = "TRHTTPMockObjectKey";
static char *const TRHTTPMockErrorKey      = "TRHTTPMockErrorKey";

@implementation ISHTTPOperation (Mock)

- (NSInteger)statusCode
{
    return [objc_getAssociatedObject([self class], TRHTTPMockStatusCodeKey) integerValue];
}


- (void)_main
{
    dispatch_async(dispatch_get_main_queue(), ^{
        Class class = [ISHTTPOperation class];
        NSInteger statusCode = [objc_getAssociatedObject(class, TRHTTPMockStatusCodeKey) integerValue];
        id object = objc_getAssociatedObject(class, TRHTTPMockObjectKey);
        NSError *error = objc_getAssociatedObject(class, TRHTTPMockErrorKey);
        NSLog(@"ccc2: %@", class);
        
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

- (id)init
{
    self = [super init];
    if (self) {
        self.statusCode = 200;
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
    
    Class class = [ISHTTPOperation class];
    objc_setAssociatedObject(class, TRHTTPMockStatusCodeKey, @(self.statusCode), OBJC_ASSOCIATION_RETAIN);
    objc_setAssociatedObject(class, TRHTTPMockObjectKey, self.object, OBJC_ASSOCIATION_RETAIN);
    objc_setAssociatedObject(class, TRHTTPMockErrorKey, self.error, OBJC_ASSOCIATION_RETAIN);
    
    ISSwizzleInstanceMethod(class, @selector(main), @selector(_main));
    self.mockified = YES;
}

- (void)unmockify
{
    if (!self.isMockified) {
        return;
    }
    
    Class class = [ISHTTPOperation class];
    objc_setAssociatedObject(class, TRHTTPMockStatusCodeKey, nil, OBJC_ASSOCIATION_RETAIN);
    objc_setAssociatedObject(class, TRHTTPMockObjectKey, nil, OBJC_ASSOCIATION_RETAIN);
    objc_setAssociatedObject(class, TRHTTPMockErrorKey, nil, OBJC_ASSOCIATION_RETAIN);
    
    ISSwizzleInstanceMethod(class, @selector(main), @selector(_main));
    self.mockified = NO;
}

@end
