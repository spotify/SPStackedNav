#import "SPFunctional-mini.h"

@implementation NSArray (SPStackedFunctional)
-(NSArray*)spstacked_filter:(BOOL(^)(id obj))predicate;
{
	return [self objectsAtIndexes:[self indexesOfObjectsPassingTest:^(id obj, NSUInteger idx, BOOL *stop) {
		return predicate(obj);
	}]];
}

-(id)spstacked_any:(BOOL(^)(id obj))iterator;
{
	for(id obj in self)
		if (iterator(obj))
			return obj;
	return NULL;
}
@end
