//
//  GCMiniControl.h
//  panel
//
//  Created by Graham on Thu Apr 12 2007.
//  Copyright (c) 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class GCMiniControlCluster, GCInfoFloater;
@protocol GCMiniControlDelegate;

//! standard "partcodes" returned by hitTest method
//! subclasses can define their own using any other values
typedef NSInteger GCControlHitTest NS_TYPED_EXTENSIBLE_ENUM;
NS_ENUM(GCControlHitTest){
	kDKMiniControlNoPart = 0,
	kDKMiniControlEntireControl = -1};
#if 0
}
#endif

//! theme elements can be used to obtain standard colours across a range of controls
typedef NSInteger DKControlThemeElement;
NS_ENUM(DKControlThemeElement){
	kDKMiniControlThemeBackground = 0,
	kDKMiniControlThemeSliderTrack = 1,
	kDKMiniControlThemeKnobInterior = 2,
	kDKMiniControlThemeKnobStroke = 3,
	kDKMiniControlThemeIris = 4,
	kDKMiniControlThemeSliderTrkHilite = 5};
#if 0 // because Xcode is a dumb-dumb.
}
#endif

//! can have optional info window floater - delegate will be asked to supply value. Info
//! window is only shown during mouse tracking.
typedef NS_ENUM(NSInteger, DKControlInfoWindowMode) {
	kDKMiniControlNoInfoWindow = 0,
	kDKMiniControlInfoWindowFollowsMouse = 1,
	kDKMiniControlInfoWindowCentred = 2
};

//! this is an abstract class providing the interface for useful concrete subclasses.
//!
//! a mini-control is similar in concept but much simpler than NSControl. It relies on the host view to
//! call it with sensible parameters, and will draw into whatever is the current view. All coordinates
//! are in the host view's coordinate system.
//!
//! mini-controls are designed to be used in clusters (though you can have a cluster of 1). The cluster will
//! handle such things as control visible, etc and hit testing the cluster. clusters retain the controls
//! but not vice versa.
@interface GCMiniControl : NSObject {
	NSRect mBounds;												// area fully enclosing the control
	GCMiniControlCluster *__weak mClusterRef;					// cluster we belong to, if any
	NSString *mIdent;											// control's identifier, if any
	id<GCMiniControlDelegate> __unsafe_unretained mDelegateRef; // delegate, if any
	GCInfoFloater *mInfoWin;									// optional info window

	CGFloat mValue;						// current value
	CGFloat mMinValue;					// min value
	CGFloat mMaxValue;					// max value
	DKControlInfoWindowMode mInfoWMode; // info window mode
	BOOL mApplyShadow;					// YES to shadow drawn backgrounds
}

+ (NSColor *)miniControlThemeColor:(DKControlThemeElement)themeElementID withAlpha:(CGFloat)alpha;

- (id)initWithBounds:(NSRect)rect inCluster:(GCMiniControlCluster *)clust;
@property (weak) GCMiniControlCluster *cluster;
@property (readonly, strong) NSView *view;

@property (nonatomic) NSRect bounds;
- (void)draw;

- (void)applyShadow;

- (void)setNeedsDisplay;
- (void)setNeedsDisplayInRect:(NSRect)rect;

- (NSColor *)themeColour:(DKControlThemeElement)themeElementID;

- (GCControlHitTest)hitTestPoint:(NSPoint)p;

- (BOOL)mouseDownAt:(NSPoint)startPoint inPart:(GCControlHitTest)part modifierFlags:(NSEventModifierFlags)flags;
- (BOOL)mouseDraggedAt:(NSPoint)currentPoint inPart:(GCControlHitTest)part modifierFlags:(NSEventModifierFlags)flags;
- (void)mouseUpAt:(NSPoint)endPoint inPart:(GCControlHitTest)part modifierFlags:(NSEventModifierFlags)flags;
- (void)flagsChanged:(NSEventModifierFlags)flags;

- (void)setInfoWindowMode:(DKControlInfoWindowMode)mode;
- (void)setupInfoWindowAtPoint:(NSPoint)p withValue:(CGFloat)val andFormat:(NSString *)format;
- (void)updateInfoWindowAtPoint:(NSPoint)p withValue:(CGFloat)val;
- (void)hideInfoWindow;
- (void)setInfoWindowFormat:(NSString *)format;
- (void)setInfoWindowValue:(CGFloat)value;

@property (nonatomic, unsafe_unretained) id<GCMiniControlDelegate> delegate;
- (void)notifyDelegateWillChange:(id)value;
- (void)notifyDelegateDidChange:(id)value;

- (void)setIdentifier:(NSString *)name;
- (NSString *)identifier;

@property (nonatomic) CGFloat value;
@property (nonatomic) CGFloat maxValue;
@property (nonatomic) CGFloat minValue;

@end

// methods that can be implemented by the delegate (all optional)

@protocol GCMiniControlDelegate <NSObject>
@optional

- (void)miniControl:(GCMiniControl *)mc willChangeValue:(id)newValue;
- (void)miniControl:(GCMiniControl *)mc didChangeValue:(id)newValue;
- (CGFloat)miniControlWillUpdateInfoWindow:(GCMiniControl *)mc withValue:(CGFloat)val;

@end
