#import <Foundation/Foundation.h>

@class SPLifetimeGlue;

typedef void(^SPLifetimeGlueCallback)(SPLifetimeGlue *glue, id objectThatDied);

/** @class SPLifetimeGlue
    @abstract Listens to the lifetime of the given objects, and notifies with the callback when
              any of them die.
    @note On ownership: The glue has an owning reference from each of the objects that it observes.
 */
@interface SPLifetimeGlue : NSObject
- (id)initWatchingLifetimesOfObjects:(NSArray*)objects callback:(SPLifetimeGlueCallback)callback;
+ (id)watchLifetimes:(NSArray*)objects callback:(SPLifetimeGlueCallback)callback;
@property(nonatomic, copy) SPLifetimeGlueCallback objectDied;
- (void)invalidate;
@end
