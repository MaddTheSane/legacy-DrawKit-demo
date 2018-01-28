///**********************************************************************************************************************************
///  GCDashEditView.h
///  GCDrawKit
///
///  Created by graham on 18/05/2007.
///  Released under the Creative Commons license 2007 Apptree.net.
///
///
///  This work is licensed under the Creative Commons Attribution-ShareAlike 2.5 License.
///  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/2.5/ or send a letter to
///  Creative Commons, 543 Howard Street, 5th Floor, San Francisco, California, 94105, USA.
///
///**********************************************************************************************************************************

#import <Cocoa/Cocoa.h>
#import <DKDrawKit/DKStrokeDash.h>

@protocol GCSDashEditViewDelegate;

@interface GCSDashEditView : NSView {
	DKStrokeDash *mDash;
	NSMutableArray *mHandles;
	NSBezierPath *mPath;
	NSInteger mSelected;
	__weak id<GCSDashEditViewDelegate> mDelegateRef;
	NSColor *mLineColour;
	NSRect mPhaseHandle;
}

@property (nonatomic, strong, nullable) DKStrokeDash *dash;

@property CGFloat lineWidth;
@property NSLineCapStyle lineCapStyle;
@property NSLineJoinStyle lineJoinStyle;
@property (nonatomic, strong, nonnull) NSColor *lineColour;

@property (weak, nullable) id<GCSDashEditViewDelegate> delegate;

//! calculates where the handle rects are given the current dash
- (void)calcHandles;

- (NSInteger)mouseInHandle:(NSPoint)mp;
- (void)drawHandles;

//! sets the dash element indexed by mSelected to the right size for the given mouse point
- (void)calcDashForPoint:(NSPoint)mp;

@end

@protocol GCSDashEditViewDelegate <NSObject>

- (void)dashDidChange:(nullable id)sender;

@end

#define kDKStandardHandleRectSize (NSMakeSize(8, 8))
#define kDKDashEditInset 8
