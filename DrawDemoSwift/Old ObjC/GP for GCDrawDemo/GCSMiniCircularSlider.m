//
//  GCMiniCircularSlider.m
//  panel
//
//  Created by Graham on Thu Apr 12 2007.
//  Copyright (c) 2007 __MyCompanyName__. All rights reserved.
//

#include <tgmath.h>
#import "GCSMiniCircularSlider.h"
#import "GCSMiniControlCluster.h"

#pragma mark Static Vars
static const CGFloat sConstrainAngle = 0.261799387799; // 15 degrees

@implementation GCSMiniCircularSlider
#pragma mark As a GCMiniCircularSlider
- (NSRect)circleBounds
{
	NSRect ar = NSInsetRect(self.bounds, 8, 8);

	if (ar.size.width > ar.size.height)
		ar.size.width = ar.size.height;
	else
		ar.size.height = ar.size.width;

	ar.origin.x = ((NSMinX(self.bounds) + NSMaxX(self.bounds)) / 2.0) - (ar.size.width / 2.0);
	ar.origin.y = ((NSMinY(self.bounds) + NSMaxY(self.bounds)) / 2.0) - (ar.size.height / 2.0);

	return ar;
}

#pragma mark -
#pragma mark As a GCMiniSlider
- (NSRect)knobRect
{
	NSRect ar = self.circleBounds;

	CGFloat radius = ar.size.width / 2.0;

	NSPoint cp;
	NSRect kr;

	cp.x = NSMidX(ar);
	cp.y = NSMidY(ar);

	kr.origin.x = (cp.x + (cos([self value]) * radius)) - (mKnobImage.size.width / 2.0);
	kr.origin.y = (cp.y + (sin([self value]) * radius)) - (mKnobImage.size.height / 2.0);
	kr.size = mKnobImage.size;

	return kr;
}

#pragma mark -
#pragma mark As a GCMiniControl
- (void)draw
{
	NSRect ar = self.circleBounds;

	NSBezierPath *path = [NSBezierPath bezierPathWithOvalInRect:ar];
	path.lineWidth = 10;
	[[NSGraphicsContext currentContext] saveGraphicsState];

	[self applyShadow];
	[[self themeColour:kDKMiniControlThemeBackground] set];
	[path stroke];

	[[NSGraphicsContext currentContext] restoreGraphicsState];

	if (self.showTickMarks) {
		// append ticks to path. show ticks every 15 degrees

		CGFloat radius = (ar.size.width / 2.0);
		CGFloat tickLength = 3, a = 0.0;
		NSPoint cp, ts, te;

		cp.x = NSMidX(ar);
		cp.y = NSMidY(ar);

		for (NSInteger t = 0; t < 24; ++t) {
			ts.x = cp.x + (cos(a) * (radius - tickLength));
			ts.y = cp.y + (sin(a) * (radius - tickLength));
			te.x = cp.x + (cos(a) * (radius + tickLength));
			te.y = cp.y + (sin(a) * (radius + tickLength));

			[path moveToPoint:ts];
			[path lineToPoint:te];

			a += sConstrainAngle;
		}
	}

	path.lineWidth = 0.5;

	NSAffineTransform *tfm = [NSAffineTransform transform];
	[tfm translateXBy:0 yBy:1];
	[path transformUsingAffineTransform:tfm];

	[[self themeColour:kDKMiniControlThemeSliderTrkHilite] set];
	[path stroke];

	tfm = [NSAffineTransform transform];
	[tfm translateXBy:0 yBy:-1];
	[path transformUsingAffineTransform:tfm];
	[[self themeColour:kDKMiniControlThemeSliderTrack] set];
	[path stroke];

	// draw the knob

	[mKnobImage drawInRect:[self knobRect] fromRect:NSZeroRect operation:NSCompositingOperationSourceAtop fraction:self.cluster.alpha];
}

- (void)flagsChanged:(NSEventModifierFlags)flags
{
	BOOL shift = (flags & NSEventModifierFlagShift) != 0;
	self.showTickMarks = shift;
}

- (instancetype)initWithBounds:(NSRect)rect inCluster:(GCSMiniControlCluster *)clust
{
	self = [super initWithBounds:rect inCluster:clust];
	if (self != nil) {
		mValue = 0.0;
		mMinValue = -M_PI;
		mMaxValue = M_PI;
		[self setInfoWindowMode:kDKMiniControlInfoWindowFollowsMouse];
	}
	return self;
}

- (BOOL)mouseDownAt:(NSPoint)startPoint inPart:(GCControlHitTest)part modifierFlags:(NSEventModifierFlags)flags
{
#pragma unused(startPoint, flags)
	if (part == kDKMiniSliderKnob) {
		NSString *fstr = @"0.0\u00B0";

		CGFloat degrees = fmod(([self value] * 180.0) / M_PI, 360.0);
		[self setupInfoWindowAtPoint:[self knobRect].origin withValue:degrees andFormat:fstr];
		return YES;
	} else
		return NO;
}

- (BOOL)mouseDraggedAt:(NSPoint)currentPoint inPart:(GCControlHitTest)part modifierFlags:(NSEventModifierFlags)flags
{
#pragma unused(part)
	// recalculate the value based on the position of the knob

	NSPoint cp;
	NSRect ar = self.circleBounds;

	cp.x = NSMidX(ar);
	cp.y = NSMidY(ar);

	CGFloat angle = atan2(currentPoint.y - cp.y, currentPoint.x - cp.x);

	// constrain angle if shift down

	BOOL shift = (flags & NSEventModifierFlagShift) != 0;

	if (shift) {
		CGFloat rem = fmod(angle, sConstrainAngle);

		if (rem > sConstrainAngle / 2.0)
			angle += (sConstrainAngle - rem);
		else
			angle -= rem;
	}

	[self setNeedsDisplayInRect:[self knobRect]];
	self.value = angle;
	[self setNeedsDisplayInRect:[self knobRect]];

	CGFloat degrees = fmod(([self value] * 180.0f) / M_PI, 360.0);

	[self updateInfoWindowAtPoint:[self knobRect].origin withValue:degrees];

	return YES;
}

@end
