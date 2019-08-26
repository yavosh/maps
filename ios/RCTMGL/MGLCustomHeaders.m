//
//  MGLCustomHeaders.h
//  RCTMGL
//
//

#import "MGLCustomHeaders.h"
#import <Mapbox/Mapbox.h>

@implementation MGLCustomHeaders {
    NSMutableArray<NSString*> *listeners;
    NSMutableDictionary<NSString*, NSString*> *currentHeaders;
    BOOL areHeadersAdded;
}

+ (id)sharedInstance
{
    static MGLCustomHeaders *headers = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ headers = [[self alloc] init]; });
    return headers;
}

- (instancetype)init
{
    if (self = [super init]) {
        listeners = [[NSMutableArray alloc] init];
        currentHeaders = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [self stop];
}

- (void)start
{
    dispatch_async(dispatch_get_main_queue(), ^{
        areHeadersAdded = YES;
    });
}

- (void)stop
{
    dispatch_async(dispatch_get_main_queue(), ^{
        areHeadersAdded = NO;
    });
}

- (BOOL)areHeadersSent
{
    return areHeadersAdded;
}

- (void)addHeader:(NSString *)value forHeaderName:(NSString *)headerName {
    if(!areHeadersAdded) {
        // Add them
    }

    [currentHeaders setObject:value forKey:headerName];
}

- (void)removeHeader:(NSString *)header {
    [currentHeaders removeObjectForKey:header];
    if(areHeadersAdded && [currentHeaders count]>0) {
        // Remove them
    }
}


@end
