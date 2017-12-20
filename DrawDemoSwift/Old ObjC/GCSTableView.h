/* GCTableView */

#import <Cocoa/Cocoa.h>

@interface GCSTableView : NSTableView
@end

// declare a custom NSCell class for drawing a colour in a table's column

@interface GCSColourCell : NSCell {
	NSColor *mColour;
	BOOL mHighlighted;
	NSRect mFrame;
	NSView *mControlView;
}

@property (copy) NSColor *colorValue;
- (void)setState:(BOOL)state;

@end

@interface NSObject (GCColourCellHack)

- (void)setTemporaryColour:(NSColor *)aColour forTableView:(NSTableView *)tView row:(NSInteger)row;

@end
