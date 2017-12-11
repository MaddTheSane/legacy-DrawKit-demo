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
@protocol DashEditViewDelegate;

@interface GCDashEditView : NSView
{
	DKStrokeDash*		mDash;
	NSMutableArray*	mHandles;
	NSBezierPath*	mPath;
	NSInteger mSelected;
	id<DashEditViewDelegate> mDelegateRef;
	NSColor*		mLineColour;
	NSRect			mPhaseHandle;
}


- (void)			setDash:(DKStrokeDash*) dash;
- (DKStrokeDash*)		dash;

- (void)			setLineWidth:(CGFloat) width;
- (void)			setLineCapStyle:(NSLineCapStyle) lcs;
- (void)			setLineJoinStyle:(NSLineJoinStyle) ljs;
- (void)			setLineColour:(NSColor*) colour;

@property (assign) id<DashEditViewDelegate> delegate;

- (void)			calcHandles;
- (NSInteger)mouseInHandle:(NSPoint) mp;
- (void)			drawHandles;
- (void)			calcDashForPoint:(NSPoint) mp;

@end

@protocol DashEditViewDelegate <NSObject>

- (void)			dashDidChange:(id) sender;

@end

#define		kDKStandardHandleRectSize	(NSMakeSize(8, 8 ))
#define		kDKDashEditInset			8
