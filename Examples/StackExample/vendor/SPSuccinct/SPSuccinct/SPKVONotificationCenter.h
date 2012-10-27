#import <Foundation/Foundation.h>

#define SPS_KEYPATH(object, property) ((void)(NO && ((void)object.property, NO)), @#property)

typedef void(^SPKVOCallback)(NSDictionary* change, id object, NSString* keyPath);

enum {
    /// By default, SPKVONC holds on to the observation after it has been added, and automatically invalidates
    /// when either 'observer' or 'observed' dies. You can disable this behavior with the ManualLifetime
    /// flag.
    SPKeyValueObservingOptionManualLifetime = 1 << 8,
};


@interface SPKVObservation : NSObject
-(void)invalidate;
@end


@interface SPKVONotificationCenter : NSObject
+(id)defaultCenter;
-(SPKVObservation*)addObserver:(id)observer toObject:(id)observed forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options;
// selector should have the following signature:
// - (void)observeChange:(NSDictionary*)change onObject:(id)target forKeyPath:(NSString *)keyPath
-(SPKVObservation*)addObserver:(id)observer toObject:(id)observed forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options selector:(SEL)sel;
-(SPKVObservation*)addObserver:(id)observer toObject:(id)observed forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options callback:(SPKVOCallback)callback;

@end

@interface NSObject (SPKVONotificationCenterAddition)
-(SPKVObservation*)sp_addObserver:(NSObject*)observer forKeyPath:(NSString*)kp options:(NSKeyValueObservingOptions)options selector:(SEL)sel;
-(SPKVObservation*)sp_addObserver:(NSObject*)observer forKeyPath:(NSString*)kp options:(NSKeyValueObservingOptions)options callback:(SPKVOCallback)callback;
-(SPKVObservation*)sp_observe:(NSString*)kp removed:(void(^)(id))onRemoved added:(void(^)(id))onAdded;
-(SPKVObservation*)sp_observe:(NSString*)kp removed:(void(^)(id))onRemoved added:(void(^)(id))onAdded initial:(BOOL)callbackInitial;
@end