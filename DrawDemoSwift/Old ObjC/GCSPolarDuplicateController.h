/* GCPolarDuplicateController */

#import <Cocoa/Cocoa.h>

@protocol GCSPolarDuplicationDelegate;

@interface GCSPolarDuplicateController : NSWindowController {
	IBOutlet NSTextField *mAngleIncrementTextField;
	IBOutlet NSTextField *mCentreXTextField;
	IBOutlet NSTextField *mCentreYTextField;
	IBOutlet NSTextField *mCopiesTextField;
	IBOutlet NSButton *mRotateCopiesCheckbox;
	IBOutlet NSButton *mAutoFitCircleCheckbox;
	IBOutlet NSButton *mOKButton;
	IBOutlet NSButton *mCancelButton;
	IBOutlet NSBox *mManualSettingsBox;

	__weak id<GCSPolarDuplicationDelegate> mDelegateRef;
}

- (IBAction)angleAction:(id)sender;
- (IBAction)cancelAction:(id)sender;
- (IBAction)centreAction:(id)sender;
- (IBAction)copiesAction:(id)sender;
- (IBAction)duplicateAction:(id)sender;
- (IBAction)rotateCopiesAction:(id)sender;
- (IBAction)autoFitAction:(id)sender;

- (void)beginPolarDuplicationDialog:(NSWindow *)parentWindow polarDelegate:(id<GCSPolarDuplicationDelegate>)delegate;
- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;

- (void)conditionallyEnableOKButton;

@end

@protocol GCSPolarDuplicationDelegate <NSObject>

- (void)doPolarDuplicateCopies:(NSInteger)copies centre:(NSPoint)cp incAngle:(CGFloat)angle rotateCopies:(BOOL)rotCopies;
- (void)doAutoPolarDuplicateWithCentre:(NSPoint)cp;
@property (readonly) NSInteger countOfItemsInSelection;

@end
