///**********************************************************************************************************************************
///  GCDashEditor.h
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
#import "GCDashEditView.h"

@class DKStrokeDash;
@class GCDashEditView;
@protocol GCDashEditorDelegate;

@interface GCDashEditor : NSWindowController <DashEditViewDelegate>
{
	IBOutlet NSTextField *mDashMarkTextField1;
	IBOutlet NSTextField *mDashSpaceTextField1;
	IBOutlet NSTextField *mDashMarkTextField2;
	IBOutlet NSTextField *mDashSpaceTextField2;
	IBOutlet NSTextField *mDashMarkTextField3;
	IBOutlet NSTextField *mDashSpaceTextField3;
	IBOutlet NSTextField *mDashMarkTextField4;
	IBOutlet NSTextField *mDashSpaceTextField4;
	IBOutlet NSMatrix *mDashCountButtonMatrix;
	IBOutlet NSButton *mDashScaleCheckbox;
	IBOutlet GCDashEditView *mDashPreviewEditView;
	IBOutlet NSButton *mPreviewCheckbox;
	IBOutlet NSSlider *mPhaseSlider;
	DKStrokeDash*			mDash;
	NSTextField*		mEF[8];
	id					mDelegateRef;
}


- (void)				openDashEditorInParentWindow:(NSWindow*) pw modalDelegate:(id<GCDashEditorDelegate>) del;
- (void)				updateForDash;
@property (nonatomic, retain) DKStrokeDash *dash;

@property CGFloat lineWidth;
@property NSLineCapStyle lineCapStyle;
@property NSLineJoinStyle lineJoinStyle;
@property (retain) NSColor *lineColour;

//! The relevant number of fields.
@property NSInteger dashCount;
- (void)				notifyDelegate;

- (IBAction)			ok:(id) sender;
- (IBAction)			cancel:(id) sender;
- (IBAction)			dashValueAction:(id) sender;
- (IBAction)			dashScaleCheckboxAction:(id) sender;
- (IBAction)			dashCountMatrixAction:(id) sender;
- (IBAction)			dashPhaseSliderAction:(id) sender;

@end



#pragma mark -

@protocol GCDashEditorDelegate <NSObject>

- (void)dashDidChange:(id) sender;

@end

