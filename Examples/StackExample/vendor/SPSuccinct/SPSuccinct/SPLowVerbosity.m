#import "SPLowVerbosity.h"

NSString *$ipadPath(NSString *path)
{
    NSString *ext = [path pathExtension];
    NSString *base = [path stringByDeletingPathExtension];
    return $sprintf(@"%@~ipad.%@", base, ext);
}

NSString *$urlencode(NSString *unencoded) {
	// Thanks, http://www.tikirobot.net/wp/2007/01/27/url-encode-in-cocoa/
    CFStringRef ret = CFURLCreateStringByAddingPercentEscapes(
														kCFAllocatorDefault, 
														(CFStringRef)unencoded, 
														NULL, 
														(CFStringRef)@";/?:@&=+$,", 
														kCFStringEncodingUTF8
														);
#if __has_feature(objc_arc)
    return [(__bridge id)ret;
#else
    return [(id)ret autorelease];
#endif
}

id SPDictionaryWithPairs(NSArray *pairs, BOOL mutablep)
{
	NSUInteger count = pairs.count/2;
	id keys[count], values[count];
	size_t kvi = 0;
	for(size_t idx = 0; kvi < count;) {
		keys[kvi] = [pairs objectAtIndex:idx++];
		values[kvi++] = [pairs objectAtIndex:idx++];
	}
	return [mutablep?[NSMutableDictionary class]:[NSDictionary class] dictionaryWithObjects:values forKeys:keys count:kvi];
}

id SPDictionaryMerge(id dictionary1, id dictionary2, BOOL mutablep)
{
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithDictionary:dictionary1];
    for (id key in dictionary2)
        [result setObject:[dictionary2 objectForKey:key] forKey:key];
    return (mutablep ? result : [NSDictionary dictionaryWithDictionary:result]);
}

NSError *$makeErr(NSString *domain, NSInteger code, NSString *localizedDesc)
{
    return [NSError errorWithDomain:domain code:code userInfo:$dict(
        NSLocalizedDescriptionKey, localizedDesc
    )];
}