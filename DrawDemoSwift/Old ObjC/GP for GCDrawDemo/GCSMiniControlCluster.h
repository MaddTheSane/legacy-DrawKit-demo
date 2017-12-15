//
//  GCMiniControlCluster.h
//  panel
//
//  Created by Graham on Thu Apr 12 2007.
//  Copyright (c) 2007 __MyCompanyName__. All rights reserved.
//

#import "GCSMiniControl.h"

/**
 
 The mini-control cluster owns one or more mini controls, and manages them as a group. The cluster of
 controls shares common attributes such as visibility and alpha value.
 
 A cluster may be owned by further clusters, or it may be owned by another object. Ultimately clusters
 must be owned by some sort of view and are drawn into that view.
 */
@interface GCSMiniControlCluster : GCSMiniControl {
	NSMutableArray<GCSMiniControl *> *mControls;
	NSMutableDictionary<NSString *, GCSMiniControl *> *mControlNames;
	NSTimer *mCATimerRef;
	__unsafe_unretained NSView *mViewRef;
	GCSMiniControl *mHitTarget;
	NSTimeInterval mFadeStartTime;

	CGFloat mControlAlpha;
	GCControlHitTest mHitPart;
	int mLinkPart;
	NSEventModifierFlags mLinkModFlagsMask;
	BOOL mVisible;
}

- (void)addMiniControl:(GCSMiniControl *)mc;
- (void)removeMiniControl:(GCSMiniControl *)mc;
@property (readonly, strong) NSArray<GCSMiniControl *> *controls;
- (GCSMiniControl *)controlAtIndex:(NSInteger)n;

- (void)setControl:(GCSMiniControl *)ctrl forKey:(NSString *)key;
- (GCSMiniControl *)controlForKey:(NSString *)key;

- (void)forceVisible:(BOOL)vis;
@property (nonatomic) BOOL visible;

@property (readwrite, nonatomic, weak) NSView *view;

@property (nonatomic) CGFloat alpha;
- (void)fadeControlAlphaWithTimeInterval:(NSTimeInterval)t;
- (void)timerFadeCallback:(NSTimer *)timer;

- (void)setLinkControlPart:(int)partcode modifierKeyMask:(NSEventModifierFlags)mask;

@end
