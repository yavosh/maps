//
//  MGLCustomHeaders.h
//  RCTMGL
//
//

#import "MGLCustomHeaders.h"
#import <Mapbox/Mapbox.h>
#import <MapBox/MGLNetworkConfiguration.h>

@implementation MGLCustomHeaders {
    NSMutableDictionary<NSString*, NSString*> *_currentHeaders;
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
        _currentHeaders = [[NSMutableDictionary alloc] init];
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
    NSLog(@"Add custom header %@ %@", headerName, value);
    if(!areHeadersAdded) {
        // Add them
    }

    [_currentHeaders setObject:value forKey:headerName];
    [[[MGLNetworkConfiguration sharedManager] sessionConfiguration] setHTTPAdditionalHeaders:_currentHeaders];
}

- (void)removeHeader:(NSString *)header {
    NSLog(@"Remove custom header %@", header);
    [_currentHeaders removeObjectForKey:header];
    [[[MGLNetworkConfiguration sharedManager] sessionConfiguration] setHTTPAdditionalHeaders:_currentHeaders];

    if(areHeadersAdded && [_currentHeaders count]>0) {
        // Remove them
    }
}


@end
