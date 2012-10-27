
enum SPSeparatorStyle
{
    SPSeparatorStyleSingleLine = 0,     // { 0, 0, 0, 0.25 }
    SPSeparatorStyleSingleLineEtched    // [ { 0, 0, 0, 0.25 }, { 1, 1, 1, 1 } ]
};
typedef enum SPSeparatorStyle SPSeparatorStyle;

@interface SPSeparatorView : UIView
@property (nonatomic)   SPSeparatorStyle    style;

// one color if single line, two colors if etched single line.
// see SPSeparatorStyle for default values (if -colors is nil).
- (NSArray*)colors;
- (void)setColors:(NSArray*)colors;
@end
