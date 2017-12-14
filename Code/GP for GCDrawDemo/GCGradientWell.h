//
//  GCGradientWell.h
//  GradientTest
//
//  Created by Jason Jobe on 3/3/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class DKGradient;

typedef NS_ENUM(NSInteger, DKGradientWellMode) {
	kDKGradientWellDisplayMode			= 0,
	kDKGradientWellAngleMode			= 1,
	kDKGradientWellRadialMode			= 2,
	kDKGradientWellSweepMode			= 3
};

@interface GCGradientWell : NSControl
{
	DKGradientWellMode	mControlMode;
	NSTrackingRectTag	mTrackingTag;
	BOOL				mForceSquare;
	BOOL				mShowProxyIcon;
	BOOL				mCanBecomeActive;
	BOOL				mIsSendingAction;
}

@property (class, nonatomic, assign) GCGradientWell *activeWell;
+ (void)				clearAllActiveWells;

@property (strong) DKGradient *gradient;
- (void)				syncGradientToControlSettings;
- (void)				initiateGradientDragWithEvent:(NSEvent*) theEvent;

@property (nonatomic) DKGradientWellMode controlMode;

@property BOOL displaysProxyIcon;

- (void)				setupTrackingRect;
@property BOOL forceSquare;

@property BOOL canBecomeActiveWell;
@property (readonly, getter=isActiveWell) BOOL activeWell;
- (void)				wellDidBecomeActive;
- (void)				wellWillResignActive;
- (void)				toggleActiveWell;

- (NSMenu*)				menuForEvent:(NSEvent*) theEvent;

- (IBAction)			cut:(id) sender;
- (IBAction)			copy:(id) sender;
- (IBAction)			copyImage:(id) sender;
- (IBAction)			paste:(id) sender;
- (IBAction)			delete:(id) sender;
- (IBAction)			resetRadial:(id) sender;

@end
