#import "GCSPolarDuplicateController.h"

#import <DKDrawKit/LogEvent.h>

@implementation GCSPolarDuplicateController
#pragma mark As a GCPolarDuplicateController

- (IBAction)angleAction:(id)sender
{
#pragma unused(sender)
}

- (IBAction)cancelAction:(id)sender
{
#pragma unused(sender)
	[self.window orderOut:self];
	[NSApp endSheet:self.window returnCode:NSCancelButton];
}

- (IBAction)centreAction:(id)sender
{
#pragma unused(sender)
	// disable the OK button if either of the centre fields are empty
	[self conditionallyEnableOKButton];
}

- (IBAction)copiesAction:(id)sender
{
#pragma unused(sender)
}

- (IBAction)duplicateAction:(id)sender
{
#pragma unused(sender)
	[self.window orderOut:self];
	[NSApp endSheet:self.window returnCode:NSOKButton];
}

- (IBAction)rotateCopiesAction:(id)sender
{
#pragma unused(sender)
}

- (IBAction)autoFitAction:(id)sender
{
	BOOL enable = ([sender intValue] == 0);

	//[mManualSettingsBox setEnabled:enable];

	mAngleIncrementTextField.enabled = enable;
	mCopiesTextField.enabled = enable;
	mRotateCopiesCheckbox.intValue = 1;
	mRotateCopiesCheckbox.enabled = enable;
}

#pragma mark -
- (void)beginPolarDuplicationDialog:(NSWindow *)parentWindow polarDelegate:(id)delegate
{
	mDelegateRef = delegate;

	[NSApp beginSheet:self.window
		modalForWindow:parentWindow
		 modalDelegate:self
		didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:)
		   contextInfo:@"polar_duplication"];

	NSInteger items = [delegate countOfItemsInSelection];
	mAutoFitCircleCheckbox.enabled = (items == 1);
	[self conditionallyEnableOKButton];
}

- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
#pragma unused(sheet, contextInfo)
	if (returnCode == NSOKButton) {
		// extract parameters and do something with them

		NSInteger copies = mCopiesTextField.integerValue;
		NSPoint centre;

		centre.x = mCentreXTextField.floatValue;
		centre.y = mCentreYTextField.floatValue;

		CGFloat incAngle = mAngleIncrementTextField.floatValue;
		BOOL rotCopies = mRotateCopiesCheckbox.intValue;

		if (mAutoFitCircleCheckbox.intValue == 1) {
			[mDelegateRef doAutoPolarDuplicateWithCentre:centre];
		} else {

			LogEvent_(kReactiveEvent, @"dialog data: copies %ld; centre {%.2f,%.2f}; incAngle %.3f; rotateCopies %d", (long)copies, centre.x, centre.y, incAngle, rotCopies);

			[mDelegateRef doPolarDuplicateCopies:copies centre:centre incAngle:incAngle rotateCopies:rotCopies];
		}
	}
}

#pragma mark -
- (void)conditionallyEnableOKButton
{
	if (mCentreXTextField.stringValue == nil ||
		[mCentreXTextField.stringValue isEqualToString:@""] ||
		mCentreYTextField.stringValue == nil ||
		[mCentreYTextField.stringValue isEqualToString:@""])
		[mOKButton setEnabled:NO];
	else
		[mOKButton setEnabled:YES];
}

@end
