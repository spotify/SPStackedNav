#import <Foundation/Foundation.h>
#import <SPSuccinct/SPSuccinct.h>
#import "SPLifetimeGlue.h"

static int fooCount = 0;

@interface Foo : NSObject
@property(retain) NSString *a, *b;
@property(retain) Foo *y;
@end
@implementation Foo
@synthesize a, b, y;
- (id)init
{
    if (!(self = [super init]))
        return nil;
    fooCount++;
    return self;
}
- (void)dealloc
{
    fooCount--;
    self.a = nil;
    self.b = nil;
    self.y = nil;
    [super dealloc];
}
- (id)retain
{
    return [super retain];
}
-(void)main;
{
	Foo *x = [[Foo new] autorelease];
	self.y = [[Foo new] autorelease];
	x.a = @"Hello";
	x.b = @"there";
	
	// This line establishes a dependency from 'self' to x.a, x.b and y.a.
    // Try to make a typo in the SPD_PAIR macro!
	$depends(@"printing", x, @"a", @"b", SPD_PAIR(y, a), ^{
		NSLog(@"%@ %@, %@", x.a, x.b, selff.y.a);
	});
    
    SPAddDependencyTA(self, @"printing2", @[SPD_PAIR(y, a)], self, @selector(change:inObject:forKeyPath:)); // C syntax
    [self sp_addDependency:@"printing3" on:@[SPD_PAIR(y, a)] target:self action:@selector(somethingHappened)]; // ObjC syntax
    
	// These are called once after the dependency is established, similarly to as if
	// you had registered KVO with NSKeyValueObservingOptionInitial.
	
	// After changing y.a, the 'printing' dependencies' blocks/actions are run, since
	// 'self' now depends on y.a.
	y.a = @"world!";
}
- (void)change:(NSDictionary*)change inObject:(id)object forKeyPath:(NSString*)keyPath
{
    NSLog(@"Woah! %@ happened in -[%@ %@]!", change, object, keyPath);
}
- (void)somethingHappened
{
    NSLog(@"Something changed, but I have no idea what.");
}
@end

int main (int argc, const char * argv[]) {
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	
	[[[Foo new] autorelease] main];
    
    
    NSLog(@"Yay multiplication: %@", [$array($num(1), $num(2), $num(3)) sp_map:^(id obj) {
        return $num([obj intValue]*2);
    }]);
    
    NSLog(@"Yay dict fake literals %@", $dict(@"foo", @"bar"));
    
    Foo *foo = [Foo new];
    NSArray *objs = [[NSArray alloc] initWithObjects:foo, nil];
    [SPLifetimeGlue watchLifetimes:objs callback:^(SPLifetimeGlue *glue, id objectThatDied) {
        NSLog(@"Foo died");
    }];
    [objs release];
    NSLog(@"Will now kill foo:");
    [foo release];
    NSLog(@"Foo should be dead.");
	
	[pool drain];
    
    NSCAssert(fooCount == 0, @"Leaked a Foo");
    
	return 0;
}

