#import <Foundation/Foundation.h>
/*!
	Minimal version of SPFunctional from http://github.com/nevyn/SPSuccinct,
	adding some functional programming methods to NSArray.
*/
@interface NSArray (SPStackedFunctional)
-(NSArray*)spstacked_filter:(BOOL(^)(id obj))predicate;
-(id)spstacked_any:(BOOL(^)(id obj))iterator;
@end
