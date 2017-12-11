//
//  GCMiniRadialControl2.h
//  panel
//
//  Created by Graham on Tue Apr 17 2007.
//  Copyright (c) 2007 __MyCompanyName__. All rights reserved.
//

#import "GCMiniControl.h"


@interface GCMiniRadialControl2 : GCMiniControl
{
	NSColor*		mTabColour;
	NSBezierPath*   mTabPath;
	NSBezierPath*   mHitTabPath;
	NSBezierPath*   mIrisPath;
	NSPoint			mCentre;
	NSSize			mOffset;
	
	CGFloat			mRadius;
	CGFloat			mRingRadius;
	CGFloat			mTabAngle;
	CGFloat			mRingScale;
	BOOL			mIrisDilating;
	BOOL			mAutoFlip;
}


- (void)			setCentre:(NSPoint) p;
- (NSPoint)			centre;

- (void)			setRadius:(CGFloat) radius;
- (CGFloat)			radius;

- (void)			setRingRadius:(CGFloat) radius;
- (CGFloat)			ringRadius;
- (void)			setRingRadiusScale:(CGFloat) rsc;

- (void)			setTabColor:(NSColor*) colour;
- (NSColor*)		tabColor;

- (void)			setTabAngle:(CGFloat) ta;
- (CGFloat)			tabAngle;

- (NSBezierPath*)   irisPath;
- (NSBezierPath*)   tabPath;
- (void)			invalidatePathCache;


@end


enum
{
	kDKRadial2HitIris   = 17,
	kDKRadial2HitTab	= 18
};
