//
//  NSBezierPath+GCAdditions.m
//  GCDrawKit
//
//  Created by graham on 12/04/2007.
//  Copyright 2007 Apptree.net. All rights reserved.
//

#include <tgmath.h>
#import "NSBezierPath+GCAdditions.h"

@implementation NSBezierPath (GCAdditions)
#pragma mark As a NSBezierPath
+ (NSBezierPath *)bezierPathWithTargetInRect:(NSRect)rect
{
	NSRect ir = NSInsetRect(rect, rect.size.width / 4, rect.size.height / 4);
	NSBezierPath *path = [self bezierPathWithOvalInRect:ir];

	NSPoint a, b;

	a.x = NSMinX(rect);
	a.y = NSMidY(rect);
	b.x = NSMaxX(rect);
	b.y = NSMidY(rect);

	[path moveToPoint:a];
	[path lineToPoint:b];

	a.x = NSMidX(rect);
	a.y = NSMinY(rect);
	b.x = NSMidX(rect);
	b.y = NSMaxY(rect);

	[path moveToPoint:a];
	[path lineToPoint:b];

	return path;
}

+ (NSBezierPath *)bezierPathWithRoundEndedRectInRect:(NSRect)rect
{
	if (rect.size.width == rect.size.height)
		return [NSBezierPath bezierPathWithOvalInRect:rect];
	else {
		NSSize rs = rect.size;
		BOOL vertical = (rs.width < rs.height);
		CGFloat radius = MIN(rs.width, rs.height);

		radius /= 2.0;

		NSBezierPath *path = [NSBezierPath bezierPath];

		if (!vertical) {
			[path moveToPoint:NSMakePoint(NSMinX(rect) + radius, NSMinY(rect))];
			[path appendBezierPathWithArcWithCenter:NSMakePoint(NSMaxX(rect) - radius, NSMinY(rect) + radius) radius:radius startAngle:270.0 endAngle:90.0];
			[path appendBezierPathWithArcWithCenter:NSMakePoint(NSMinX(rect) + radius, NSMinY(rect) + radius) radius:radius startAngle:90.0 endAngle:270.0];
		} else {
			[path moveToPoint:NSMakePoint(NSMaxX(rect), NSMinY(rect) + radius)];
			[path appendBezierPathWithArcWithCenter:NSMakePoint(NSMinX(rect) + radius, NSMaxY(rect) - radius) radius:radius startAngle:0.0 endAngle:180.0];
			[path appendBezierPathWithArcWithCenter:NSMakePoint(NSMinX(rect) + radius, NSMinY(rect) + radius) radius:radius startAngle:180.0 endAngle:0.0];
		}

		[path closePath];

		return path;
	}
}

+ (NSBezierPath *)roundRectInRect:(NSRect)rect andCornerRadius:(CGFloat)radius
{
	// Make sure radius doesn't exceed a maximum size

	if (radius >= (rect.size.height / 2))
		radius = rect.size.height * 0.5f;

	if (radius >= (rect.size.width / 2))
		radius = rect.size.width * 0.5f;

	// Make sure silly values simply lead to un-rounded corners:

	if (radius <= 0)
		return [NSBezierPath bezierPathWithRect:rect];

	// Now draw our rectangle:
	NSRect innerRect = NSInsetRect(rect, radius, radius); // Make rect with corners being centers of the corner circles.
	NSBezierPath *path = [NSBezierPath bezierPath];

	[path moveToPoint:NSMakePoint(rect.origin.x, rect.origin.y + radius)];

	// Bottom left (origin):
	[path appendBezierPathWithArcWithCenter:innerRect.origin radius:radius startAngle:180.0 endAngle:270.0];

	// Bottom right:
	[path appendBezierPathWithArcWithCenter:NSMakePoint(NSMaxX(innerRect), NSMinY(innerRect)) radius:radius startAngle:270.0 endAngle:360.0];

	// Top right:
	[path appendBezierPathWithArcWithCenter:NSMakePoint(NSMaxX(innerRect), NSMaxY(innerRect)) radius:radius startAngle:0.0 endAngle:90.0];

	// Top left:
	[path appendBezierPathWithArcWithCenter:NSMakePoint(NSMinX(innerRect), NSMaxY(innerRect)) radius:radius startAngle:90.0 endAngle:180.0];
	[path closePath]; // Implicitly creates left edge.

	return path;
}

+ (NSBezierPath *)bezierPathWithOffsetTargetInRect:(NSRect)rect offset:(NSInteger)off
{
	if (off == 0)
		return [NSBezierPath bezierPathWithTargetInRect:rect];
	else {
		NSRect ir = NSInsetRect(rect, rect.size.width / 8, rect.size.height / 4);

		if (off == -1)
			ir.origin.x = NSMinX(rect);
		else
			ir.origin.x = NSMinX(rect) + rect.size.width / 4;

		NSBezierPath *path = [NSBezierPath bezierPathWithRoundEndedRectInRect:ir];

		NSPoint a, b;

		a.x = NSMinX(rect);
		a.y = NSMidY(rect);
		b.x = NSMaxX(rect);
		b.y = NSMidY(rect);

		[path moveToPoint:a];
		[path lineToPoint:b];

		a.x = NSMidX(rect);
		a.y = NSMinY(rect);
		b.x = NSMidX(rect);
		b.y = NSMaxY(rect);

		[path moveToPoint:a];
		[path lineToPoint:b];

		return path;
	}
}

#pragma mark -
+ (NSBezierPath *)bezierPathWithIrisRingWithRadius:(CGFloat)radius width:(CGFloat)width tabAngle:(CGFloat)angle tabSize:(NSSize)tabsize
{
	NSBezierPath *path = [NSBezierPath bezierPathWithIrisRingWithRadius:radius width:width tabSize:tabsize];

	// now rotate the path to the desired angle

	NSAffineTransform *tfm = [NSAffineTransform transform];
	[tfm rotateByRadians:angle];
	[path transformUsingAffineTransform:tfm];

	return path;
}

+ (NSBezierPath *)bezierPathWithIrisRingWithRadius:(CGFloat)radius width:(CGFloat)width tabSize:(NSSize)tabsize
{
	NSBezierPath *path = [NSBezierPath bezierPath];

	path.windingRule = NSEvenOddWindingRule;
	//[path moveToPoint:NSZeroPoint];

	// outer ring leaves a gap for the tab to connect

	CGFloat a, sa, ea;

	a = atan2((tabsize.height / 2), (radius + width / 2));

	// arc angles in degrees:

	sa = -((a * 180.0) / M_PI);
	ea = (a * 180.0) / M_PI;

	[path appendBezierPathWithArcWithCenter:NSZeroPoint radius:(radius + width / 2) startAngle:sa endAngle:ea clockwise:YES];

	// and the tab
	NSPoint rp;

	rp.x = tabsize.width;
	rp.y = 0;

	[path relativeLineToPoint:rp];

	rp.y = -tabsize.height;
	rp.x = 0;

	[path relativeLineToPoint:rp];

	rp.x = -tabsize.width;
	rp.y = 0;

	[path relativeLineToPoint:rp];

	// inner ring

	rp.x = radius - width / 2;
	rp.y = 0;
	[path moveToPoint:rp];
	[path appendBezierPathWithArcWithCenter:NSZeroPoint radius:(radius - width / 2) startAngle:0.0 endAngle:360.0 clockwise:NO];

	return path;
}

+ (NSBezierPath *)bezierPathWithIrisTabWithRadius:(CGFloat)radius width:(CGFloat)width tabAngle:(CGFloat)angle tabSize:(NSSize)tabsize
{
	NSBezierPath *path = [NSBezierPath bezierPathWithIrisTabWithRadius:radius width:width tabSize:tabsize];

	NSAffineTransform *tfm = [NSAffineTransform transform];
	[tfm rotateByRadians:angle];
	[path transformUsingAffineTransform:tfm];

	return path;
}

+ (NSBezierPath *)bezierPathWithIrisTabWithRadius:(CGFloat)radius width:(CGFloat)width tabSize:(NSSize)tabsize
{
	NSBezierPath *path = [NSBezierPath bezierPath];

	NSPoint rp;

	rp.x = radius + (width / 2);
	rp.y = -(tabsize.height / 2);

	[path moveToPoint:rp];

	rp.x = tabsize.width;
	rp.y = 0;
	[path relativeLineToPoint:rp];
	rp.x = 0;
	rp.y = tabsize.height;
	[path relativeLineToPoint:rp];
	rp.x = -tabsize.width;
	rp.y = 0;
	[path relativeLineToPoint:rp];
	[path closePath];

	return path;
}

@end
