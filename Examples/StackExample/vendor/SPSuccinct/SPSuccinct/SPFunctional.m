#import "SPFunctional.h"

@implementation NSArray (Functional)
-(NSArray*)sp_map:(id(^)(id obj))mapper;
{
	return [self sp_mapi:^(id obj, int idx) { return mapper(obj); }];
}
-(NSArray*)sp_mapi:(id(^)(id obj, int idx))mapper;
{
	NSMutableArray *mapped = [NSMutableArray arrayWithCapacity:self.count];
	int i = 0;
	for (id obj in self)
		[mapped addObject:mapper(obj, i++)];
	return mapped;
}
-(NSArray*)sp_mapk:(NSString*)keyPath;
{
	return [self sp_map:^(id obj) {return [obj valueForKeyPath:keyPath];}];
}
-(id)sp_collect:(id)start with:(id(^)(id sum, id obj))collector;
{
	id sum = start;
	for (id obj in self)
		sum = collector(sum, obj);
	return sum;
}
-(NSArray*)sp_filter:(BOOL(^)(id obj))predicate;
{
	return [self objectsAtIndexes:[self indexesOfObjectsPassingTest:^(id obj, NSUInteger idx, BOOL *stop) {
		return predicate(obj);
	}]];
}
-(void)sp_each:(void(^)(id obj))iterator;{
	for(id obj in self) iterator(obj);
}
-(id)sp_any:(BOOL(^)(id obj))iterator;
{
	for(id obj in self)
		if (iterator(obj))
			return obj;
	return NULL;
}
-(BOOL)sp_all:(BOOL(^)(id obj))iterator;
{
	for(id obj in self)
		if (!iterator(obj))
			return NO;
	return YES;
}
@end

@implementation NSSet (Functional)
-(NSSet*)sp_map:(id(^)(id obj))mapper;
{
	NSMutableSet *mapped = [NSMutableSet setWithCapacity:self.count];
	for (id obj in self)
		[mapped addObject:mapper(obj)];
	return mapped;
}
-(id)sp_collect:(id)start with:(id(^)(id sum, id obj))collector;
{
	id sum = start;
	for (id obj in self)
		sum = collector(sum, obj);
	return sum;
}
-(NSSet*)sp_filter:(BOOL(^)(id obj))predicate;
{
	return [self objectsPassingTest:^(id obj, BOOL *stop) {
		return predicate(obj);
	}];
}
-(void)sp_each:(void(^)(id obj))iterator;{
	for(id obj in self) iterator(obj);
}
-(id)sp_any:(BOOL(^)(id obj))iterator;
{
	for(id obj in self)
		if (iterator(obj))
			return obj;
	return NULL;
}
-(BOOL)sp_all:(BOOL(^)(id obj))iterator;
{
	for(id obj in self)
		if (!iterator(obj))
			return NO;
	return YES;
}
@end


@implementation NSDictionary (TCFunctional)
-(NSDictionary*)sp_map:(id(^)(NSString *key, id value))mapper;
{
    NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity:[self count]];
    for(NSString *key in self.allKeys)
        [d setObject:mapper(key, [self objectForKey:key]) forKey:key];
    return [[d copy] autorelease];
}
-(NSDictionary*)sp_filter:(BOOL(^)(id key, id val))predicate;
{
	NSMutableArray *keysToKeep = [NSMutableArray array];
	[self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		if(predicate(key, obj)) [keysToKeep addObject:key];
	}];
	NSMutableDictionary *d = [NSMutableDictionary dictionary];
	for (id key in keysToKeep)
		[d setObject:[self objectForKey:key] forKey:key];
	
	return d;
}
-(id)sp_any:(BOOL(^)(id key, id val))iterator;
{
	for(id key in self)
		if (iterator(key, [self objectForKey:key]))
			return [self objectForKey:key];
	return NULL;
}
-(BOOL)sp_all:(BOOL(^)(id key, id val))iterator;
{
	for(id key in self)
		if (!iterator(key, [self objectForKey:key]))
			return NO;
	return YES;
}
@end
