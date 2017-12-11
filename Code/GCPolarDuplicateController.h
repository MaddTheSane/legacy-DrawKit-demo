/* GCPolarDuplicateController */

#import <Cocoa/Cocoa.h>

@protocol PolarDuplicationDelegate;

@interface GCPolarDuplicateController : NSWindowController
{
    IBOutlet id mAngleIncrementTextField;
    IBOutlet id mCentreXTextField;
    IBOutlet id mCentreYTextField;
    IBOutlet id mCopiesTextField;
    IBOutlet id mRotateCopiesCheckbox;
	IBOutlet id	mAutoFitCircleCheckbox;
	IBOutlet id	mOKButton;
	IBOutlet id	mCancelButton;
	IBOutlet id	mManualSettingsBox;
	
	id<PolarDuplicationDelegate> mDelegateRef;
}


- (IBAction)	angleAction:(id)sender;
- (IBAction)	cancelAction:(id)sender;
- (IBAction)	centreAction:(id)sender;
- (IBAction)	copiesAction:(id)sender;
- (IBAction)	duplicateAction:(id)sender;
- (IBAction)	rotateCopiesAction:(id)sender;
- (IBAction)	autoFitAction:(id) sender;


- (void)	beginPolarDuplicationDialog:(NSWindow*) parentWindow polarDelegate:(id<PolarDuplicationDelegate>) delegate;
- (void)	sheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void  *)contextInfo;

- (void)	conditionallyEnableOKButton;

@end



@protocol PolarDuplicationDelegate <NSObject>

- (void)doPolarDuplicateCopies:(NSInteger) copies centre:(NSPoint) cp incAngle:(CGFloat) angle rotateCopies:(BOOL) rotCopies;
- (void)doAutoPolarDuplicateWithCentre:(NSPoint) cp;
- (NSInteger)countOfItemsInSelection;

@end
