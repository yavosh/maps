//
//  MGLCustomHeaders.h
//  RCTMGL
//

#import <Foundation/Foundation.h>

@interface MGLCustomHeaders : NSObject

@property (nonatomic, strong) NSMutableDictionary<NSString*, NSString*> *currentHeaders;

+ (id)sharedInstance;

- (void)start;
- (void)stop;
- (BOOL)areHeadersSent;
- (void)addHeader:(NSString*)value forHeaderName:(NSString *)header;
- (void)removeHeader:(NSString *)header;

@end
