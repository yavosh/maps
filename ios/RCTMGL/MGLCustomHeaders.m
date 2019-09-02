//
//  MGLCustomHeaders.h
//  RCTMGL
//
//

#import <objc/runtime.h>

#import "MGLCustomHeaders.h"
#import <Mapbox/Mapbox.h>
#import <MapBox/MGLNetworkConfiguration.h>

@implementation NSMutableURLRequest (CustomHeaders)
    + (void)load {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            Class class = [self class];
            Method oldMethod = class_getClassMethod(class, @selector(requestWithURL:));
            Method newMethod = class_getClassMethod(class, @selector(__swizzle_requestWithURL:));
            method_exchangeImplementations(oldMethod, newMethod);
        });
    }

    +(NSMutableURLRequest*) __swizzle_requestWithURL:(NSURL*)url {
        NSLog(@"URL %@", url);        
        if([url.scheme isEqualToString:@"ws"]) {
            NSLog(@"&&&&& Will not swizzle url scheme=ws  url=%@", url);
            return [NSMutableURLRequest __swizzle_requestWithURL:url];
        }
        
        NSArray<NSString*>* stack = [NSThread callStackSymbols];
        NSLog(@"&&&&& Current swizzle stack  %@", stack);
        
        if ([stack count] < 2) {
            NSLog(@"&&&&& Will not swizzle url stack < 2  url=%@", url);
            return [NSMutableURLRequest __swizzle_requestWithURL:url];
        }
        
        if ([stack[1] containsString:@"Mapbox"] == NO) {
            NSLog(@"&&&&& Will not swizzle url=%@ stack[0]=%@ stack[1]=%@", url, stack[0], stack[1]);
            return [NSMutableURLRequest __swizzle_requestWithURL:url];
        }
        
        NSMutableURLRequest *req = [NSMutableURLRequest __swizzle_requestWithURL:url];
        NSDictionary<NSString*, NSString*> *currentHeaders = [[[MGLCustomHeaders sharedInstance] currentHeaders] copy];
        if(currentHeaders != nil && [currentHeaders count]>0) {
            for (NSString* headerName in currentHeaders) {
                id headerValue = currentHeaders[headerName];
                [req setValue:headerValue forHTTPHeaderField:headerName];
            }
        }        
        return req;
    }

@end

@implementation MGLCustomHeaders {
    NSMutableDictionary<NSString*, NSString*> *_currentHeaders;
    BOOL areHeadersAdded;
}

+ (id)sharedInstance
{
    static MGLCustomHeaders *customHeaders;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ customHeaders = [[self alloc] init]; });
    return customHeaders;
}

// This replaces the [NSMutableURLRequest requestWithURL:] with custom implementation which
// adds runtime headers copied from [MGLCustomHeaders _currentHeaders]
+(void)initHeaders
{
    //TODO: Protect so this happens only once
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class targetClass = [NSMutableURLRequest class];
        Method oldMethod = class_getClassMethod(targetClass, @selector(requestWithURL:));
        Method newMethod = class_getClassMethod(targetClass, @selector(__swizzle_requestWithURL:));
        method_exchangeImplementations(oldMethod, newMethod);
    });
}

- (instancetype)init
{
    if (self = [super init]) {
        _currentHeaders = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)addHeader:(NSString *)value forHeaderName:(NSString *)headerName {
    
    if(!areHeadersAdded) {
        areHeadersAdded = YES;
    }
    
    if([value length] > 0) {
        // Emptry header is used to init headers on iOS
        NSLog(@"Add custom header %@ %@", headerName, value);
        [_currentHeaders setObject:value forKey:headerName];
        [[[MGLNetworkConfiguration sharedManager] sessionConfiguration] setHTTPAdditionalHeaders:_currentHeaders];
    }
    
    NSLog(@"Headers added %@", [[MGLNetworkConfiguration sharedManager] sessionConfiguration].HTTPAdditionalHeaders);
}

- (void)removeHeader:(NSString *)header {
    if(!areHeadersAdded) {
        return;
    }
    
    NSLog(@"Remove custom header %@", header);
    [_currentHeaders removeObjectForKey:header];
}

@end
