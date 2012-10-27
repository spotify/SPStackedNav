#import <Foundation/Foundation.h>

#define $array(...)  [NSArray arrayWithObjects:__VA_ARGS__, nil]
#define $marray(...) [NSMutableArray arrayWithObjects:__VA_ARGS__, nil]
#define $set(...) [NSSet setWithObjects:__VA_ARGS__, nil]
#define $dict(...)  ({ NSArray *pairs = [NSArray arrayWithObjects:__VA_ARGS__, nil]; SPDictionaryWithPairs(pairs, false); })
#define $mdict(...) ({ NSArray *pairs = [NSArray arrayWithObjects:__VA_ARGS__, nil]; SPDictionaryWithPairs(pairs, true;   })
#define $merge(d1,d2) SPDictionaryMerge(d1, d2, false)
#define $mmerge(d1,d2) SPDictionaryMerge(d1, d2, true)
#define $num(val) [NSNumber numberWithInt:val]
#define $numf(val) [NSNumber numberWithDouble:val]
#define $sprintf(...) [NSString stringWithFormat:__VA_ARGS__]
#define $nsutf(cstr) [NSString stringWithUTF8String:cstr]
#define $isIPad() (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define $isIPhone5() ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone && [UIScreen mainScreen].bounds.size.height == 568)

#define $cast(klass, obj) ({\
    __typeof__(obj) obj2 = (obj); \
    if(![obj2 isKindOfClass:[klass class]]) \
        [NSException exceptionWithName:NSInternalInconsistencyException \
                                reason:$sprintf(@"%@ is not a %@", obj2, [klass class]) \
                                userInfo:nil]; \
    (klass*)obj2;\
})
#define $castIf(klass, obj) ({ __typeof__(obj) obj2 = (obj); [obj2 isKindOfClass:[klass class]]?(klass*)obj2:nil; })

#define $notNull(x) ({ __typeof(x) xx = (x); NSAssert(xx != nil, @"Must not be nil"); xx; })

#define $deviceMultitasks() (([[UIDevice currentDevice] respondsToSelector:@selector(isMultitaskingSupported)] && [[UIDevice currentDevice] isMultitaskingSupported]))

#ifdef __cplusplus
extern "C" {
#endif

NSString *$ipadPath(NSString *path); // appends ~ipad before extension
#define $idiomaticPath(path) ($isIPad() ? $ipadPath(path) : path)

NSString *$urlencode(NSString *unencoded);
id SPDictionaryWithPairs(NSArray *pairs, BOOL mutablep);
id SPDictionaryMerge(id dictionary1, id dictionary2, BOOL mutablep);

NSError *$makeErr(NSString *domain, NSInteger code, NSString *localizedDesc);

#ifdef __cplusplus
}
#endif
