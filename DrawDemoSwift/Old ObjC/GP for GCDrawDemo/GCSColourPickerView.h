//
//  GCColourPickerView.h
//  gradientpanel
//
//  Created by Graham on Tue Mar 27 2007.
//  Copyright (c) 2007 __MyCompanyName__. All rights reserved.
//

#import <AppKit/AppKit.h>
#import <DKDrawKit/GCInfoFloater.h>

typedef NS_ENUM(NSInteger, DKSColourPickerMode) {
	kDKSColourPickerModeSwatches = 0,
	kDKSColourPickerModeSpectrum = 1
};

@interface GCSColourPickerView : NSView {
	NSColor *mNonSelectColour;
	GCInfoFloater *mInfoWin;
	id mTargetRef;
	DKSColourPickerMode mMode;
	NSPoint mSel;
	SEL mSelector;
	CGFloat mBright;
	BOOL mShowsInfo;
}

@property DKSColourPickerMode mode;

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
