//
//  GCMiniControl.m
//  panel
//
//  Created by Graham on Thu Apr 12 2007.
//  Copyright (c) 2007 __MyCompanyName__. All rights reserved.
//

#import "GCMiniControl.h"
#import "GCMiniControlCluster.h"
#import <DKDrawKit/GCInfoFloater.h>
#import <DKDrawKit/LogEvent.h>

@implementation GCMiniControl
#pragma mark As a GCMiniControl
+ (NSColor *)miniControlThemeColor:(DKControlThemeElement)themeElementID withAlpha:(CGFloat)alpha
{
	switch (themeElementID) {
		case kDKMiniControlThemeBackground:
			return [[NSColor lightGrayColor] colorWithAlphaComponent:0.25 * alpha];

		case kDKMiniControlThemeSliderTrack:
			return [[NSColor blackColor] colorWithAlphaComponent:0.67 * alpha];

		case kDKMiniControlThemeSliderTrkHilite:
			return [[NSColor lightGrayColor] colorWithAlphaComponent:0.67 * alpha];

		case kDKMiniControlThemeKnobInterior:
			return [[NSColor grayColor] colorWithAlphaComponent:0.5 * alpha];

		case kDKMiniControlThemeKnobStroke:
			return [[NSColor whiteColor] colorWithAlphaComponent:0.67 * alpha];

		case kDKMiniControlThemeIris:
			return [[NSColor lightGrayColor] colorWithAlphaComponent:0.33 * alpha];

		default:
			return nil;
	}
}

#pragma mark -
- (instancetype)initWithBounds:(NSRect)rect inCluster:(GCMiniControlCluster *)clust
{
	self = [super init];
	if (self != nil) {
		self.bounds = rect;
		mClusterRef = clust;
		NSAssert(mIdent == nil, @"Expected init to zero");
		NSAssert(mDelegateRef == nil, @"Expected init to zero");
		mInfoWin = [GCInfoFloater infoFloater];

		NSAssert(mValue == 0.0, @"Expected init to zero");
		NSAssert(mMinValue == 0.0, @"Expected init to zero");
		mMaxValue = 1.0;
		NSAssert(mInfoWMode == kDKMiniControlNoInfoWindow, @"Expected init to zero");
		mApplyShadow = YES;

		if (mInfoWin == nil) {
			return nil;
		}
		if (clust != nil) {
			[clust addMiniControl:self];
		}
	}
	return self;
}

@synthesize cluster = mClusterRef;

- (NSView *)view
{
	return self.cluster.view;
}

#pragma mark -
@synthesize bounds=mBounds;

- (void)draw
{
	// override to do something
}

#pragma mark -
- (void)applyShadow
{
	if (mApplyShadow) {
		NSShadow *shadowObj = [[NSShadow alloc] init];

		shadowObj.shadowColor = [NSColor blackColor];
		shadowObj.shadowOffset = NSMakeSize(2, -2);
		shadowObj.shadowBlurRadius = 1.0;
		[shadowObj set];
	}
}

#pragma mark -
- (void)setNeedsDisplay
{
	// relies on the delegate implementing setNeedsDisplayInRect: there is no guarantee that this will actually
	// cause a redraw - you need to set it up to work.

	[self setNeedsDisplayInRect:self.bounds];
}

- (void)setNeedsDisplayInRect:(NSRect)rect
{
	// relies on the delegate implementing setNeedsDisplayInRect: there is no guarantee that this will actually
	// cause a redraw - you need to set it up to work.

	if (self.view)
		[self.view setNeedsDisplayInRect:rect];
	else if (self.delegate && [self.delegate respondsToSelector:@selector(setNeedsDisplayInRect:)])
		[(NSView *)self.delegate setNeedsDisplayInRect:rect];
}

#pragma mark -
- (NSColor *)themeColour:(DKControlThemeElement)themeElementID
{
	// returns theme colour but applies local value of alpha

	return [[self class] miniControlThemeColor:themeElementID withAlpha:self.cluster.alpha];
}

#pragma mark -
- (GCControlHitTest)hitTestPoint:(NSPoint)p
{
	return (NSPointInRect(p, self.bounds)) ? kDKMiniControlEntireControl : kDKMiniControlNoPart;
}

#pragma mark -
- (BOOL)mouseDownAt:(NSPoint)startPoint inPart:(GCControlHitTest)part modifierFlags:(NSEventModifierFlags)flags
{
#pragma unused(flags)
	// override to do something, call super to handle info windows

	//	LogEvent_(kReactiveEvent, @"mini-control mouse down, part = %d", part);

	if (part != kDKMiniControlNoPart) {
		[self setupInfoWindowAtPoint:startPoint withValue:self.value andFormat:nil];
		return YES;
	} else
		return NO;
}

- (BOOL)mouseDraggedAt:(NSPoint)currentPoint inPart:(GCControlHitTest)part modifierFlags:(NSEventModifierFlags)flags
{
#pragma unused(part, flags)
	// override to do something, call super to handle info windows

	[self updateInfoWindowAtPoint:currentPoint withValue:self.value];
	return YES;
}

- (void)mouseUpAt:(NSPoint)endPoint inPart:(GCControlHitTest)part modifierFlags:(NSEventModifierFlags)flags
{
#pragma unused(endPoint, part, flags)
	// override to do something, call super to handle info windows
	//	LogEvent_(kReactiveEvent, @"mini-control mouse up, part = %d", part);
	[self hideInfoWindow];
}

- (void)flagsChanged:(NSEventModifierFlags)flags
{
#pragma unused(flags)
	// override to do something

	//	LogEvent_(kInfoEvent, @"mini-control flags changed, flags = %d", flags);
}

#pragma mark -
- (void)setInfoWindowMode:(DKControlInfoWindowMode)mode
{
	mInfoWMode = mode;
}

- (void)setupInfoWindowAtPoint:(NSPoint)p withValue:(CGFloat)val andFormat:(NSString *)format
{
	if (mInfoWMode != kDKMiniControlNoInfoWindow) {
		if (mInfoWin == nil)
			mInfoWin = [GCInfoFloater infoFloater];

		if (format)
			[self setInfoWindowFormat:format];

		[self updateInfoWindowAtPoint:p withValue:val];
		[mInfoWin orderFront:self];
	}
}

#pragma mark -
- (void)updateInfoWindowAtPoint:(NSPoint)p withValue:(CGFloat)val
{
	// let delegate have opportunity to set this value

	if (self.delegate && [self.delegate respondsToSelector:@selector(miniControlWillUpdateInfoWindow:withValue:)])
		val = [self.delegate miniControlWillUpdateInfoWindow:self withValue:val];

	[mInfoWin setFloatValue:val];

	if (mInfoWMode == kDKMiniControlInfoWindowFollowsMouse)
		[mInfoWin positionNearPoint:p inView:self.view];
	else if (mInfoWMode == kDKMiniControlInfoWindowCentred) {
		// position window above and centred horizontally in bounds

		NSRect wfr = mInfoWin.frame;
		NSRect br = self.bounds;
		NSPoint wp;

		wp.x = ((NSMinX(br) + NSMaxX(br)) / 2.0) - (NSWidth(wfr) / 2.0);
		wp.y = NSMinY(br) - 2; //NSHeight( wfr );

		[mInfoWin positionNearPoint:wp inView:self.view];
	}
}

- (void)hideInfoWindow
{
	[mInfoWin hide];
}

- (void)setInfoWindowFormat:(NSString *)format
{
	[mInfoWin setFormat:format];
}

- (void)setInfoWindowValue:(CGFloat)value
{
	[mInfoWin setFloatValue:value];
}

#pragma mark -
@synthesize delegate = mDelegateRef;

- (id)delegate
{
	// return the delegate if we have one, otherwise use the cluster's delegate

	if (mDelegateRef)
		return mDelegateRef;
	else
		return self.cluster.delegate;
}

- (void)notifyDelegateWillChange:(id)value
{
	if (self.delegate && [self.delegate respondsToSelector:@selector(miniControl:willChangeValue:)])
		[self.delegate miniControl:self willChangeValue:value];
}

- (void)notifyDelegateDidChange:(id)value
{
	if (self.delegate && [self.delegate respondsToSelector:@selector(miniControl:didChangeValue:)])
		[self.delegate miniControl:self didChangeValue:value];
}

#pragma mark -
- (void)setIdentifier:(NSString *)name
{
	// stores the control against <name> in the owning cluster, so it can easily be located by name

	mIdent = [name copy];
	[self.cluster setControl:self forKey:mIdent];
}

@synthesize identifier=mIdent;

#pragma mark -
- (void)setValue:(CGFloat)v
{
	v = MAX(v, [self minValue]);
	v = MIN(v, [self maxValue]);

	if (v != mValue) {
		[self notifyDelegateWillChange:@(mValue)];
		mValue = v;
		[self notifyDelegateDidChange:@(mValue)];
	}
}

@synthesize value=mValue;

#pragma mark -
- (void)setMaxValue:(CGFloat)v
{
	mMaxValue = v;

	if (mValue > mMaxValue)
		self.value = mMaxValue;
}

@synthesize maxValue=mMaxValue;

#pragma mark -
- (void)setMinValue:(CGFloat)v
{
	mMinValue = v;

	if (mValue < mMinValue)
		self.value = mMinValue;
}

@synthesize minValue=mMinValue;

#pragma mark -
#pragma mark As an NSObject

@end

/*
@implementation  NSObject (GCMiniControlDelegate)

- (void)		miniControl:(GCMiniControl*) mc willChangeValue:(id) newValue
{
	LogEvent_(kReactiveEvent, @"miniControl '%@' willChangeValue '%@'", mc,  newValue);
}


- (void)		miniControl:(GCMiniControl*) mc didChangeValue:(id) newValue
{
	LogEvent_(kReactiveEvent, @"miniControl '%@' didChangeValue '%@'", mc,  newValue);
}

@end
*/
