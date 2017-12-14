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

@class DKStrokeDash;
@protocol GCDashEditViewDelegate;

@interface GCDashEditView : NSView {
	DKStrokeDash *mDash;
	NSMutableArray *mHandles;
	NSBezierPath *mPath;
	NSInteger mSelected;
	id<GCDashEditViewDelegate> __unsafe_unretained mDelegateRef;
	NSColor *mLineColour;
	NSRect mPhaseHandle;
}

@property (nonatomic, strong) DKStrokeDash *dash;

@property CGFloat lineWidth;
@property NSLineCapStyle lineCapStyle;
@property NSLineJoinStyle lineJoinStyle;
@property (nonatomic, strong) NSColor *lineColour;

@property (unsafe_unretained) id<GCDashEditViewDelegate> delegate;

//! calculates where the handle rects are given the current dash
- (void)calcHandles;

- (NSInteger)mouseInHandle:(NSPoint)mp;
- (void)drawHandles;

//! sets the dash element indexed by mSelected to the right size for the given mouse point
- (void)calcDashForPoint:(NSPoint)mp;

@end

@protocol GCDashEditViewDelegate <NSObject>

- (void)dashDidChange:(id)sender;

@end

#define kDKStandardHandleRectSize (NSMakeSize(8, 8))
#define kDKDashEditInset 8
