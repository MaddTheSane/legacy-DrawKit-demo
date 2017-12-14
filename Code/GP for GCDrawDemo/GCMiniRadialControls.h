//
//  GCMiniRadialControls.h
//  panel
//
//  Created by Graham on Thu Apr 12 2007.
//  Copyright (c) 2007 __MyCompanyName__. All rights reserved.
//

#import "GCMiniControl.h"

@interface GCMiniRadialControls : GCMiniControl {
	CGFloat mRadius;
	NSPoint mCentre;
}

@property (nonatomic) NSPoint centre;

@property (nonatomic) CGFloat radius;

@property (readonly) NSRect targetRect;
@property (readonly) NSRect rectForRadius;

@end

// hit part codes:

NS_ENUM(GCControlHitTest){kDKHitRadialTarget = 24, kDKHitRadialRadius = 42};
