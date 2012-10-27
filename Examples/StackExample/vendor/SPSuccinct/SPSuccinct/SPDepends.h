#import <Foundation/Foundation.h>
#ifdef __cplusplus
extern "C" {
#endif

@class SPDependency;
typedef void(^SPDependsCallback)();
typedef void(^SPDependsFancyCallback)(NSDictionary *change, id object, NSString *keyPath);
#define SPD_PAIR(object, property) object, SPS_KEYPATH(object, property)

/**
 * Add a dependency from an object to another object.
 * Registers that your object depends on the given objects and their key paths,
 * and invokes the callback when the values of any of the given key paths
 * changes.
 * 
 * @param owner See associationName. 
 * @param associationName If an owner and association name is given, the dependency 
 *                        object is associated with the owner under the given name, 
 *                        and automatically deallocated if another dependency with the 
 *                        same name is given, or if the owner object dies.
 *
 *                        If the automatic association described above is not used, 
 *                        you must retain the returned dependency object until the 
 *                        dependency becomes invalid.
 * @param callback Called when the association changes. Always called once immediately
 *                 after registration. Can be a SPDependsFancyCallback if you want.
 * @example
 *  __block __typeof(self) selff; // weak reference
 *  NSArray *dependencies = [NSArray arrayWithObjects:foo, @"bar", @"baz", a, @"b", nil]
 *  SPAddDependency(self, @"modifyThing", dependencies, ^ {
 *      selff.thing = foo.bar*3 + foo.baz - a.b;
 *  });
 */
SPDependency *SPAddDependency(id owner, NSString *associationName, NSArray *dependenciesAndNames, SPDependsCallback callback);

/**
 * Like SPAddDependency, but takes a target-action pair instead. Action may take 0 to 3 arguments,
 * just like SPDependsFancyCallback.
 */
SPDependency *SPAddDependencyTA(id owner, NSString *associationName, NSArray *dependenciesAndNames, __unsafe_unretained id target, SEL action);

/**
 * Like SPAddDependency, but can be called varg style without an explicit array object.
 * End with the callback and then nil.
 */
SPDependency *SPAddDependencyV(id owner, NSString *associationName, ...) NS_REQUIRES_NIL_TERMINATION;

/// Remove all dependencies this object has on other objects.
void SPRemoveAssociatedDependencies(id owner);
/// Remove a single dependency by name.
void SPRemoveAssociatedDependency(id owner, NSString *associationName);


#if __has_feature(objc_arc)
#define SPDependsWeakSelf __weak __typeof(self)
#else
#define SPDependsWeakSelf __block __typeof(self)
#endif

//// Shortcut for SPAddDependencyV
#define $depends(associationName, object, keypath, ...) ({ \
    SPDependsWeakSelf selff = self; /* Weak reference*/ \
    SPAddDependencyV(self, associationName, object, keypath, __VA_ARGS__, nil);\
})

@interface SPDependency : NSObject
-(void)invalidate;
@end

// ObjC aliases to the above C functions
@interface NSObject (SPDepends)
// Associates; automatic lifetime.
- (SPDependency*)sp_addDependency:(NSString*)depName on:(NSArray*)dependenciesAndNames changed:(SPDependsCallback)changed;
- (SPDependency*)sp_addDependency:(NSString*)depName on:(NSArray*)dependenciesAndNames target:(id)target action:(SEL)action;

// Does not associate: you must retain these SPDependencies until you're done with them
- (SPDependency*)sp_addDependencyOn:(NSArray*)dependenciesAndNames changed:(SPDependsCallback)changed;
- (SPDependency*)sp_addDependencyOn:(NSArray*)dependenciesAndNames target:(id)target action:(SEL)action;

- (void)sp_removeDependency:(NSString*)name;
- (void)sp_removeDependencies;
@end



#ifdef __cplusplus
}
#endif
