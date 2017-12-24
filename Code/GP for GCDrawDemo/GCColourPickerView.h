//
//  GCColourPickerView.h
//  gradientpanel
//
//  Created by Graham on Tue Mar 27 2007.
//  Copyright (c) 2007 __MyCompanyName__. All rights reserved.
//

#import <AppKit/AppKit.h>

@class GCInfoFloater;

typedef NS_ENUM(NSInteger, DKColourPickerMode) {
	kDKColourPickerModeSwatches = 0,
	kDKColourPickerModeSpectrum = 1
};

@interface GCColourPickerView : NSView {
	NSColor *mNonSelectColour;
	GCInfoFloater *mInfoWin;
	__weak id mTargetRef;
	DKColourPickerMode mMode;
	NSPoint mSel;
	SEL mSelector;
	CGFloat mBright;
	BOOL mShowsInfo;
}

@property DKColourPickerMode mode;

- (void)drawSwatches:(NSRect)rect;
- (void)drawSpectrum:(NSRect)rect;

@property (readonly, copy) NSColor *color;
- (NSColor *)colorForSpectrumPoint:(NSPoint)p;
- (NSPoint)pointForSpectrumColor:(NSColor *)colour;
- (NSRect)rectForSpectrumPoint:(NSPoint)sp;
- (BOOL)pointIsInColourwheel:(NSPoint)p;

@property (nonatomic) CGFloat brightness;

- (NSPoint)swatchAtPoint:(NSPoint)p;
- (NSColor *)colorForSwatchX:(NSInteger)x y:(NSInteger)y;
- (NSRect)rectForSwatch:(NSPoint)sp;
- (void)updateInfoAtPoint:(NSPoint)p;

- (void)sendToTarget;

- (void)setTarget:(id)target;
- (void)setAction:(SEL)selector;

- (void)setColorForUndefinedSelection:(NSColor *)colour;
- (void)setShowsInfo:(BOOL)si;

@end
