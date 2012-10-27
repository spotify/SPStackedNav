#import "SPDepends.h"
#import "SPKVONotificationCenter.h"
#import <objc/runtime.h>

@interface SPDependency ()
@property(copy) SPDependsFancyCallback callback;
@property(assign) id owner;
@property(retain) NSMutableArray *subscriptions;
@end

@implementation SPDependency
@synthesize callback = _callback, owner = _owner;
@synthesize subscriptions = _subscriptions;

- (id)initWithDependencies:(NSArray*)pairs callback:(SPDependsFancyCallback)callback owner:(id)owner
{
    if (!(self = [super init]))
        return nil;
    
    self.callback = callback;
    self.owner = owner;
    
    _subscriptions = [NSMutableArray new];
    
    SPKVONotificationCenter *nc = [SPKVONotificationCenter defaultCenter];
    
    NSEnumerator *en = [pairs objectEnumerator];
    id object = [en nextObject];
    id next = [en nextObject];
    
    for(;;) {
        SPKVObservation *subscription = [nc addObserver:self toObject:object forKeyPath:next options:0 selector:@selector(somethingChanged:inObject:forKey:)];
        [_subscriptions addObject:subscription];
        
        next = [en nextObject];
        if (!next)
            break;
        
        if (![next isKindOfClass:[NSString class]]) {
            object = next;
            next = [en nextObject];
        }
    }
    
    self.callback(nil, nil, nil);
    
    return self;
}
-(void)invalidate;
{
    for(SPKVObservation *observation in _subscriptions)
        [observation invalidate];
    self.callback = nil;
}
-(void)dealloc;
{
    [self invalidate];
    self.subscriptions = nil;
    self.owner = nil;
    self.callback = nil;
    [super dealloc];
}
-(void)somethingChanged:(NSDictionary*)change inObject:(id)object forKey:(NSString*)key
{
#if _DEBUG
    NSAssert(self.callback != nil, @"Somehow a KVO reached us after an 'invalidate'?");
#endif
    if (self.callback)
        self.callback(change, object, key);
}
@end

static void *dependenciesKey = &dependenciesKey;

SPDependency *SPAddDependency(id owner, NSString *associationName, NSArray *dependenciesAndNames, SPDependsCallback callback)
{
    id dep = [[SPDependency alloc] initWithDependencies:dependenciesAndNames callback:callback owner:owner];
    if(owner && associationName) {
        NSMutableDictionary *dependencies = objc_getAssociatedObject(owner, dependenciesKey);
        if(!dependencies) dependencies = [NSMutableDictionary dictionary];

        SPDependency *oldDependency = [dependencies objectForKey:associationName];
        if(oldDependency) [oldDependency invalidate];
        
        [dependencies setObject:dep forKey:associationName];
        objc_setAssociatedObject(owner, dependenciesKey, dependencies, OBJC_ASSOCIATION_RETAIN);
        [dep release];
    } else {
        // Try to avoid autorelease, so only do it when we can't guarantee the life length of the dep longer
        // than the runloop.
        [dep autorelease];
    }
    return dep;
}

SPDependency *SPAddDependencyTA(id owner, NSString *associationName, NSArray *dependenciesAndNames, __unsafe_unretained id target, SEL action)
{
    __block __unsafe_unretained id unretainedTarget = target;
    return SPAddDependency(owner, associationName, dependenciesAndNames, ^(NSDictionary *change, id object, NSString *keyPath){
        [unretainedTarget methodForSelector:action](unretainedTarget, action, change, object, keyPath);
    });
}

SPDependency *SPAddDependencyV(id owner, NSString *associationName, ...)
{
    NSMutableArray *dependenciesAndNames = [NSMutableArray new];
    va_list va;
    va_start(va, associationName);
    
    id object = va_arg(va, id);
    id peek = va_arg(va, id);
    
#if defined (_DEBUG) || SP_WITH_QA_TESTING
    NSCAssert(object, @"Dependency argument is nil.");
    NSCAssert(peek, @"Dependency argument is nil.");
#endif
    
    if (object == nil || peek == nil)
        return nil;
    
    do {
        [dependenciesAndNames addObject:object];
        object = peek;
        peek = va_arg(va, id);
    } while(peek != nil);
    
    id dep = SPAddDependency(owner, associationName, dependenciesAndNames, object);
    
    [dependenciesAndNames release];
    return dep;
}

void SPRemoveAssociatedDependencies(id owner)
{
    NSMutableDictionary *dependencies = objc_getAssociatedObject(owner, dependenciesKey);
    for(SPDependency *dep in [dependencies allValues])
        [dep invalidate];
    
    objc_setAssociatedObject(owner, dependenciesKey, nil, OBJC_ASSOCIATION_RETAIN);
}

void SPRemoveAssociatedDependency(id owner, NSString *associationName)
{
    NSMutableDictionary *dependencies = objc_getAssociatedObject(owner, dependenciesKey);
    SPDependency *dep = [dependencies objectForKey:associationName];
    [dep invalidate];
    if (dep)
        [dependencies removeObjectForKey:associationName];
}

@implementation NSObject (SPDepends)
- (SPDependency*)sp_addDependency:(NSString*)depName on:(NSArray*)dependenciesAndNames changed:(SPDependsCallback)changed;
{
    return SPAddDependency(self, depName, dependenciesAndNames, changed);
}

- (SPDependency*)sp_addDependency:(NSString*)depName on:(NSArray*)dependenciesAndNames target:(id)target action:(SEL)action;
{
    return SPAddDependencyTA(self, depName, dependenciesAndNames, target, action);
}
- (SPDependency*)sp_addDependencyOn:(NSArray*)dependenciesAndNames changed:(SPDependsCallback)changed
{
    return [self sp_addDependency:nil on:dependenciesAndNames changed:changed];
}
- (SPDependency*)sp_addDependencyOn:(NSArray*)dependenciesAndNames target:(id)target action:(SEL)action
{
    return [self sp_addDependency:nil on:dependenciesAndNames target:target action:action];
}

- (void)sp_removeDependency:(NSString*)name
{
    SPRemoveAssociatedDependency(self, name);
}

- (void)sp_removeDependencies
{
    SPRemoveAssociatedDependencies(self);
}
@end
