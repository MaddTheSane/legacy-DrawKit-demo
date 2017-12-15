#import "GCSCheckboxCell.h"

#import <DKDrawKit/LogEvent.h>

@implementation GCSCheckboxCell

#pragma mark -
#pragma mark As an NSCell
- (BOOL)trackMouse:(NSEvent *)theEvent inRect:(NSRect)cellFrame ofView:(NSView *)controlView untilMouseUp:(BOOL)untilMouseUp
{
#pragma unused(theEvent, untilMouseUp)
	//	LogEvent_(kReactiveEvent, @"tracking in checkbox starting");

	[self setHighlighted:YES];
	[controlView setNeedsDisplayInRect:cellFrame];

	// keep control until mouse up

	NSEvent *evt;
	BOOL loop = YES;
	BOOL wasIn, isIn;
	NSEventMask mask = NSEventMaskLeftMouseUp | NSEventMaskLeftMouseDragged;

	wasIn = YES;

	while (loop) {
		evt = [controlView.window nextEventMatchingMask:mask];

		switch (evt.type) {
			case NSEventTypeLeftMouseDragged: {
				NSPoint p = [controlView convertPoint:evt.locationInWindow fromView:nil];
				isIn = NSPointInRect(p, cellFrame);

				if (isIn != wasIn) {
					self.highlighted = isIn;
					[controlView setNeedsDisplayInRect:cellFrame];
					wasIn = isIn;
				}
			} break;

			case NSEventTypeLeftMouseUp:
				loop = NO;
				break;

			default:
				break;
		}
	}

	[self setHighlighted:NO];

	// if the mouse was in the cell when it was released, flip the checkbox state

	if (wasIn)
		self.intValue = !self.intValue;

	[controlView setNeedsDisplayInRect:cellFrame];

	//	LogEvent_(kReactiveEvent, @"tracking in checkbox ended");

	return wasIn;
}

- (char)charValue
{
	return (char)self.intValue;
}

@end
