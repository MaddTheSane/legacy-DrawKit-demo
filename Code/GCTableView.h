/* GCTableView */

#import <Cocoa/Cocoa.h>

@interface GCTableView : NSTableView
@end

// declare a custom NSCell class for drawing a colour in a table's column

@interface GCColourCell : NSCell {
	NSColor *mColour;
	NSRect mFrame;
	NSView *mControlView;
}

@property (nonatomic, copy) NSColor *colorValue;

@end

@interface NSObject (GCColourCellHack)

- (void)setTemporaryColour:(NSColor *)aColour forTableView:(NSTableView *)tView row:(NSInteger)row;

@end
