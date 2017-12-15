//
//  GCGradientCell.h
//  GradientTest
//
//  Created by Jason Jobe on 3/3/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "DKSGradientCell.h"
#import "GCSMiniControl.h"
#import "GCSGradientWell.h"

@class GCSMiniControl;
@class GCSMiniControlCluster;

//! internal "partcodes" for where a mouse hit occurred
typedef NS_ENUM(NSInteger, DKHitGCGradientCell) {
	kDKHitNone = 0,
	kDKHitMiniControl = 5,
	kDKHitProxyIcon = 7,
	kDKHitOther = 999
};

@interface GCSGradientCell : DKSGradientCell <GCSMiniControlDelegate> {
	NSRect mControlBoundsRect;
	GCSMiniControlCluster *mMiniControls;
	BOOL mUpdatingControls;
	DKHitGCGradientCell mHitPart;
}

- (void)setMiniControlBoundsWithCellFrame:(NSRect)cframe forMode:(DKSGradientWellMode)mode;
- (void)setMiniControlBounds:(NSRect)br withIdentifier:(NSString *)key;
- (void)drawMiniControlsForMode:(DKSGradientWellMode)mode;
- (GCSMiniControlCluster *)controlClusterForMode:(DKSGradientWellMode)mode;
- (GCSMiniControl *)miniControlForIdentifier:(NSString *)key;
//! Sets the minicontrol values in \c mode cluster to match the current gradient.
- (void)updateMiniControlsForMode:(DKSGradientWellMode)mode;

- (NSRect)proxyIconRectInCellFrame:(NSRect)rect;

- (void)setControlVisible:(BOOL)vis;

@end

#define kDKDefaultGradientCellInset (NSMakeSize(8.0, 8.0))
