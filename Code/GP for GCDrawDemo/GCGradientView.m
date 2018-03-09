//
//  GCGradientView.m
//  panel
//
//  Created by Graham on Wed Apr 11 2007.
//  Copyright (c) 2007 __MyCompanyName__. All rights reserved.
//

#import "GCGradientView.h"
#import <DKDrawKit/DKGradient.h>

@implementation GCGradientView

- (id)initWithFrame:(NSRect)frame
{
	self = [super initWithFrame:frame];

	if (self) {
		[self setGradient:[DKGradient defaultGradient]];
	}
	return self;
}

- (BOOL)isFlipped
{
	return YES;
}

- (void)drawRect:(NSRect)rect
{
#pragma unused(rect)
	[[self gradient] fillRect:[self bounds]];
}

- (void)setGradient:(DKGradient *)grad
{
	_gradient = grad;
	[self setNeedsDisplay:YES];
}

@synthesize gradient=_gradient;

@end

@implementation GCGradientListView

- (id)initWithFrame:(NSRect)frame
{
	self = [super initWithFrame:frame];

	if (self) {
		_list = nil;
		_cellSize = kGCDefaultListViewCellSize;
		_cellSpacing = kGCDefaultListViewCellSpacing;
	}
	return self;
}

- (BOOL)isFlipped
{
	return YES;
}

- (void)drawRect:(NSRect)rect
{
#pragma unused(rect)
	// render each gradient in the list in a row/column matrix arrangement

	NSRect r = [self bounds];
	NSInteger rows, cols;
	DKGradient *grad;
	NSRect gr;

	cols = MAX(1, NSWidth(r) / (_cellSize.width + _cellSpacing.width));
	rows = ([_list count] / cols) + 1;

	gr.origin.x = _cellSpacing.width;
	gr.origin.y = _cellSpacing.height;
	gr.size = _cellSize;

	for (NSInteger j = 0; j < rows; ++j) {
		for (NSInteger k = 0; k < cols; ++k) {
			NSInteger i = (j * cols) + k;

			if (i >= 0 && i < (NSInteger)[_list count]) {
				grad = [_list objectAtIndex:i];
				[grad fillRect:gr];
			}

			gr.origin.x += (_cellSize.width + _cellSpacing.width);
		}

		gr.origin.y += (_cellSize.height + _cellSpacing.height);
		gr.origin.x = _cellSpacing.width;
	}
}

@synthesize gradientList=_list;
@synthesize cellSize=_cellSize;

@end
