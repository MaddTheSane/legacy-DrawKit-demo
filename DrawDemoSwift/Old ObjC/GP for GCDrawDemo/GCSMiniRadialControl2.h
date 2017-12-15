//
//  GCMiniRadialControl2.h
//  panel
//
//  Created by Graham on Tue Apr 17 2007.
//  Copyright (c) 2007 __MyCompanyName__. All rights reserved.
//

#import "GCSMiniControl.h"

@interface GCSMiniRadialControl2 : GCSMiniControl {
	NSColor *mTabColour;
	NSBezierPath *mTabPath;
	NSBezierPath *mHitTabPath;
	NSBezierPath *mIrisPath;
	NSPoint mCentre;
	NSSize mOffset;

	CGFloat mRadius;
	CGFloat mRingRadius;
	CGFloat mTabAngle;
	CGFloat mRingScale;
	BOOL mIrisDilating;
	BOOL mAutoFlip;
}

@property (nonatomic) NSPoint centre;

@property (nonatomic) CGFloat radius;

@property (nonatomic) CGFloat ringRadius;
- (void)setRingRadiusScale:(CGFloat)rsc;

@property (nonatomic, copy) NSColor *tabColor;

@property (nonatomic) CGFloat tabAngle;

@property (readonly, copy) NSBezierPath *irisPath;
@property (readonly, copy) NSBezierPath *tabPath;
- (void)invalidatePathCache;

@end

NS_ENUM(GCControlHitTest){
	kDKRadial2HitIris = 17,
	kDKRadial2HitTab = 18};
