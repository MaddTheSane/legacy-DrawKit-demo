//
//  GCMiniControlCluster.h
//  panel
//
//  Created by Graham on Thu Apr 12 2007.
//  Copyright (c) 2007 __MyCompanyName__. All rights reserved.
//

#import "GCMiniControl.h"


/**
 
 The mini-control cluster owns one or more mini controls, and manages them as a group. The cluster of
 controls shares common attributes such as visibility and alpha value.
 
 A cluster may be owned by further clusters, or it may be owned by another object. Ultimately clusters
 must be owned by some sort of view and are drawn into that view.
 */
@interface GCMiniControlCluster : GCMiniControl
{
	NSMutableArray<GCMiniControl*>*			mControls;
	NSMutableDictionary<NSString*,GCMiniControl*>*	mControlNames;
	NSTimer*				mCATimerRef;
	__unsafe_unretained NSView *mViewRef;
	GCMiniControl*			mHitTarget;
	NSTimeInterval			mFadeStartTime;
	
	CGFloat mControlAlpha;
	GCControlHitTest mHitPart;
	int						mLinkPart;
	NSEventModifierFlags	mLinkModFlagsMask;
	BOOL					mVisible;
}


- (void)addMiniControl:(GCMiniControl*) mc;
- (void)removeMiniControl:(GCMiniControl*) mc;
@property (readonly, retain) NSArray<GCMiniControl*> *controls;
- (GCMiniControl*)controlAtIndex:(NSInteger) n;

- (void)					setControl:(GCMiniControl*) ctrl forKey:(NSString*) key;
- (GCMiniControl*)			controlForKey:(NSString*) key;

- (void)forceVisible:(BOOL) vis;
@property (nonatomic) BOOL visible;

@property (readwrite, nonatomic, assign) NSView *view;

@property (nonatomic) CGFloat alpha;
- (void)					fadeControlAlphaWithTimeInterval:(NSTimeInterval) t;
- (void)					timerFadeCallback:(NSTimer*) timer;

- (void)					setLinkControlPart:(int) partcode modifierKeyMask:(NSEventModifierFlags) mask;


@end

