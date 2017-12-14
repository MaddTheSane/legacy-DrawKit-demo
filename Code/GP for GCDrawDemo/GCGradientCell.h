//
//  GCGradientCell.h
//  GradientTest
//
//  Created by Jason Jobe on 3/3/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "DKGradientCell.h"
#import "GCMiniControl.h"
#import "GCGradientWell.h"

@class GCMiniControl;
@class GCMiniControlCluster;

//! internal "partcodes" for where a mouse hit occurred
typedef NS_ENUM(NSInteger, DKHitGCGradientCell) {
	kDKHitNone = 0,
	kDKHitMiniControl = 5,
	kDKHitProxyIcon = 7,
	kDKHitOther = 999
};

@interface GCGradientCell : DKGradientCell <GCMiniControlDelegate> {
	NSRect mControlBoundsRect;
	GCMiniControlCluster *mMiniControls;
	BOOL mUpdatingControls;
	DKHitGCGradientCell mHitPart;
}

- (void)setMiniControlBoundsWithCellFrame:(NSRect)cframe forMode:(DKGradientWellMode)mode;
- (void)setMiniControlBounds:(NSRect)br withIdentifier:(NSString *)key;
- (void)drawMiniControlsForMode:(DKGradientWellMode)mode;
- (GCMiniControlCluster *)controlClusterForMode:(DKGradientWellMode)mode;
- (GCMiniControl *)miniControlForIdentifier:(NSString *)key;
//! Sets the minicontrol values in \c mode cluster to match the current gradient.
- (void)updateMiniControlsForMode:(DKGradientWellMode)mode;

- (NSRect)proxyIconRectInCellFrame:(NSRect)rect;

- (void)setControlVisible:(BOOL)vis;

@end

#define kDKDefaultGradientCellInset (NSMakeSize(8.0, 8.0))
