/* GCPolarDuplicateController */

#import <Cocoa/Cocoa.h>
#import "GCBasicDialogController.h"

@protocol PolarDuplicationDelegate;

@interface GCPolarDuplicateController : NSWindowController <GCBasicDialogDelegate> {
	IBOutlet NSTextField *mAngleIncrementTextField;
	IBOutlet NSTextField *mCentreXTextField;
	IBOutlet NSTextField *mCentreYTextField;
	IBOutlet NSTextField *mCopiesTextField;
	IBOutlet NSButton *mRotateCopiesCheckbox;
	IBOutlet NSButton *mAutoFitCircleCheckbox;
	IBOutlet NSButton *mOKButton;
	IBOutlet NSButton *mCancelButton;
	IBOutlet NSBox *mManualSettingsBox;

	__weak id<PolarDuplicationDelegate> mDelegateRef;
}

- (IBAction)angleAction:(id)sender;
- (IBAction)cancelAction:(id)sender;
- (IBAction)centreAction:(id)sender;
- (IBAction)copiesAction:(id)sender;
- (IBAction)duplicateAction:(id)sender;
- (IBAction)rotateCopiesAction:(id)sender;
- (IBAction)autoFitAction:(id)sender;

- (void)beginPolarDuplicationDialog:(NSWindow *)parentWindow polarDelegate:(id<PolarDuplicationDelegate>)delegate;
- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(NSModalResponse)returnCode contextInfo:(void *)contextInfo;

- (void)conditionallyEnableOKButton;

@end

@protocol PolarDuplicationDelegate <NSObject>

- (void)doPolarDuplicateCopies:(NSInteger)copies centre:(NSPoint)cp incAngle:(CGFloat)angle rotateCopies:(BOOL)rotCopies;
- (void)doAutoPolarDuplicateWithCentre:(NSPoint)cp;
@property (readonly) NSInteger countOfItemsInSelection;

@end
