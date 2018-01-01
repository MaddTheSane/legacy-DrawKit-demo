/* GCTableView */

#import <Cocoa/Cocoa.h>

@protocol GCSColourCellHack <NSObject>

- (void)setTemporaryColour:(NSColor *)aColour forTableView:(NSTableView *)tView row:(NSInteger)row;

@end
